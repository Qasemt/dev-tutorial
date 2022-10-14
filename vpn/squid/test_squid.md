## test port squid 8080 or 3128 or any 
```
netstat -lnp | grep 8080
```

## Test 
```
curl -x http://public_IP_SERVER:3128  --proxy-user josh:tBYkDK0hcBlg2   -I  http://google.com 
curl -x http://public_IP_SERVER:3128   --proxy-user user1:HwlQMxxWMUbBw  -I http://google.com
curl -x http://public_IP_SERVER:3128    -I http://google.com

```
