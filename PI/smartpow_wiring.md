

##### Relay pin :
___
Pi - GPIO | Relay pin
--- | ---
17 | inp1
27 | inp2
22 | inp3
23 | inp4
4 (5v) | Relay VCC
20 (GND) | GND



***put Jumper on Relay Board ( JVCC  & VCC)***


##### LCD 1602 :
___
**PI - Pin 2 (5v) ------ VCC LCD**


##### Boot App :
nano ~/myprj/runapp.sh
```bash
python ~/myprj/main.py "Start App" 1 1

#cd /root/myprj/irrigationApp
cd  /root/myprj/smartpow

node server.js
#node jfLCD.js


```
