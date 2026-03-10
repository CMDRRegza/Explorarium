#include "spanshplotter.h"
#include "spanshdbtask.h"
#include <QDebug>
#include "routetask.h"
#include <QThreadPool>
#include <QJsonObject>
#include <QDate>

SpanshPlotter::SpanshPlotter(QObject *parent)
    : QObject{parent}
{}

void SpanshPlotter::GenerateRoute(QString source, QString dest, int cargo, int fuel, bool alr,
                                  bool neutron, bool injections, bool secondary, bool refuel, QString view, QJsonObject shipbuild)
{
    view = view.toLower().replace(" ", "-");
    qInfo() << "Generating route";
    QVariantMap params;
    params["cargo"] = cargo;
    params["fuel"] = fuel;
    params["alr"] = alr;
    params["neutron"] = neutron;
    params["injections"] = injections;
    params["secondary"] = secondary;
    params["refuel"] = refuel;
    params["view"] = view;

    RouteTask *task = new RouteTask(this,
                                    source,
                                    dest,
                                    shipbuild,
                                    params, m_shipData);
    QThreadPool::globalInstance()->start(task);
}

void SpanshPlotter::clearRoute()
{
    m_route.clear();
    emit routeChanged();
}

void SpanshPlotter::GrabSystemData(QString systemName)
{
    if(systemName.isEmpty()) return;
    qInfo() << "Asking spansh";
    SpanshDBTask *task = new SpanshDBTask(this, "", "systemMap", systemName);
    QThreadPool::globalInstance()->start(task);
}

void SpanshPlotter::error(QString operation, QString title, QString error)
{
    qInfo() << operation << title << error;
    emit fatal(operation, title, error);
}

void SpanshPlotter::loadingbaydataplease(QJsonArray data)
{
    qInfo() << "Got yummy data thx plssss hehehehe hshahhahe ezezeze LETS GOOO";
    m_shipData = data;
}

void SpanshPlotter::gotSpanshReply(QByteArray data)
{
    QJsonParseError err;
    QJsonDocument doc = QJsonDocument::fromJson(data, &err);
    if (err.error != QJsonParseError::NoError) {
        qWarning() << "Invalid JSON:" << err.errorString();
        return;
    }

    QJsonObject root = doc.object();
    QJsonObject result = root["result"].toObject();
    QJsonArray jumps = result["jumps"].toArray();
    QVariantList model;
    for(int i = 0; i < jumps.size(); i++) {
        QJsonObject system = jumps[i].toObject();
        QVariantMap map = system.toVariantMap();
        model.append(map);
    }
    m_route = model;
    qInfo() << "Plot Complete fully!!";
    emit routeChanged();
    emit generatedRoute();
}

void SpanshPlotter::gotTargetEvent(QString id64, QString systemName)
{
    qInfo() << "Signals and slots okay";
    if(id64.isEmpty() || id64.isNull()) return;
    m_systemName = systemName;
    qInfo() << "Asking spansh";

    SpanshDBTask *task = new SpanshDBTask(this,
                                          id64, "system" , m_systemName);
    QThreadPool::globalInstance()->start(task);

    SpanshDBTask *othertask = new SpanshDBTask(this,
                                               "", "edsm" , m_systemName);
    QThreadPool::globalInstance()->start(othertask);
}

void SpanshPlotter::targetLoadingBay(QVariantMap data)
{
    QVariantMap myPackage;
    if(data.isEmpty()) return;
    if(data["id"].toString().toLower() == "spansh") {
        m_spanshDone = true;
        if(data.contains("error")) {
            QString errorCode = data["error"].toString();
            if(errorCode.toLower().contains("could not find")) {
                myPackage["description"] = QString("%1 is not in Spansh").arg(m_systemName);
                myPackage["name"] = m_systemName;
                myPackage["timestamp"] = "hidethispls";
                myPackage["body_count"] = "";
                spanshEdsmPackage["spansh"] = myPackage;
                if(m_spanshDone && m_edsmDone) {
                    combine();
                }
                return;
            }
        }
        QString name = data["name"].toString();
        QString rawTimestamp = data["updated_at"].toString();
        QString full_body_count = data["full_body_count"].toString();
        int body_count = data["body_count"].toInt();

        QDateTime dt = QDateTime::fromString(rawTimestamp, "yyyy-MM-dd HH:mm:ss+z");
        QString timestamp = "Unknown Date";
        if(dt.isValid()) {
            timestamp = dt.date().toString("yyyy-MM-dd");
        } else {
            if(rawTimestamp.toLower() != "unknown date") {
                timestamp = rawTimestamp.left(10);
            }
        }

        QString bodyCnt = QString("(%1/%2)").arg(body_count).arg(full_body_count);
        QString description = QString("%1 is present in Spansh.").arg(name);

        myPackage["name"] = name;
        myPackage["timestamp"] = timestamp;
        myPackage["body_count"] = bodyCnt;
        myPackage["description"] = description;

        spanshEdsmPackage["spansh"] = myPackage;

        m_spanshDone = true;

        if(m_spanshDone && m_edsmDone) {
            combine();
            return;
        }
    } else if(data["id"].toString().toLower() == "edsm") {
        m_edsmDone = true;
        if(data.contains("error")) {
            QString errorCode = data["error"].toString();
            if(errorCode.toLower().contains("empty")) {
                myPackage["description"] = QString("%1 is not in EDSM").arg(m_systemName);
                myPackage["name"] = m_systemName;
                myPackage["timestamp"] = "hidethispls";
                myPackage["body_count"] = "";
                myPackage["commander"] = "";
                spanshEdsmPackage["edsm"] = myPackage;
                if(m_spanshDone && m_edsmDone) {
                    combine();
                }
                return;
            }
        }

        QString name = data["name"].toString();
        QString fullbodycount = data["fullbodycount"].toString();
        int bodycount = data["bodycount"].toInt();
        QString commander = data["commander"].toString();
        QString rawTimestamp = data["date"].toString();

        QDateTime dt = QDateTime::fromString(rawTimestamp, "yyyy-MM-dd HH:mm:ss+z");
        QString timestamp = "Unknown Date";
        if(dt.isValid()) {
            timestamp = dt.date().toString("yyyy-MM-dd");
        } else {
            if(rawTimestamp.toLower() != "unknown date") {
                timestamp = rawTimestamp.left(10);
            }
        }
        QString bodyCnt = QString("(%1/%2)").arg(bodycount).arg(fullbodycount);
        QString description = QString("%1 is present in EDSM.").arg(name);

        myPackage["name"] = name;
        myPackage["timestamp"] = timestamp;
        myPackage["body_count"] = bodyCnt;
        myPackage["description"] = description;
        myPackage["commander"] = commander;

        spanshEdsmPackage["edsm"] = myPackage;

        m_edsmDone = true;
        if(m_spanshDone && m_edsmDone) {
            combine();
            return;
        }
    }
}

void SpanshPlotter::combine()
{
    m_spanshDone = false;
    m_edsmDone = false;

    if (!spanshEdsmPackage.isEmpty()) {
        emit showWindow(spanshEdsmPackage);
    }

    spanshEdsmPackage = QVariantMap();
}
