
```bash
#unix:!macx: LIBS += -L"/opt/gdal-linux32/lib" -lproj

#INCLUDEPATH += /opt/gdal-linux32/include
#DEPENDPATH += /opt/gdal-linux32/include


#INCLUDEPATH +=/opt/gdal-linux32/include
#DEPENDPATH +=/opt/gdal-linux32/include
#unix:!macx: LIBS += /opt/gdal-linux32/lib/libgdal.a

#unix:!macx: PRE_TARGETDEPS += /opt/gdal-linux32/lib/libgdal.a

------------------------------------------

unix:!macx: LIBS += -L"/usr/local/Trolltech/geo123/lib" -lproj

INCLUDEPATH += /usr/local/Trolltech/geo123/include
DEPENDPATH += /usr/local/Trolltech/geo123/include


unix:!macx: LIBS += /usr/local/Trolltech/geo123/lib/libgdal.a

INCLUDEPATH += /usr/local/Trolltech/geo123/include
DEPENDPATH += /usr/local/Trolltech/geo123/include

unix:!macx: PRE_TARGETDEPS += /usr/local/Trolltech/geo123/lib/libgdal.a


///////////////////
vtlCommonData.DEPENDPATH  =commoncodes
gisUnit.DEPENDPATH = commoncodes moduleGPS
ModuleCom.DEPENDPATH= commoncodes moduleFD
vtlcore.DEPENDPATH = commoncodes vtlCommonData moduleDAL gisUnit stDetector moduleGPS moduleController moduleFD ModuleCom


sudo ln -s /usr/local/Trolltech/geo123/lib/libproj.so.0.7.0 /usr/local/Trolltech/geo123/lib/libproj.so.0


scp -d -r  /usr/local/Trolltech/geo123 root@192.168.1.56:/usr/local/Trolltech/geo123

scp Development/BeagleBone/sysroot/lib/libffi.* root@192.168.1.56:/usr/lib/
```
