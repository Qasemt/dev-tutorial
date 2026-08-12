1. [Disabling SSH Timeout When Connecting to/from Ubuntu](Disabling_SSH_Timeout.md)
2. [Connect to SSH without password (RSA KEY)](SSH-Login-No-Password.md)
3. [Config Port ssh For VM and Host windows](config_vm_host_windows.md)

---

config login with public / private key :

```text
https://wpclouddeploy.com/add-your-existing-ssh-key-to-the-root-user-account/
```

---

# ctrl service

```bash
service sshd restart
```

You can also change the configuration of SSHD. Edit /etc/ssh/sshd_config and add

```bash
$ nano /etc/ssh/sshd_config
```

set

```conf
PermitRootLogin yes
```

## SSH Password Login for Non-Root Users

To allow SSH access for users other than `root` using a password, make sure the following options are set in `/etc/ssh/sshd_config`:

```conf
PasswordAuthentication yes
AllowUsers root <username>
```


#### enable root login from ssh

```bash
sudo nano /etc/ssh/sshd_config

# search for the line starting with

PermitRootLogin yes

# must be "yes", "without-password", "forced-commands-only" or "no".

```

## SSH Config

causes of slow ssh logins
Try setting UseDNS to no in **/etc/sshd_config** or **/etc/ssh/sshd_config**

```console
 UseDNS no
```

### change port SSH

```bash
netstat -tulnp | grep ssh
nano /etc/ssh/sshd_config
Port 22333
systemctl restart sshd
netstat -tulpn | grep ssh
ssh -p 22333 user@localhost
ufw allow 22333/tcp
```
