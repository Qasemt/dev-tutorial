##### Boot App :

nano ~/myprj/runapp.sh
```bash
python ~/myprj/main.py "Start App" 1 1

#cd /root/myprj/irrigationApp
cd  /root/myprj/smartpow

node server.js
#node jfLCD.js
```
sudo nano /etc/init.d/myboot
```bash
su root -c '/root/myprj/runapp.sh 
```
