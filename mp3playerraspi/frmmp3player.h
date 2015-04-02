#ifndef FRMMP3PLAYER_H
#define FRMMP3PLAYER_H

#include <QWidget>
#include <mp3admin.h>
#include <qdebug.h>
namespace Ui {
class frmmp3player;
}

class frmmp3player : public QWidget
{
    Q_OBJECT

public:
    explicit frmmp3player(QWidget *parent = 0);
    ~frmmp3player();

private slots:
    void on_btnPlay_clicked();

    void on_btnStop_clicked();

    void on_btnpause_clicked();
    void onPositionTracking(float percentage);
    void onPlayerStatus(int statuscode);

private:
    Ui::frmmp3player *ui;
    mp3Admin *_mp3Admin ;

};

#endif // FRMMP3PLAYER_H
