# Wireguard and iptables restrictions for multiple users

If you don't know what Wireguard is, well, you should.
It's fast, easy to setup and highly configurable.
We will configure Wireguard for multiple users with various restrictions using *iptables*.

## Assumptions

This should fit most setups (not mine though :wink:)

- LAN network: `192.168.1.0/24` (`192.168.1.1` => `192.168.1.254`)
- LAN DNS server address: `192.168.1.1`
- Wireguard is installed (kernel and tools) on a Linux host (it should also work on other platforms though).
- The Linux host address: `192.168.1.10`
- The Linux host main interface: `enp4s0` (find it with `ip a`)

## Initial server setup

1. Ensure your iptables firewall has its FORWARD table policy set to `DROP`:

    ```sh
    iptables -P FORWARD -j DROP
    ```

1. Generate a Wireguard private key

    ```sh
    echo "Private key: $(wg genkey)"
    ```

    ```text
    Private key: OM5BUrGVAswOm/r8asLtdUgJB8rrXflD6TVFL5aGAHk=
    ```

1. Create a file **/etc/wireguard/wg0.conf** (or any other name than `wg0`) with content:

    ```conf
    [Interface]
    Address = 10.0.0.1/24
    ListenPort = 51820
    PrivateKey = OM5BUrGVAswOm/r8asLtdUgJB8rrXflD6TVFL5aGAHk=
    PostUp = /etc/wireguard/postup.sh
    PostDown = /etc/wireguard/postdown.sh
    ```

    **Don't forget** to replace the `PrivateKey` value with the one you generated

1. Create a file **/etc/wireguard/postup.sh** with content:

    ```sh
    WIREGUARD_INTERFACE=wg0
    WIREGUARD_LAN=10.0.0.0/24
    MASQUERADE_INTERFACE=enp4s0

    iptables -t nat -I POSTROUTING -o $MASQUERADE_INTERFACE -j MASQUERADE -s $WIREGUARD_LAN

    # Add a WIREGUARD_wg0 chain to the FORWARD chain
    CHAIN_NAME="WIREGUARD_$WIREGUARD_INTERFACE"
    iptables -N $CHAIN_NAME
    iptables -A FORWARD -j $CHAIN_NAME

    # Accept related or established traffic
    iptables -A $CHAIN_NAME -o $WIREGUARD_INTERFACE -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

    # Accept traffic from any Wireguard IP address connected to the Wireguard server
    iptables -A $CHAIN_NAME -s $WIREGUARD_LAN -i $WIREGUARD_INTERFACE -j ACCEPT

    # Drop everything else coming through the Wireguard interface
    iptables -A $CHAIN_NAME -i $WIREGUARD_INTERFACE -j DROP

    # Return to FORWARD chain
    iptables -A $CHAIN_NAME -j RETURN
    ```

1. Create a file **/etc/wireguard/postdown.sh** with content:

    ```sh
    WIREGUARD_INTERFACE=wg0
    WIREGUARD_LAN=10.0.0.0/24
    MASQUERADE_INTERFACE=enp4s0
    CHAIN_NAME="WIREGUARD_$WIREGUARD_INTERFACE"

    iptables -t nat -D POSTROUTING -o $MASQUERADE_INTERFACE -j MASQUERADE -s $WIREGUARD_LAN

    # Remove and delete the WIREGUARD_wg0 chain
    iptables -D FORWARD -j $CHAIN_NAME
    iptables -F $CHAIN_NAME
    iptables -X $CHAIN_NAME
    ```

## First admin client

Let's setup a client with full access to Internet and your LAN through Wireguard.

1. Install Wireguard on your client device
1. On your client device, create a configuration file **client.conf** with content:

    ```conf
    [Interface]
    Address = 10.0.0.2/32
    DNS = 192.168.1.1
    PrivateKey = YOUR_CLIENT_PRIVATE_KEY

    [Peer]
    AllowedIPs = 0.0.0.0/0, ::/0
    Endpoint = 192.168.1.10:51820
    PersistentKeepalive = 25
    PublicKey = YOUR_SERVER_PUBLIC_KEY
    ```

1. Replace in the configuration above `YOUR_SERVER_PUBLIC_KEY` with the key shown using `wg show wg0 public-key` on your server. For example: `p6aGalk69yCM8vNhbvC5mEH/HhJr1c8f55UaeJSChX0=`.
1. Generate keys for your client:

    ```sh
    priv=`wg genkey` && printf "Private key: $priv\nPublic key: `echo "$priv" | wg pubkey`\n" && unset -v priv
    ```

    ```text
    Private key: 2L4L8YwusK4Ot4jVoo/1wwQfLAeRM6kJ/WWxzfnWKm4=
    Public key: GmVyaj+K36xEk7ko/8jijMB9XX9dFgi4mJxsAEFMHmA=
    ```

1. Replace in client.conf `YOUR_CLIENT_PRIVATE_KEY` with the private key just generated above.
1. Use the public key shown above to add the following block to **/etc/wireguard/wg0.conf** on your server:

    ```conf
    [Peer]
    # Your first admin client
    PublicKey = GmVyaj+K36xEk7ko/8jijMB9XX9dFgi4mJxsAEFMHmA=
    AllowedIPs = 10.0.0.2/32
    ```

1. On your server, start Wireguard: `wg-quick up wg0`.
1. You should now be able to connect to the Wireguard server from your client. You can check on the server with `wg` and it should show a `latest handshake` line.

## LAN only user

Let's add a user who should only have access to the LAN.

1. Repeat steps 1 to 5 from the First admin client section above.
1. Use the public key shown in step 4 to add the following block to **/etc/wireguard/wg0.conf** on your server:

    ```conf
    [Peer]
    # LAN only user
    PublicKey = 7GneIV/Od7WEKfTpIXr+rTzPf3okaQTBwsfBs5Eqiyw=
    AllowedIPs = 10.0.0.3/32
    ```

1. Shutdown Wireguard: `wg-quick down wg0`
1. Modify **/etc/wireguard/postup.sh**:
    - Limit full access to our first admin client `10.0.0.2` only by changing:

        ```sh
        iptables -A $CHAIN_NAME -s 10.0.0.0/24 -i $WIREGUARD_INTERFACE -j ACCEPT
        ```

        to

        ```sh
        iptables -A $CHAIN_NAME -s 10.0.0.2 -i $WIREGUARD_INTERFACE -j ACCEPT
        ```

    - Add a new line to allow our new user to LAN access only

        ```sh
        iptables -A $CHAIN_NAME -s 10.0.0.3 -i $WIREGUARD_INTERFACE -d 192.168.1.0/24 -j ACCEPT
        ```

1. Start Wireguard: `wg-quick up wg0`
1. Note that the client should set its `AllowedIPs = 0.0.0.0/0, ::/0` to `AllowedIPs = 192.168.1.0/24` so it tunnels only to when trying to reach an address on the LAN.

## Restrict the user to a port

Let's re-use the user we previously created. Let's only allow him to access port 445 (Samba) on a server `192.168.1.20` for example.

1. Shutdown Wireguard: `wg-quick down wg0`
1. Modify

    ```sh
    iptables -A $CHAIN_NAME -s 10.0.0.3 -i $WIREGUARD_INTERFACE -d 192.168.1.0/24 -j ACCEPT
    ```

    to

    ```sh
    iptables -A $CHAIN_NAME -s 10.0.0.3 -i $WIREGUARD_INTERFACE -d 192.168.10.20 -p tcp --dport 445 -j ACCEPT
    ```

1. Start Wireguard: `wg-quick up wg0`

## Restrict the user to limited Web browsing only

That's useful for our friends who want to stream restricted content on Netflix without allowing them on your LAN 😉

1. Shutdown Wireguard: `wg-quick down wg0`
1. Modify

    ```sh
    iptables -A $CHAIN_NAME -s 10.0.0.3 -i $WIREGUARD_INTERFACE -d 192.168.10.20 -p tcp --dport 445 -j ACCEPT
    ```

    to

    ```sh
    # DNS
    iptables -A $CHAIN_NAME -s 10.0.0.3 -i $WIREGUARD_INTERFACE -d 192.168.1.1 -p udp --dport 53 -j ACCEPT
    # Drop traffic to your any private IP address
    iptables -A $CHAIN_NAME -s 10.0.0.3 -i $WIREGUARD_INTERFACE -d 10.0.0.0/8,172.16.0.0/12,192.168.0.0/16 -j DROP
    # Accept outgoing connections to HTTP(S) ports to any IP address (public because of rule above)
    iptables -A $CHAIN_NAME -s 10.0.0.3 -i $WIREGUARD_INTERFACE -d 0.0.0.0/0 -p tcp -m multiport --dports 80,443 -j ACCEPT
    ```

1. Start Wireguard: `wg-quick up wg0`
1. Don't forget to set back the client to `AllowedIPs = 0.0.0.0/0, ::/0`

## More rules

Feel free to comment, I'll try my best to make you a rule 😉

Enjoy!
