
#### source link
1. http://serverfault.com/questions/326268/python-new-install-showing-error-while-loading-shared-libraries

##### Step 1

ldconfig creates the necessary links and cache to the most recent shared libraries
found in the directories specified on the command line, in the file /etc/ld.so.conf, and in the trusted
directories (/lib and /usr/lib). The cache is used by the run-time linker, ld.so or ld-linux.so. ldconfig
checks the header and filenames of the libraries it encounters when determining which versions should have
their links updated.
```bash
#echo "/usr/local/Trolltech/geo123/lib" > /etc/ld.so.conf.d/gdal.conf

#echo "/usr/local/Trolltech/g123cubie2/lib" > /etc/ld.so.conf.d/g.conf

#echo "/usr/local/softwares/vtl" > /etc/ld.so.conf.d/vtl.conf
```
##### Step 
run this Command 
```bash
$  ldconfig

```

### Resolve link dll
##### Step 1 
```bash
nano relink.sh
chmod +x relink.sh 
```
##### Step 2
add this lines

```bash
rm /usr/local/Trolltech/geo123/lib/libproj.so
rm /usr/local/Trolltech/geo123/lib/libproj.so.0
rm /usr/local/Trolltech/geo123/lib/libpgtypes.so.3 
rm  /usr/local/Trolltech/geo123/lib/libpq.so.5
rm /usr/local/Trolltech/geo123/lib/libecpg_compat.so.3 
rm /usr/local/Trolltech/geo123/lib/libgeos-3.3.8.so 
rm /usr/local/Trolltech/geo123/lib/libecpg.so.6 
rm /usr/lib/libffi.so.6

sudo ln -s /usr/local/Trolltech/geo123/lib/libproj.so.0.7.0 /usr/local/Trolltech/geo123/lib/libproj.so
sudo ln -s /usr/local/Trolltech/geo123/lib/libproj.so.0.7.0 /usr/local/Trolltech/geo123/lib/libproj.so.0
sudo ln -s /usr/local/Trolltech/geo123/lib/libpgtypes.so.3.3 /usr/local/Trolltech/geo123/lib/libpgtypes.so.3 

sudo ln -s /usr/local/Trolltech/geo123/lib/libpq.so.5.5 /usr/local/Trolltech/geo123/lib/libpq.so.5
sudo ln -s /usr/local/Trolltech/geo123/lib/libecpg_compat.so.3.4 /usr/local/Trolltech/geo123/lib/libecpg_compat.so.3 
sudo ln -s /usr/local/Trolltech/geo123/lib/libgeos.so /usr/local/Trolltech/geo123/lib/libgeos-3.3.8.so 
sudo ln -s /usr/local/Trolltech/geo123/lib/libecpg.so.6.4 /usr/local/Trolltech/geo123/lib/libecpg.so.6 
sudo ln -s /usr/lib/libffi.so.6.0.1 /usr/lib/libffi.so.6
echo 'relink Finished :) ' 
```
