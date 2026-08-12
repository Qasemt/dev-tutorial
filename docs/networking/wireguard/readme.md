# WireGuard

## Guides

1. [Server Setup](server_setup.md) — CentOS 7, or Alpine on VirtualBox (NAT)
2. [Client Setup](client_setup.md) — matching client configs, generic Linux/Linode client, Raspberry Pi AllowedIPs note
3. [Multi-user restrictions with iptables](multiuser_restrictions.md) — LAN-only users, port-restricted users, web-only users

---

#### How To Set Up WireGuard

- Installing WireGuard

```sh
# apt update
# apt install wireguard qrencode resolvconf
```

- Service Handle

```sh
# systemctl start wg-quick@wg0
# systemctl status wg-quick@wg0

OR

# wg-quick up wg0
# wg-quick down wg0

```

- Create QR CODE

```sh
# qrencode -t ansiutf8 < client01.conf
```

## Simple monitoring

check the wireguard connection using sudo wg show

```sh
# watch -n 1  wg show
```
