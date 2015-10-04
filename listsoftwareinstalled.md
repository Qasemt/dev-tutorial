
sudo dpkg --get-selections | sed "s/.*deinstall//" | sed "s/install$//g" > ~/pkglist

This will store your currently installed packages in the file ~/pkglist (~ stands for your home directory). You can open and review it with any text editor or in the terminal with
```bash
nano  ~/pkglist
```

___

### ADD/Remove Program in linux (GUI Base) 
apt-get install synaptic
