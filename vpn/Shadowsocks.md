# Shadowsocks
### Source :
*  https://github.com/shadowsocks/go-shadowsocks2
*  https://golang.org/doc/install?download=go1.15.7.linux-amd64.tar.gz
____
<ol>
<li> apt-get update && apt-get upgrade</li>
<li> install golang latest (manually )</li>
<li> compile source with golang</li>
<li> run server and client go-shadowsocks2 </li>

arguments used :
 <br><code>verbose</code>
<br><code> password : 1234</code>

```
https://golang.org/doc/install?download=go1.15.7.linux-amd64.tar.gz
```
<li>  Server:</li>

```
./go-shadowsocks2 -s 'ss://AEAD_CHACHA20_POLY1305:1234@:8488' 
```
<li>  client :</li>

```
./go-shadowsocks2 -c 'ss://AEAD_CHACHA20_POLY1305:1234@[127.0.0.1]:8488' \
    -socks :1080 -u -udptun :8053=8.8.8.8:53,:8054=8.8.4.4:53 \
                             -tcptun :8053=8.8.8.8:53,:8054=8.8.4.4:53
```

<li> if you use virtual box -> set NAT port forwarding [ip guest]**1080** : to host [127.0.0.1:any port]</li>

<ol>
