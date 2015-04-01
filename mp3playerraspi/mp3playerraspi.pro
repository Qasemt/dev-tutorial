#-------------------------------------------------
#
# Project created by QtCreator 2013-10-07T23:18:56
#
#-------------------------------------------------

QT       += core gui

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

target.files  = mp3player
target.path   = /root
INSTALLS      = target

TARGET = mp3player
TEMPLATE = app

CONFIG += link_pkgconfig
PKGCONFIG += gstreamer-0.10

#DEFINES += PROJECT_PATH=\"\\\"$$PWD\\\"\"

SOURCES += main.cpp\
        mainwindow.cpp \
    mp3admin.cpp \
    frmplayer.cpp

HEADERS  += mainwindow.h \
    mp3admin.h \
    frmplayer.h

FORMS    += mainwindow.ui \
    frmplayer.ui
