### Disabling SSH Timeout When Connecting to/from Ubuntu

[reference 1](https://queirozf.com/entries/disabling-ssh-timeout-when-connecting-to-from-ubuntu)
[reference 2](https://unix.stackexchange.com/questions/602518/ssh-connection-client-loop-send-disconnect-broken-pipe-or-connection-reset)

### SOL 1:
nano /etc/ssh/sshd_config
```bash
# other configs above

ClientAliveInterval 600
TCPKeepAlive yes
ClientAliveCountMax 10
```
Restart the ssh server so that changes take effect:
```console
$ sudo /etc/init.d/ssh restart
```
### SOL 2: 👌👍👍👍👍
- linux : nano  ~/.ssh/config
- window :edit  C:\Users\**USER**\.ssh\config
```
Host *
    ServerAliveInterval 20
    TCPKeepAlive no
```
