#ifndef FRMPLAYER_H
#define FRMPLAYER_H

#include <QWidget>

namespace Ui {
class FrmPlayer;
}

class FrmPlayer : public QWidget
{
    Q_OBJECT

public:
    explicit FrmPlayer(QWidget *parent = 0);
    ~FrmPlayer();

private:
    Ui::FrmPlayer *ui;
};

#endif // FRMPLAYER_H
