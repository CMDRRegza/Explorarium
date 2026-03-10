#ifndef JOURNALTASK_H
#define JOURNALTASK_H

#include "journalmanager.h"
#include <QRunnable>
#include <QDebug>

class JournalTask : public QRunnable
{
public:
    JournalTask(JournalManager *manager, QString currentFile, qint64 filePosition, QVariantMap params);
    ~JournalTask() { qInfo() << this << "Destroyed"; }
    void run() override;
private:
    JournalManager *m_manager;
    QVariantMap m_params;
    QVariantMap ReadJournalData();
    int displayValue();
    QString m_currentFile;
    qint64 m_filePosition;
};

#endif // JOURNALTASK_H
