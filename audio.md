 
##### Samples :

1. wget https://cdn.shopify.com/s/files/1/0062/6682/files/sample.wav
2. wget http://www.nch.com.au/acm/sample.wav
 
 ```bash
 aplay /usr/share/sounds/alsa/Side_Right.wav
 ```

##### play mp3 file
```bash
 mplayer -ao alsa -volume 10 "/usr/local/softwares/1.mp3"
 mplayer -ao alsa:device=default=Device /usr/local/softwares/1.mp3
 ffmpeg -i /usr/local/softwares/1.mp3  -f alsa "default:CARD=Black" -re -vol 20
```
#### Note 
 agar error [[[codec audio codec family [mpg123] (afm=mpg123) not available] dad in command ro ejra kon
 source : https://linuxindetails.wordpress.com/2011/09/24/audio-codec-family-mpg123-afmmpg123-not-available/
```bash
 root@localhost:~#apt-get install libmpg123-0
 ```
 Then, enable the use of this codec within your own mplayer configuration file :
```bash
fool@localhost:~$echo "afm=mp3lib" >> ~/.mplayer/config
```

#### Driver List (sounds)
```bash
 aplay -L
```
##### out :
```bash
 speaker-test -D default:Balck (or headset)
 ```
 
 ##### source :
* http://wiki.laptop.org/go/Fluendo_mp3_decoder
 ```bash
 install alsa-utils
 apt-cache search ^gstreamer
 ```
 ```bash
=========================================== BBB ======================================
be to pish farz gstreame roy bbb nasbe faghat in 
packe gstreamer0.10-plugins-ugly baray decoder [mad] nasb kon

sudo apt-get install gstreamer0.10-plugins-ugly

****************************************************************
----for instalion cubibe (error autoaudiosink ) 
apt-get install gstreamer0.10-plugins-good 

apt-get install gstreamer0.10-tools 
-----------------optional install --------------------
apt-get install gstreamer0.10-plugins-bad 
++++++++++++++++++++++ USB Audio Config +++++++++++++++
baray inke gstream betone voice ro az usb pakhsh kone bayad
asla ro be in sorate config koni 
root@beaglebone:~# nano .asoundrc 
pcm.!default sysdefault:Device
```
