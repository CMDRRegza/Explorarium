#include "loadingscreenmanager.h"
#include <QDebug>
#include <QTimer>

LoadingScreenManager::LoadingScreenManager(QObject *parent)
    : QObject{parent}
{
    qInfo() << this << "Constructed";
}

void LoadingScreenManager::supabaseClientCompleted()
{
    this->m_done++;
    this->isDone();
    qInfo() << "yes2";
}

void LoadingScreenManager::isDone()
{
    if(this->m_done == this->m_bayNum) {
        qInfo() << this << "Loading complete";
        emit loadApp();
    }
}
