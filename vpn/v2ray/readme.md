
1. [How To Setup Your Own v2ray on a Virtual Server](https://privacymelon.com/v2ray-setup-guide/)
2. [link proxy forward](https://hxp.plus/2020/02/07/v2ray/#use-nginx-to-forward-port-443-to-v2ray)
---

### Using acme.sh to install SSL cert for nginx
  * acme.sh requires socat
```
apt install socat
```

```
curl https://get.acme.sh | sh -s email=user1@freevista.com
Or 
wget -O -  https://get.acme.sh | sh -s email=my@example.com
```
