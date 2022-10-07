### REF
* [GParted iso very easy :+1:](https://www.pragmaticlinux.com/2020/09/how-to-increase-the-disk-size-in-a-virtualbox-virtual-machine/)
* [CLI Very hard ](https://support.binarylane.com.au/support/solutions/articles/11000015259-how-to-expand-storage-dev-vda1-so-it-takes-up-the-entire-disk)


---
lsblk -p | grep "disk"
```
 /dev/sda      8:0    0  800M  0 disk
```
lsblk -p | grep "part"
 ```
├─/dev/sda1   8:1    0  100M  0 part /boot
├─/dev/sda2   8:2    0  128M  0 part [SWAP]
└─/dev/sda3   8:3    0  283M  0 part /
 ```
