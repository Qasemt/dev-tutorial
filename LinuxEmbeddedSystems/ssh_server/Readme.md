1. [Disabling SSH Timeout When Connecting to/from Ubuntu](Disabling_SSH_Timeout.md)
2. [Connect to SSH without password (RSA KEY)](connect_to_ssh_without_password.md) 

----

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



