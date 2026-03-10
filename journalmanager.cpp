#include "journalmanager.h"
#include "journaltask.h"
#include <QDebug>
#include <QThreadPool>
#include <QFileSystemWatcher>
#include <QDir>
#include <QVariantMap>
#include <QSettings>
#include <QApplication>
#include <QTimer>
#include <QJsonObject>

JournalManager::JournalManager(QObject *parent)
    : QObject{parent}
{
    qInfo() << this << "Constructed";

    QSettings settings(QApplication::organizationName(), QApplication::applicationName());
    m_journalPath = settings.value("journalPath", m_journalPath).toString();
    if(m_journalPath.isEmpty() || m_journalPath.isNull()) {
        m_journalPath = QDir::homePath() + "/Saved Games/Frontier Developments/Elite Dangerous/";
    }
    m_commanderName = settings.value("cmdrName", "Unknown").toString();
    m_shipbuild = settings.value("shipbuild", "Unknown").toJsonObject();
    m_location = settings.value("location", "Unknown").toString();
    m_displayValue = settings.value("display", -1).toInt();
    QVariantList coordsVar = settings.value("coordinates", QVariantList()).toList();

    m_displayWatcher = new QFileSystemWatcher(this);
    m_displayWatcher->addPath(m_displayPath);
    connect(m_displayWatcher, &QFileSystemWatcher::fileChanged, this,  &JournalManager::onChangedDisplayFile);

    m_watcher = new QFileSystemWatcher(this);
    m_watcher->addPath(m_journalPath);
    connect(m_watcher, &QFileSystemWatcher::directoryChanged, this, &JournalManager::onNewFile);
    connect(m_watcher, &QFileSystemWatcher::fileChanged, this, &JournalManager::onJournalUpdate);

    qInfo() << coordsVar;
    m_coordinates.clear();
    for (int i = 0; i < coordsVar.size(); ++i) {
        m_coordinates.append(coordsVar[i].toDouble());
    }
    m_debounceTimer = new QTimer(this);
    m_debounceTimer->setSingleShot(true);
    m_debounceTimer->setInterval(200);
    connect(m_debounceTimer, &QTimer::timeout, this, &JournalManager::contactJournalData);

    onNewFile();
    onChangedDisplayFile();
}

QString JournalManager::findLatestJournal()
{
    QDir dir(m_journalPath);
    QFileInfoList files = dir.entryInfoList(QStringList() << "Journal.*.log", QDir::Files, QDir::Time);
    if (!files.isEmpty()) {
        return files.first().absoluteFilePath();
    }
    return QString();
}

void JournalManager::onNewFile()
{
    QString oldfile = m_currentJournalFile;
    QString newfile = findLatestJournal();

    if(newfile != oldfile) {
        if (!oldfile.isEmpty()) {
            m_watcher->removePath(oldfile);
        }
        m_watcher->addPath(newfile);
        m_currentJournalFile = newfile;
        m_fileposition = 0;

        m_debounceTimer->start();
    }
}

void JournalManager::onChangedDisplayFile()
{
    if (!QFile::exists(m_displayPath)) return;

    QVariantMap info;
    info["display"] = true;
    JournalTask *task = new JournalTask(this, m_displayPath, 0, info);
    QThreadPool::globalInstance()->start(task);
}

void JournalManager::onJournalUpdate()
{
    m_debounceTimer->start();
}

void JournalManager::onDisplayValueLoaded(const int value)
{
    QSettings settings(QApplication::organizationName(), QApplication::applicationName());
    settings.setValue("display", value);
    m_displayValue = value;
    emit displayValueChanged();
    qInfo() << "found new value";
}

void JournalManager::contactJournalData()
{
    JournalTask *task = new JournalTask(this, m_currentJournalFile, m_fileposition, QVariantMap());
    QThreadPool::globalInstance()->start(task);
}

void JournalManager::onJournalDataLoaded(const QVariantMap &data)
{
    QSettings settings(QApplication::organizationName(), QApplication::applicationName());
    if (data.contains("cmdrName")) {
        QString name = data["cmdrName"].toString();
        if (!name.isEmpty()) {
            m_commanderName = name;
            settings.setValue("cmdrName", name);
            qInfo() << "Retrieved name" << name;
            emit CmdrChanged();
            emit loadingComplete();
        }
    }

    if(data.contains("target")) {
        QJsonObject targetObj = data.value("target").toJsonObject();
        if(m_windowPopupFirst) {
            QString id64 = QString::number(targetObj.value("SystemAddress").toVariant().toLongLong());
            QString systemName = targetObj.value("Name").toString();
            emit targetEvent(id64, systemName);
        } else {
            m_windowPopupFirst = true;
        }
    }

    if(data.contains("shipbuild")) {
        QJsonObject shipObj = data.value("shipbuild").toJsonObject();
        m_shipbuild = shipObj;
        settings.setValue("shipbuild", m_shipbuild);
    }

    if (data.contains("location")) {
        m_location = data["location"].toString();
        settings.setValue("location", m_location);
        m_coordinates.clear();
        m_coordinates.append(data["x"].toDouble());
        m_coordinates.append(data["y"].toDouble());
        m_coordinates.append(data["z"].toDouble());
        QVariantList coordsVar;
        for (int i = 0; i < m_coordinates.size(); ++i) {
            coordsVar.append(m_coordinates[i]);
        }
        settings.setValue("coordinates", coordsVar);
        qInfo() << "Retrieved location" << m_location << m_coordinates;
        emit locationChanged();
    }

    if(data.contains("pos")) {
        m_fileposition = data["pos"].toLongLong();
    }
}

QString JournalManager::commanderName()
{
    return m_commanderName;
}

QString JournalManager::location()
{
    return m_location;
}

void JournalManager::setJournalPath(QString path)
{
    if(path.isEmpty() || path.isNull()) return;
    if(path == m_journalPath) {qInfo() << "Same journal Path"; return;}
    QSettings settings(QApplication::organizationName(), QApplication::applicationName());
    QDir dir(path);
    if(dir.exists()) {
        m_watcher->removePath(m_journalPath);
        m_watcher->addPath(path);
        m_journalPath = path;
        settings.setValue("journalPath", path);

        if(!m_currentJournalFile.isEmpty()) {
            m_watcher->removePath(m_currentJournalFile);
            m_currentJournalFile = QString();
        }

        emit journalPathChanged();

        onNewFile();
    } else {
        qWarning() << "Path doesn't exist! Aborting change";
        return;
    }
}




