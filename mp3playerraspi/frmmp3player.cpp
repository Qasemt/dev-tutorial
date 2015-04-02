#include "frmmp3player.h"
#include "ui_frmmp3player.h"

frmmp3player::frmmp3player(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::frmmp3player)
{
    ui->setupUi(this);
     system("amixer sset 'PCM' 0");
     _mp3Admin =new mp3Admin();
}

frmmp3player::~frmmp3player()
{
    delete ui;
}

void frmmp3player::on_btnPlay_clicked()
{
    _mp3Admin->setPlayFlag(true);
    _mp3Admin->playLocal("/home/pi/1.mp3");
    qDebug()<<"play";
}

void frmmp3player::on_btnStop_clicked()
{
    _mp3Admin->setPlayFlag(false);
     qDebug()<<"stop";
}
