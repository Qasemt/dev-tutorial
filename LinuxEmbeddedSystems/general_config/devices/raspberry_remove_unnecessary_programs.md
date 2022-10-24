### remove unnecessary programs raspberry pi
* src :https://medium.com/@sean_t_king/how-to-remove-un-necessary-software-from-your-raspberry-pi-server-fa312f83e00
Type the following in the terminal:
```
sudo cp /etc/network/interfaces /etc/network/interfaces.bak
wget https://gist.githubusercontent.com/samatjain/4dda24e14a5b73481e2a/raw/5d9bac8ec40b94833b4e9938121945be252fdee1/Slim-Raspbian.sh -O Slim-Raspbian.sh
sh ./Slim-Raspbian.sh | sudo sh
```


```
sudo apt-get remove --purge libreoffice*
sudo apt-get clean
sudo apt-get autoremove
```
