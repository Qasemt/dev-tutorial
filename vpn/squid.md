#### source
* [How to create your own HTTP Proxies using Squid Proxy on Ubuntu 16.04](https://www.proxyrack.com/how-to-create-your-own-http-proxies-using-squid-proxy-on-ubuntu-16-04/)
* [config 2](https://www.linode.com/docs/web-servers/squid/squid-http-proxy-ubuntu-12-04/)


## SQUID Condif 
```
#
# Recommended minimum configuration:
#

# Example rule allowing access from your local networks.
# Adapt to list your (internal) IP networks from where browsing
# should be allowed

debug_options ALL,2 0,6 11,6 28,6 46,6

acl localnet src 10.0.0.0/8	# RFC1918 possible internal network
acl localnet src 172.16.0.0/12	# RFC1918 possible internal network
acl localnet src 192.168.0.0/16	# RFC1918 possible internal network
acl localnet src fc00::/7       # RFC 4193 local private network range
acl localnet src fe80::/10      # RFC 4291 link-local (directly plugged) machines

acl SSL_ports port 443
acl Safe_ports port 80		# http
acl Safe_ports port 21		# ftp
acl Safe_ports port 443		# https
acl Safe_ports port 70		# gopher
acl Safe_ports port 210		# wais
acl Safe_ports port 1025-65535	# unregistered ports
acl Safe_ports port 280		# http-mgmt
acl Safe_ports port 488		# gss-http
acl Safe_ports port 591		# filemaker
acl Safe_ports port 777		# multiling http
acl CONNECT method CONNECT

#
# Recommended minimum Access Permission configuration:
#

# Only allow cachemgr access from localhost
http_access allow localhost manager
http_access deny manager

# Deny requests to certain unsafe ports
http_access deny !Safe_ports

# Deny CONNECT to other than secure SSL ports
http_access deny CONNECT !SSL_ports

# We strongly recommend the following be uncommented to protect innocent
# web applications running on the proxy server who think the only
# one who can access services on "localhost" is a local user
#http_access deny to_localhost

#
# INSERT YOUR OWN RULE(S) HERE TO ALLOW ACCESS FROM YOUR CLIENTS
#

acl whitelist dstdomain "/etc/squid/sites.whitelist.txt"
http_access allow whitelist


# Example rule allowing access from your local networks.
# Adapt localnet in the ACL section to list your (internal) IP networks
# from where browsing should be allowed
#http_access allow localnet
#http_access allow localhost

# And finally deny all other access to this proxy
http_access deny all

# Squid normally listens to port 3128
http_port 3128

# Uncomment the line below to enable disk caching - path format is /cygdrive/<full path to cache folder>, i.e.
#cache_dir aufs /cygdrive/d/squid/cache 3000 16 256


# Leave coredumps in the first cache dir
coredump_dir /var/cache/squid

# Add any of your own refresh_pattern entries above these.
refresh_pattern ^ftp:		1440	20%	10080
refresh_pattern ^gopher:	1440	0%	1440
refresh_pattern -i (/cgi-bin/|\?) 0	0%	0
refresh_pattern .		0	20%	4320

dns_nameservers 8.8.8.8 208.67.222.222

max_filedescriptors 3200
```

### /etc/squid/sites.whitelist.txt
```
.example.com
.google.com
.bing.com
.wikipedia.org

#Docker
registry-1.docker.io
auth.docker.io
production.cloudflare.docker.com
go.microsoft.com
winlayers.cdn.mscr.io
```