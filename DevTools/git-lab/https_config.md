

#### Step 1: Create the SSL Certificate
``` console
sudo mkdir -p /etc/gitlab/ssl
sudo chmod 700 /etc/gitlab/ssl

sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout gitlab.xxxx.com.key -out gitlab.xxxx.com.crt
```

#### Step 2: add config 

>sudo nano /etc/gitlab/gitlab.rb

``` bash 
external_url 'https://gitlab.xxxxxx.com'

nginx['ssl_certificate'] = "/etc/gitlab/ssl/gitlab.xxxx.com.crt" 
 nginx['ssl_certificate_key'] = "/etc/gitlab/ssl/gitlab.xxxx.com.key"
nginx['proxy_set_headers'] = {
 "X-Forwarded-Proto" => "http"
 }
 
```
#### Step 3: run cmd

```
sudo gitlab-ctl reconfigure
sudo gitlab-ctl restart
```

#### for debug nginx 
```
sudo gitlab-ctl tail nginx
```
