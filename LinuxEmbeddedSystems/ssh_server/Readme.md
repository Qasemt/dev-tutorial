1. [Disabling SSH Timeout When Connecting to/from Ubuntu](Disabling_SSH_Timeout.md)
2. [Connect to SSH without password (RSA KEY)](connect_to_ssh_without_password.md)
3. [Config Port ssh For VM and Host windows](config_vm_host_windows.md)

---

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

#### enable root login from ssh

```bash
sudo nano /etc/ssh/sshd_config

# search for the line starting with

PermitRootLogin yes

# must be "yes", "without-password", "forced-commands-only" or "no".

```

# SSH Config

causes of slow ssh logins
Try setting UseDNS to no in **/etc/sshd_config** or **/etc/ssh/sshd_config**

```console
 UseDNS no
```
