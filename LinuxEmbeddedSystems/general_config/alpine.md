1. [ref link ....](https://unix.stackexchange.com/questions/171643/virtualbox-time-sync)

---

# Sync time apline in VM

install virtualbox

```bash
apk add virtualbox-guest-additions
```

run cmd

```bash
 /usr/sbin/VBoxService --timesync-set-start
```
