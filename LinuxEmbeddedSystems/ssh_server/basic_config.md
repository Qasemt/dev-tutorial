# ctrl service 
```
service sshd restart
```

You can also change the configuration of SSHD. Edit /etc/ssh/sshd_config and add

```
$ nano /etc/ssh/sshd_config
```
set 
```
PermitRootLogin yes
```



# SSH Config 
causes of slow ssh logins
Try setting UseDNS to no in **/etc/sshd_config** or **/etc/ssh/sshd_config**

``` console
 UseDNS no 
 ```

________
### Connect to SSH without password (RSA KEY)


[link 1 ](https://geekdudes.wordpress.com/2016/10/06/ssh-login-without-password-from-windows-to-ubuntu-server-16-04-1-lts/)

[link 2 !!! ](https://askubuntu.com/questions/306798/trying-to-do-ssh-authentication-with-key-files-server-refused-our-key)


#### Trying to do ssh authentication with key files: server refused our key

``` bash 
generate a key pair with puttygen.exe (length: 1024 bits)
load the private key in the PuTTY profile
enter the public key in ~/.ssh/authorized_keys in one line (needs to start with ssh-rsa)
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
chown $USER:$USER ~/.ssh -R
change /etc/ssh/sshd_config so it contains AuthorizedKeysFile %h/.ssh/authorized_keys
sudo service ssh restart
For troubleshooting do # tail -f /var/log/auth.log.

```
