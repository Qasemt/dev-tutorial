##### Source : 
* http://stackoverflow.com/questions/24912778/qtcreator-kit-specific-precompiler-macro-definitions


___
```bash
CONFIG(debug, debug|release): DEFINES += _debug
CONFIG(debug, debug|release): DEFINES += _release
CONFIG(cubie2, desktoplinux4|cubie2): DEFINES += PLATFORM_CUBIE2
CONFIG(desktoplinux4, desktoplinux4|cubie2): DEFINES += PLATFORM_DESKTOPLINUX4


#ifdef PLATFORM_DESKTOPLINUX4
unix:!macx: LIBS +=-L"/opt/gdal-linux32/lib/" -lproj
unix:!macx: LIBS += /opt/gdal-linux32/lib/libgdal.a
unix:!macx: PRE_TARGETDEPS += /opt/gdal-linux32/lib/libgdal.a
#endif

#ifdef PLATFORM_CUBIE2
unix:!macx: LIBS += -L"/usr/local/Trolltech/g123cubie2/lib/" -lproj
unix:!macx: LIBS += /usr/local/Trolltech/g123cubie2/lib/libgdal.a
unix:!macx: PRE_TARGETDEPS += /usr/local/Trolltech/g123cubie2/lib/libgdal.a
#endif
```

##### Run Qt From VNC in Frame Buffer Mode 
```bash
./program -qws -display VNC::size=640x480:depth=32:3
```
