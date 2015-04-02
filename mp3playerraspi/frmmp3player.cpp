#include "frmmp3player.h"
#include "ui_frmmp3player.h"

frmmp3player::frmmp3player(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::frmmp3player)
{
    ui->setupUi(this);
    system("amixer sset 'PCM' 0");
    _mp3Admin =new mp3Admin();
    connect(_mp3Admin,SIGNAL(PositionTracking(float)),this,SLOT(onPositionTracking(float)));
    connect(_mp3Admin,SIGNAL(PlayerStatus(int)),this,SLOT(onPlayerStatus(int)));


}

frmmp3player::~frmmp3player()
{
    delete _mp3Admin;
    delete ui;

}

void frmmp3player::on_btnPlay_clicked()
{
    _mp3Admin->setPlayFlag(true);
    _mp3Admin->playLocal(ui->txtpath->text());
    qDebug()<<"play";
}

void frmmp3player::on_btnStop_clicked()
{
    _mp3Admin->setPlayFlag(false);
    qDebug()<<"stop";
}

void frmmp3player::on_btnpause_clicked()
{

    _mp3Admin->pauseLocalSong();
}

void frmmp3player::onPositionTracking(float percentage)
{
    qDebug()<<"prec :"<<percentage;
    ui->progressBar->setValue(percentage);
}

void frmmp3player::onPlayerStatus(int statuscode)
{
    // ePlayerStatus_play=0,ePlayerStatus_stop=1,ePlayerStatus_finished=2,ePlayerStatus_pause=3
    if(statuscode==0)
        ui->lblstatus->setText("play");
    else if(statuscode==1)
        ui->lblstatus->setText("stop");
    else if(statuscode==2)
        ui->lblstatus->setText("finished");
    else if(statuscode==3)
        ui->lblstatus->setText("pause");

}
