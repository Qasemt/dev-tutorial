## Privoxy 
### download last Version :
https://www.privoxy.org/sf-download-mirror/Win32/

### change config.txt 
* remove 127.0.0.1 from this line
listen-address  :8118

### block sites in user.action
```
{ +block }
www.example.com/nasty-ads/sponsor.gif
.instagram.com
www.whatsapp.com
www.web.whatsapp.com
.whatsapp.com
```
