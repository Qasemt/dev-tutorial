1. [referece 1 ](https://parspack.com/blog/os/linux/how-to-configure-linux-server-iptables-firewall)
2. [ip table command ](https://linuxlearn.org/what-is-iptable/)
3. [delete iptables (digital ocean)](https://www.digitalocean.com/community/tutorials/how-to-list-and-delete-iptables-firewall-rules)
4. [help](https://linux.die.net/man/8/iptables)

---

## 🔗 Chain :

- add chain

```bash
# iptables -N (enter chain name)
```

---

نمایش وضعیت فایروال لینوکس (linux iptables)

```bash
# iptables -n -L -v --line-numbers
```

حذف کلیه رول ها از فایروال ( Flush iptables ):

```bash
# iptables -F
OR
# iptables --flush

# service iptables save
Saving firewall rules to /etc/sysconfig/iptables:          [  OK  ]
```

### نحوه مسدود نمودن یک IP بر روی سرور

```bash
# iptables -A INPUT -s 1.2.3.4 -j DROP

# iptables -A INPUT -s 192.168.0.0/24 -j DROP
```

---

## ⏩ Forward

How to forward port in Linux

> Here we will forward port 80 to port 8080 on 172.31.40.29. Do not get confused port forwarding with port redirection.
> We need to insert an entry in PREROUTING chain of iptables with DNAT target. Command will be as follows –

```bash
# iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 80 -j DNAT --to 172.31.40.29:8080
# iptables -A FORWARD -p tcp -d 172.31.40.29 --dport 8080 -j ACCEPT
```

---

## 🚀 Test and Check

How to check port forwarding iptables rules

```bash
[pc:]# iptables -t nat -L -n -v
result :

Chain PREROUTING (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination
    0     0 DNAT       tcp  --  eth0   *       0.0.0.0/0            0.0.0.0/0            tcp dpt:80 to:172.31.40.29:8080

```

Using ICMPv4:

```sh
ping <client wireguard ip > for exam -> 10.0.0.2
ping fdc9:281f:04d7:9ee9::2
```

> iptables -t nat -xvnL

> tcpdump -n -tttt -i wg0 not port 22

---

## 💾 How to save iptables rules

```bash
# service iptables save

Saving firewall rules to /etc/sysconfig/iptables:          [  OK  ]
```
