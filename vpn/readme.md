 ### Check which ports are listening
 
 ```
 netstat -tulpn
 ```

### Generate a self signed certificate and type in anything you like

```
cd ~;openssl genrsa -out key.pem 2048
openssl req -new -x509 -key key.pem -out cert.pem -days 4095
```
