#ifndef MP3ADMIN_H
#define MP3ADMIN_H
#include <QString>
#include <gst/gst.h>
#include <glib.h>
#include <QVector>
#include <QFileDialog>
#include <gst/gst.h>
#include <glib.h>
#include <QDebug>
#include <QTimer>

#include <QObject>
class mp3Admin: public QObject
{
    Q_OBJECT
public:
    static bool _play;
    explicit mp3Admin(QObject *parent = 0);

    void playLocal(QString actualSongPath);
    bool getPlayFlag();
    void setPlayFlag(bool value);
    void pauseLocalSong();
    void pauseRemoteSong(int indexPipeline);
    void stopRemoteSong(int indexPipeline, QString actualSongPath);
    void setPathList(QFileInfoList list);
    QFileInfoList getPathList();
    QString getPreviewPath(QString actualPath);
    QString getNextPath(QString actualPath);
    void playRemote(int index, QString actualSongPath, QString ip, int _portNumber);
    enum ePlayerStatus
    {
        ePlayerStatus_play=0,ePlayerStatus_stop=1,ePlayerStatus_finished=2,ePlayerStatus_pause=3
    };
private:
    QFileInfoList _pathList; //
    QVector<QString> listIP;
    QVector<int> listPorts;
    GstElement *pipelineLocal;
    QVector<GstElement**> listPipelines;
    QString getPrevOrNextPath(QString actualPath, int moveCount);
    static gboolean bus_call (GstBus *bus, GstMessage *msg, gpointer data);
    static gboolean timeout_callback(gpointer data);
    QTimer* _timerTracking;
private slots:
    void timeout_timerTracking();

signals:
    void PositionTracking(float percentage);
     void PlayerStatus(int statuscode);

};

#endif // MP3ADMIN_H
