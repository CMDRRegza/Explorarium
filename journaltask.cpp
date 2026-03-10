#include "journaltask.h"
#include <QDebug>
#include <QThread>
#include <QDir>
#include <QStandardPaths>
#include <QFileInfo>
#include <QStringList>
#include <QFile>
#include <QTextStream>
#include <QJsonDocument>
#include <QJsonObject>
#include <QVariantMap>
#include <QJsonArray>
#include <QXmlStreamReader>

JournalTask::JournalTask(JournalManager *manager, QString currentFile, qint64 filePosition, QVariantMap params)
{
    qInfo() << this << "Constructed";
    m_manager = manager;
    m_params = params;
    m_currentFile = currentFile;
    m_filePosition = filePosition;
    setAutoDelete(true);
}

void JournalTask::run() {
    qInfo() << this << "Running on: " << QThread::currentThread();
    if(!m_params.isEmpty()) {
        qInfo() << "Grabbing new display value";
        int num = displayValue();
        QMetaObject::invokeMethod(m_manager, "onDisplayValueLoaded",
                                  Qt::QueuedConnection, Q_ARG(int, num));
        return;
    }
    QVariantMap locationName = this->ReadJournalData();
    QMetaObject::invokeMethod(m_manager, "onJournalDataLoaded",
                                Qt::QueuedConnection, Q_ARG(QVariantMap, locationName));
}

QVariantMap JournalTask::ReadJournalData()
{
    QVariantMap result;
    QString latestFile = m_currentFile;
    QFile file(latestFile);
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        file.seek(m_filePosition);
        QTextStream in(&file);
        QString fileContent = in.readAll();
        QStringList lines = fileContent.split("\n");

        for(int i = 0; i < lines.size(); ++i) {
            QString line = lines[i];
            if (line.isEmpty()) continue;
            QJsonDocument doc = QJsonDocument::fromJson(line.toUtf8());
            if(!doc.isNull() && doc.isObject()) {
                QJsonObject obj = doc.object();
                if(obj["event"].toString() == "Commander") {
                    result["cmdrName"] = obj["Name"].toString();
                    qInfo() << "Found name!" << result["cmdrName"];
                    break;
                }
            }
        }

        for(int i = 0; i < lines.size(); ++i) {
            QString line = lines[i];
            if (line.isEmpty()) continue;
            QJsonDocument doc = QJsonDocument::fromJson(line.toUtf8());
            if(!doc.isNull() && doc.isObject()) {
                QJsonObject obj = doc.object();
                if(obj["event"].toString() == "FSDTarget") {
                    obj.remove("timestamp");
                    result["target"] = obj;
                    qInfo() << "Found target!" << result["target"];
                    break;
                }
            }
        }

        for(int i = lines.size() - 1; i >= 0; --i) {
            QString line = lines[i];
            if (line.isEmpty()) continue;
            QJsonDocument doc = QJsonDocument::fromJson(line.toUtf8());
            if(!doc.isNull() && doc.isObject()) {
                QJsonObject obj = doc.object();
                if(obj["event"].toString() == "Loadout") {
                    obj.remove("timestamp");
                    result["shipbuild"] = obj;
                    qInfo() << "Found build!" << result["shipbuild"];
                    break;
                }
            }
        }

        for(int i = lines.size() - 1; i >= 0; --i) {
            QString line = lines[i];
            if (line.isEmpty()) continue;
            QJsonDocument doc = QJsonDocument::fromJson(line.toUtf8());
            if(!doc.isNull() && doc.isObject()) {
                QJsonObject obj = doc.object();
                if(obj["event"].toString() == "FSDJump"
                    || obj["event"].toString() == "Location"
                    || obj["event"].toString() == "CarrierJump") {
                    result["location"] = obj["StarSystem"].toString();
                    QJsonArray pos = obj["StarPos"].toArray();
                    result["x"] = pos[0].toDouble();
                    result["y"] = pos[1].toDouble();
                    result["z"] = pos[2].toDouble();
                    qInfo() << "Found location!" << result["location"];
                    break;
                }
            }
        }

        result["pos"] = file.pos();
        file.close();
    }
    bool missingCmdr = !result.contains("cmdrName");
    bool missingShip = !result.contains("shipbuild");
    bool missingLoc = !result.contains("location");
    if (missingCmdr || missingShip || missingLoc) {
        qInfo() << "Missing Info! Running search to find proper data.";
        QFileInfo currentInfo(m_currentFile);
        QDir dir = currentInfo.absoluteDir();
        QFileInfoList files = dir.entryInfoList(QStringList() << "Journal.*.log", QDir::Files, QDir::Time);

        for(int i = 0; i < files.size(); ++i) {
            if (!missingCmdr && !missingShip && !missingLoc) break;
            QFileInfo info = files[i];
            QString path = info.absoluteFilePath();
            if (path == m_currentFile) continue;

            QFile journalFile(path);
            if(journalFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
                QTextStream journalIn(&journalFile);
                QString content = journalIn.readAll();
                QStringList lines = content.split("\n");

                if(missingCmdr) {
                    for(int i = 0; i < lines.size(); ++i) {
                        QString line = lines[i];
                        if (line.isEmpty()) continue;
                        QJsonDocument doc = QJsonDocument::fromJson(line.toUtf8());
                        if(!doc.isNull() && doc.isObject()) {
                            QJsonObject obj = doc.object();
                            if(obj["event"].toString() == "Commander") {
                                result["cmdrName"] = obj["Name"].toString();
                                missingCmdr = false;
                                qInfo() << "Found name!" << result["cmdrName"];
                                break;
                            }
                        }
                    }
                }

                if(missingLoc) {
                    for(int i = lines.size() - 1; i >= 0; --i) {
                        QString line = lines[i];
                        if (line.isEmpty()) continue;
                        QJsonDocument doc = QJsonDocument::fromJson(line.toUtf8());
                        if(!doc.isNull() && doc.isObject()) {
                            QJsonObject obj = doc.object();
                            if(obj["event"].toString() == "FSDJump"
                                || obj["event"].toString() == "Location"
                                || obj["event"].toString() == "CarrierJump") {
                                result["location"] = obj["StarSystem"].toString();
                                QJsonArray pos = obj["StarPos"].toArray();
                                result["x"] = pos[0].toDouble();
                                result["y"] = pos[1].toDouble();
                                result["z"] = pos[2].toDouble();
                                missingLoc = false;
                                qInfo() << "Found location!" << result["location"];
                                break;
                            }
                        }
                    }
                }

                if(missingShip) {
                    for(int i = lines.size() - 1; i >= 0; --i) {
                        QString line = lines[i];
                        if (line.isEmpty()) continue;
                        QJsonDocument doc = QJsonDocument::fromJson(line.toUtf8());
                        if(!doc.isNull() && doc.isObject()) {
                            QJsonObject obj = doc.object();
                            if(obj["event"].toString() == "Loadout") {
                                obj.remove("timestamp");
                                result["shipbuild"] = obj;
                                missingShip = false;
                                qInfo() << "Found build!" << result["shipbuild"];
                                break;
                            }
                        }
                    }
                }

                journalFile.close();
            }
        }
    }

    return result;
}

int JournalTask::displayValue()
{
    int displayValue = -1;
    QFile file = QFile(m_currentFile);
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QXmlStreamReader xml(&file);
        while (!xml.atEnd() && !xml.hasError()) {
            xml.readNext();
            if(xml.isStartElement()) {
                if (xml.name().compare(u"FullScreen") == 0) {
                    displayValue = xml.readElementText().toInt();
                    break;
                }
            }
        }
        file.close();
    }
    return displayValue;
}

