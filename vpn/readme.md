# VPN

## Create Domain Name

- [link doc](./any/create_domain_free.md)

## Check which ports are listening

```
netstat -tulpn
```

## Generate a self signed certificate and type in anything you like

```
cd ~;openssl genrsa -out key.pem 2048
openssl req -new -x509 -key key.pem -out cert.pem -days 4095
```

## UUID Generator

- https://www.uuidgenerator.net/

## AUTO START

- [reference 1](/LinuxEmbeddedSystems/general_config/auto_start_with_open_rc.md)

## 🧪 Test Speed Internet

```bash
wget --output-document=/dev/null http://speedtest.wdc01.softlayer.com/downloads/test500.zip
```
