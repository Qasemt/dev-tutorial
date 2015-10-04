```bash
apt-get update
```
to refresh the package lists, then

apt-cache search zlib
to check the relevant packages in the lists you have just updated, then

apt-get install <whatever_package_you_found_earlier>
I suggest using regular expression as search strings for apt-cache, since they are more accurate, as in
```bash
apt-cache search ^zlib
```

##### For Cubie
```bash
sudo apt-get install --reinstall zlibc zlib1g zlib1g-dev
```

##### Tools For Serial Port on Linux
1. gtkterm
2. minicom
3. cutecom

