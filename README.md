# Dev Tutorial
````bash
mp3-player-raspi-gstreamer
./program -qws -display VNC::size=640x480:depth=32:3

````


http://wiki.laptop.org/go/Fluendo_mp3_decoder

````bash
sudo apt-get update 
sudo apt-get install gstreamer1.0


baray neshan dadan  codec va feature hay gstreamer
gst-inspect flump3dec


Test gstreamer

gst-launch-0.10 playbin uri=file:///home/pi/1.mp3
aplay /usr/share/sounds/alsa/Front_Center.wav


sound card info
amixer 

````
![alt text](http://beagleboard.org/static/images/black_hardware_details.png "BBB")

![alt text](http://beagleboard.org/static/images/cape-headers.png "Pin Out")

### Author:

* Qasem Taheri: taaheri2@gmail.com


### License:
 [The MIT License (MIT)](http://opensource.org/licenses/MIT)


