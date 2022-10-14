1. [only one ip to squid proxy server](https://serverfault.com/questions/1008068/how-to-enable-only-one-ip-to-squid-proxy-server)
---
## Squid
```
apt-get install squid 
apt-get install apache2-utils
```

nano /etc/squid/squid.conf
```
http_port 3128 transparent

# allow all requests
acl all src 0.0.0.0/0

#acl ncsa_users dst 0.0.0.0/0 all
http_access allow all
```

### manage Password 
---

Creating a new password file:

htpasswd -c -nbm /etc/squid/passwords username password
Adding users:

htpasswd -nbm /etc/squid/passwords username password
Deleting users:

htpasswd -D -nbm /etc/squid/passwords username

___________________________________________

printf "user1:$(openssl passwd -crypt 1234)\n" | sudo tee -a /etc/squid/htpasswd



```
curl -x http://public_IP_SERVER:3128  --proxy-user josh:tBYkDK0hcBlg2   -I  http://google.com 
curl -x http://public_IP_SERVER:3128   --proxy-user user1:HwlQMxxWMUbBw  -I http://google.com
curl -x http://public_IP_SERVER:3128    -I http://google.com
```
---

```
systemctl status squid
systemctl restart squid
```
