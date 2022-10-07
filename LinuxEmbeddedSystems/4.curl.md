### For Alpine install build tool (make ,compiler)
```
apk --no-cache --update add build-base 
apk --no-cache add automake  autoconf libtool

apk add openssl-dev libssh2-dev

```
---
- Download latest `curl`
- Manual install `curl`:
```
sudo apt install libssh2-1-dev libssl-dev
cd curl/
./buildconf

./configure --with-ssl --with-libssh2
make
sudo make install
```
- Test installation:
```
curl -V
```
#### test upload
``` console
curl  -k sftp://XXX.XXX.XXX.XXX/~/ -u  username:pass -T /home/XXXX/ff --ftp-create-dirs 
```
