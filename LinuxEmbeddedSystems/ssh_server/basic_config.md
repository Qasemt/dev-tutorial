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
