September 25th, 2007 mysurface Posted in Admin, chmod, shutdown, sudo | Hits: 174172 | 17 Comments »
If you are gnome user, you probably enjoy shutdown with just a click on the dialog. In order to shutdown from command line, you are requested to be either ***root or using sudo***, such as
```bash
sudo shutdown -h now
```
For more detail examples of shutdown, continue to read here.
With sudo, you need to type your password. Sometimes it will be more convenient to us if we are able to shutdown without sudo. Is it possible?
The answer is yes, there are two ways to do that (Any other ways available?)
```bash
1. Adding suid mode to /sbin/shutdown
2. Modify /etc/sudoers with visudo
```
___
##### Method 1

1: Adding suid mode to */sbin/shutdown*

By adding suid mode to shutdown command, you are allowing regular user to run shutdown command as **root**.
```bash
sudo chmod u+s /sbin/shutdown
```
Check out examples of chmod here.
Now you can run shutdown without needing **sudo**.
___
##### Method 2

2: Modify **/etc/sudoers** with **visudo**

This seems to be proper way to allow a command to run as root from specified users without needing to type **password**.

```bash
sudo visudo
```

By running visudo, it leads to edit **/etc/sudoers**.
Adding the line below to that file, assume mysurface is the user that allow to **shutdown** without **password**.
```bash
mysurface ALL = NOPASSWD: /sbin/shutdown
```
For ubuntu, usually the default user is in the **%admin group**. Therefore, you can also allow all users from the **%admin** group to shutdown without password.
```bash
%admin ALL = NOPASSWD: /sbin/shutdown
```

In fact, you still need **sudo to shutdown**, but this time you do not need to specified **password**.
```bash
sudo shutdown -h now
```
You can also **reboot** the system by using **shutdown** command too.
```bash
sudo shutdown -r now
```
