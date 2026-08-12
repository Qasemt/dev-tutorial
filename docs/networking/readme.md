<h1 align="center">Networking</h1>

<p align="center">
  VPN tunnels, proxies, and tunneling tools.
</p>

<p align="center">
  <a href="#wireguard">WireGuard</a> ·
  <a href="#proxies--tunnels">Proxies & Tunnels</a> ·
  <a href="#tailscale">Tailscale</a> ·
  <a href="#domains">Domains</a> ·
  <a href="#quick-commands">Quick Commands</a>
</p>

---

## WireGuard

| Page | Notes |
| :--- | :--- |
| [Server Setup](./wireguard/server_setup.md) | CentOS 7, or Alpine on VirtualBox (NAT) |
| [Client Setup](./wireguard/client_setup.md) | Matching client configs, generic Linux, Raspberry Pi note |
| [Multi-user Restrictions](./wireguard/multiuser_restrictions.md) | Per-user iptables access control |

## Proxies & Tunnels

| Page | Notes |
| :--- | :--- |
| [Squid](./squid/readme.md) | HTTP proxy — config, single-IP allow, port testing |
| [Privoxy](./Privoxy_proxy.md) | Filtering proxy, blocking sites via `user.action` |
| [Shadowsocks](./Shadowsocks.md) | go-shadowsocks2 build and run |
| [MTProxy](./MTProxy.md) | Telegram MTProto proxy on CentOS 7 |
| [V2Ray](./v2ray/readme.md) | Setup + nginx/acme.sh SSL forwarding |
| [Tor](./tor.md) | Bridges and `torrc` |

## Tailscale

| Page | Notes |
| :--- | :--- |
| [Connecting Remote Teams](./tailscale_dev_setup.md) | Mesh VPN between NAT'd teams, no port forwarding |
| [Remote Serial Port Bridge](./remote_serial_bridge.md) | Windows COM port → Linux virtual serial port, via hub4com + socat |

## Domains

| Page | Notes |
| :--- | :--- |
| [Create a Free Domain + VPS](./create_domain_free.md) | Freenom domain pointed at a VPS IP |

---

## Quick Commands

Check which ports are listening:

```bash
netstat -tulpn
```

Generate a self-signed certificate:

```bash
cd ~;openssl genrsa -out key.pem 2048
openssl req -new -x509 -key key.pem -out cert.pem -days 4095
```

UUID generator: https://www.uuidgenerator.net/

Autostart a VPN/proxy service at boot: see [Autostart / Init Scripts](../embedded-linux/general_config/autostart.md).

Test internet speed:

```bash
wget --output-document=/dev/null http://speedtest.wdc01.softlayer.com/downloads/test500.zip
wget --output-document=/dev/null https://speed.hetzner.de/1GB.bin
```
