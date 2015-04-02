#include <QApplication>
#include "mainwindow.h"
#include <frmmp3player.h>
int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    frmmp3player w;
    //MainWindow w;
    w.show();
    
    return a.exec();
}
