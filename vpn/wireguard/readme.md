## Sub Documents

- [Config client ](./docs/client_config.md)

---

#### References

1. [Set up Server](wireguard_single_user.md)
2. [Set up a wireGuard client (**linux**)](client_wireguard_linux.md)

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
