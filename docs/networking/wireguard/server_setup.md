# WireGuard Server Setup

Setting up a WireGuard server, by platform.

## CentOS 7

- https://www.youtube.com/watch?v=QjbwKPBZEeU
- https://kb.bluvalt.com/howto/setup-wireguard-centos/
- https://upcloud.com/resources/tutorials/get-started-wireguard-vpn
- https://arash-hatami.ir/config-wireguard/

System Requirements:

- OS: CentOS 7
- RAM: minimum 1024MB (2GB preferable)

```bash
#yum install kernel-devel kernel-headers # you have to install kernel headers first
#yum install epel-release https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm
#yum install yum-plugin-elrepo
#yum install kmod-wireguard wireguard-tools
#yum install qrencode or apk add libqrencode
#yum install nano
```

Reboot, then load the module:

```bash
$ modprobe wireguard
```

If `modprobe` doesn't work, you may have to reboot the machine.

```bash
#reboot
#lsmod | grep -i wireguard
```

```bash
#cd /etc/wireguard/
```

```bash
#umask 077
#umask
#wg genkey | tee server-private.key | wg pubkey > server-public.key
#ls -al
#nano wg0.conf
```

Put all of the following into the file, edit the marked sections, and save:

```conf
[Interface]
Address = 192.168.200.254/24
SaveConfig = true
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
ListenPort = 55525
PrivateKey = _$SERVER_PRIVATE_KEY_

[Peer]
PublicKey = $CLIENT_PUBLIC_KEY
AllowedIPs = 192.168.200.5/32
```

```bash
#cat server-private.key
```

Copy the key and insert it, then generate a client keypair:

```bash
#wg genkey | tee client-private.key | wg pubkey > client-public.key
#cat client-public.key
```

Copy each key into `wg0.conf` as needed, then check the firewall and IP forwarding:

```bash
# iptables -vnL
# sysctl -a | grep -i forward
```

Enable IP forwarding — edit `/etc/sysctl.conf` (or a `.conf` file under `/etc/sysctl.d/`) and add:

```conf
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding=1
```

```bash
# sysctl -p /etc/sysctl.d/wireguard.conf
# sysctl -a | grep -i ip_forward
```

The matching client config for this server is in [Client Setup](client_setup.md).

---

## Alpine, on VirtualBox (NAT)

```bash
apk add wireguard-tools
modprobe wireguard
```

Generate server and client keys:

```bash
wg genkey | tee server-private.key | wg pubkey > server-public.key
wg genkey | tee client-private.key | wg pubkey > client-public.key
```

`/etc/wireguard/wg0.conf`:

```conf
[Interface]
Address = 10.0.0.1/24
ListenPort = 55525
PrivateKey = SERVER_PRIVATE_KEY_

PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE; ip6tables -A FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE; ip6tables -D FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
PublicKey = CLIENT_PUBLIC_KEY
#AllowedIPs = 10.0.0.2/32,192.168.1.0/24
AllowedIps = 10.0.0.2/32
```

Note: on the server, set `AllowedIPs` to the peer's own `/32` (e.g. `10.0.0.2/32` for an iPhone) so it can't be spoofed by another peer; on that peer's own client config, keep `AllowedIPs = 0.0.0.0/0` (all IPv4).

Once running, sanity-test the tunnel:

```bash
wget -O /dev/null http://speedtest.wdc01.softlayer.com/downloads/test500.zip
```

### Firewall / routing via helper scripts

Instead of inline `PostUp`/`PostDown`, you can point at scripts:

```conf
[Interface]
...
...
PostUp = /etc/wireguard/postup.sh
PostDown = /etc/wireguard/postdown.sh
```

`postup.sh`:

```shellscript
#!/bin/sh
iptables -A FORWARD -i wg0 -j ACCEPT;
...
...
...
```

```bash
chmod a+rx  /etc/wireguard/postup.sh
chmod a+rx  /etc/wireguard/postdown.sh
```

The matching client config for this server is in [Client Setup](client_setup.md).
