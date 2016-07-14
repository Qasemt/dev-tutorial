
#### Links 
+ [linke 1](https://tmrh20.github.io/RF24/RPi.html) <br>

__________
#### Manual Install
Make a directory to contain the RF24 and possibly RF24Network lib and enter it:
```bash
mkdir ~/rf24libs 
cd ~/rf24libs
Clone the RF24 repo:
git clone https://github.com/tmrh20/RF24.git RF24 
```

Change to the new RF24 directory
```bash
cd RF24 
Build the library, and run an example file:
sudo make install
cd examples_RPi  
make  
sudo ./gettingstarted
```
