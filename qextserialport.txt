#### Source :

git clone https://github.com/qextserialport/qextserialport.git
####or 

git clone https://github.com/Qasemt/qextserialport.git
```bash
mkdir qextserialport-build
cd qextserialport-build
/opt/qt4.8.6/bin/qmake ../qextserialport/qextserialport.pro
make -j4
sudo make install
```

#### BBB
```bash
/usr/local/Trolltech/Qt-4.8.6-beaglebone/bin/qmake ../qextserialport/qextserialport.pro
```
