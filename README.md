# mp3-player-raspi-gstreamer

./program -qws -display VNC::size=640x480:depth=32:3




http://wiki.laptop.org/go/Fluendo_mp3_decoder
^^^^^^^^^^^^^^^^^^^^

sudo apt-get update 
sudo apt-get install gstreamer1.0
^^^^^^^^^^^^^^^^^^^^

baray neshan dadan  codec va feature hay gstreamer
gst-inspect flump3dec


^^^^^^^^^^^^^^^^^^^^Test gstreamer^^^^^^^^^^^^^^^^^^^^

gst-launch-0.10 playbin uri=file:///home/pi/1.mp3
aplay /usr/share/sounds/alsa/Front_Center.wav


sound card info
amixer 



scp -r /home/qasem/Development/BeagleBone/sysroot root@192.168.1.56:~/sysroot


ssh root@192.168.1.56

# mkdir -p /usr/local/Trolltech/Qt-4.8.6-beaglebone
# exit

scp -r /usr/local/Trolltech/Qt-4.8.6-beaglebone/lib/ root@192.168.1.56:/usr/local/Trolltech/Qt-4.8.6-beaglebone
scp -r /usr/local/Trolltech/Qt-4.8.6-beaglebone/plugins/ root@ 192.168.1.56:/usr/local/Trolltech/Qt-4.8.6-beaglebone
