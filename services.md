##### Service List
```bash
service --status-all

service --status-all
 [ ? ] acpid
 [ - ] apparmor
 [ ? ] apport
 [ ? ] atd
 [ - ] bootlogd
 [ ? ] console-setup
 [ ? ] cron
 [ ? ] dbus
 [ ? ] dmesg
 [ ? ] dns-clean
 Remove a service
 ```
##### Remove the service start up
Use the remove keyword with update-rc.d to remove the service start up command for an application. You will need to use the -f switch if the applications **/etc/init.d** start up file exists.
```bash
update-rc.d -f  apache2 remove
```

##### Set StartUp Service

To make the script run with the start argument at the end of the start sequence, and run with the stop argument at the beginning of the shutdown sequence:
```bash
sudo update-rc.d myscript defaults 98 02
```

A more straightforward way is to make the init script non-executable. You do that with the *chmod* command.
```bash
sudo chmod -x /etc/init.d/myscript
```

After this the service will no longer be able to run.
Reactivate the service with:
```bash
sudo chmod +x /etc/init.d/myscript
```
------------------
###### Exam
```bash
service apache2 start
service apache2 stop
service apache2 status
```

