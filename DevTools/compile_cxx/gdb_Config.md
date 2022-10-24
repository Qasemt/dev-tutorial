#### install on the target if not installed
```bash
apt-get install gdbserver
```



#### Step 1

install on the host computer
```bash
sudo apt-get install gdb-multiarch
```

#### Step 2
```bash
qtcreator ->Build&Run -> Debubggers 
name = cross-GDB 
path = /usr/bin/gdb-multiarch
```

#### Step 3
```bash
qtcreator ->Devices  ->select device (BBB) -> GDB server exexcutable : [gdbserver]
```

#### Step 4

```bash
Build&Run->Kits->Sysroot =>/home/qasem/Development/[cubie2]/sysroot/
```
___
#### gdb config for 32 bit desktop
error after run with debug mod =   &"warning: GDB: Failed to set controlling terminal: Invalid argument\n"

###### Solution  1 :

**first install requirment:**
```bash
 sudo apt-get install python2.7
```

I also upgraded gdb to latest 7.9: I installed libncurses5-dev package: **sudo apt-get install libncurses5-dev** , which is needed to build gdb.
I downloaded latest gz archive from **http://ftp.gnu.org/gnu/gdb** to the temporary folder, and executed the following commands:

```bash
tar xvfz gdb-*.gz
cd gdb*
./configure --prefix /usr/local/bin/gdb-python2 --with-python
make
make install
```
###### Solution  2 :
agar bar tarf nashod man ba in ravesh javab gerftam (albate roy laptop)
```bash
apt-get remove gdb 
apt-get install gdb
agar baz error dad 
```
version QT creator ra avaz konid ke man be 3.4.0 ertegha dadam
