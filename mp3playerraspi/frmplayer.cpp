#include "frmplayer.h"
#include "ui_frmplayer.h"

FrmPlayer::FrmPlayer(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::FrmPlayer)
{
    ui->setupUi(this);
}

FrmPlayer::~FrmPlayer()
{
    delete ui;
}
