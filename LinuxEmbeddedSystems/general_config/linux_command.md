### Remove

```console
apt-get remove packagename
```

will remove the binaries, but not the configuration or data files of the package packagename. It will also leave dependencies installed with it on installation time untouched.

```console
apt-get purge packagename or apt-get remove --purge packagename
```

will remove about everything regarding the package packagename, but not the dependencies installed with it on installation.
Both commands are equivalent.

Particularly useful when you want to 'start all over' with an application because you messed up the configuration. However,
it does not remove configuration or data files residing in users home directories, usually in hidden folders there.
There is no easy way to get those removed as well.

```console
apt-get autoremove
```

removes orphaned packages, i.e. installed packages that used to be installed as an dependency,
but aren't any longer. Use this after removing a package which had installed dependencies you're no longer interested in.

```console
aptitude remove packagename or aptitude purge packagename (likewise)
```

will also attempt to remove other packages which were required by packagename on but are not required by any remaining packages.
Note that aptitude only remembers dependency information for packages that it has installed.

---

---

#### How to find location of installed library

```console
dpkg -L packagename
```

---

#### Find file

```console
locate <file name>
sudo updatedb ### for update cache locate
```

### Kill

```console
ps aux | grep node
killall -9 any node

# for kill nginx
kill $(ps aux | grep 'nginx' | awk '{print $2}')

```
