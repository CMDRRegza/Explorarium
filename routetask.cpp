#include "routetask.h"
#include "spanshplotter.h"
#include <QRunnable>
#include <QDebug>
#include <QThread>
#include <QEventLoop>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <qobjectdefs.h>
#include <QUrlQuery>
#include <QTimer>

RouteTask::RouteTask(SpanshPlotter *manager, QString sourceSystem, QString destinationSystem,
                     QJsonObject shipBuild, QVariantMap constParams, QJsonArray shipData)
{
    m_manager = manager;
    m_source = sourceSystem;
    m_destination = destinationSystem;
    m_shipBuild = shipBuild;
    m_constParams = constParams;
    m_shipData = shipData;

    setAutoDelete(true);
}

QJsonObject RouteTask::extractShipBuild(QString value)
{
    QJsonObject obj;

    for(int i = 0; i < m_shipData.size(); i++) {
        QJsonObject package = m_shipData[i].toObject();
        QString symbol = package.value("symbol").toString().toLower();
        if(symbol == value.toLower()) {
            obj = package;
            qInfo() << package << "oiii over here!";
            break;
        }
    }

    return obj;
}

double RouteTask::jsonToDouble(const QJsonValue &v, double fallback)
{
    if (v.isDouble()) {
        return v.toDouble();
    }

    if (v.isString()) {
        bool ok = false;
        double d = v.toString().trimmed().toDouble(&ok);
        return ok ? d : fallback;
    }

    return fallback;
}

double RouteTask::optimalMassGrabber()
{
    double optimalMass = 0.0;

    QJsonArray modules = m_shipBuild.value("Modules").toArray();
    for(int i = 0; i < modules.size(); i++) {
        QJsonObject slot = modules[i].toObject();
        if(slot.value("Slot").toString().toLower() == "frameshiftdrive") {
            QJsonObject engineering = slot.value("Engineering").toObject();
            qInfo() << engineering;
            QJsonArray modifiers = engineering.value("Modifiers").toArray();
            for(int j = 0; j < modifiers.size(); j++) {
                QJsonObject package = modifiers[j].toObject();
                if(package.value("Label").toString().toLower() == "fsdoptimalmass") {
                    double v = package.value("Value").toDouble();
                    optimalMass = v;
                    break;
                }
            }
        }
    }

    return optimalMass;
}

void RouteTask::run()
{
    qInfo() << "Plotter Running on: " << QThread::currentThread();
    QJsonDocument shipDoc(m_shipBuild);
    if (!shipDoc.isObject()) {
        qWarning() << "shipbuild isn't valid JSON:";
        QMetaObject::invokeMethod(m_manager, "error",
                                  Qt::QueuedConnection,
                                  Q_ARG(QString, "Journal Error"),
                                  Q_ARG(QString, "Parsing journal data"),
                                  Q_ARG(QString, "Loadout event json is corrupted."));
        return;
    }

    QJsonObject loadout = shipDoc.object();
    QJsonArray modules = loadout.value("Modules").toArray();
    QString fsdSymbol;

    double range_boost = 0.0;

    for (int i = 0; i < modules.size(); i++) {
        QJsonValue v = modules[i];
        QJsonObject m = v.toObject();
        QString item = m.value("Item").toString();

        if (m.value("Slot").toString() == "FrameShiftDrive") {
            fsdSymbol = item;
        }

        if (item.startsWith("int_guardianfsdbooster")) {
            if (item.contains("_size5")) range_boost = 10.5;
            else if (item.contains("_size4")) range_boost = 9.25;
            else if (item.contains("_size3")) range_boost = 7.75;
            else if (item.contains("_size2")) range_boost = 6.0;
            else if (item.contains("_size1")) range_boost = 4.0;
        }
    }
    loadout.remove("timestamp");
    QJsonObject ourShipData = extractShipBuild(fsdSymbol);
    if(fsdSymbol.toLower() == "int_hyperdrive_overcharge_size8_class5_overchargebooster_mkii") {
        m_superchargeMultiplier = 6;
    }
    QJsonObject tanks = loadout.value("FuelCapacity").toObject();

    QJsonObject header;
    header["appName"] = "Explorarium";
    header["appVersion"] = 1;
    header["appURL"] = "";

    QJsonObject wrapper;
    wrapper["header"] = header;
    wrapper["data"] = loadout;

    QJsonArray shipArray;
    shipArray.append(wrapper);

    QString spanshShipbuild = QString::fromUtf8(QJsonDocument(shipArray).toJson(QJsonDocument::Compact));

    // QJsonObject request;

    // request["source"] = m_source;
    // request["destination"] = m_destination;
    // request["is_supercharged"] = m_constParams["alr"].toBool();
    // request["use_supercharge"] = m_constParams["neutron"].toBool();
    // request["use_injections"] = m_constParams["injections"].toBool();
    // request["exclude_secondary"] = m_constParams["secondary"].toBool();
    // request["refuel_every_scoopable"] = m_constParams["refuel"].toBool();
    // request["fuel_power"] = ourShipData.value("fuel_power").toDouble();
    // request["fuel_multiplier"] = ourShipData.value("fuel_multiplier").toDouble();
    // request["optimal_mass"] = ourShipData.value("optimal_mass").toDouble();
    // request["base_mass"] = loadout.value("UnladenMass").toDouble();
    // request["tank_size"] = tanks.value("Main").toDouble();
    // request["internal_tank_size"] = tanks.value("Reserve").toDouble();
    // request["reserve_size"] = 0; // Unknown value/Left in testing value? this seems to always be 0 upon every request.
    // request["max_fuel_per_jump"] = ourShipData.value("max_fuel_per_jump").toDouble();
    // request["range_boost"] = range_boost;
    // request["ship_build"] = spanshShipbuild;
    // request["max_time"] = 60;
    // request["cargo"] = m_constParams["cargo"].toInt();
    // request["algorithm"] = m_constParams["view"].toString().toLower();
    // request["supercharge_multiplier"] = m_superchargeMultiplier;
    // request["injection_multiplier"] = m_injectionMultipler;

    QUrlQuery q;
    double optimalMass = optimalMassGrabber();
    double maxFuelPerJump = jsonToDouble(ourShipData.value("max_fuel_per_jump"));
    double fuelPower = jsonToDouble(ourShipData.value("fuel_power"));
    double fuelMultiplier = jsonToDouble(ourShipData.value("fuel_multiplier"));

    q.addQueryItem("source", m_source);
    q.addQueryItem("destination", m_destination);

    q.addQueryItem("is_supercharged", QString::number(m_constParams.value("alr").toBool() ? 1 : 0));
    q.addQueryItem("use_supercharge", QString::number(m_constParams.value("neutron").toBool() ? 1 : 0));
    q.addQueryItem("use_injections", QString::number(m_constParams.value("injections").toBool() ? 1 : 0));
    q.addQueryItem("exclude_secondary", QString::number(m_constParams.value("secondary").toBool() ? 1 : 0));
    q.addQueryItem("refuel_every_scoopable", QString::number(m_constParams.value("refuel").toBool() ? 1 : 0));

    q.addQueryItem("fuel_power", QString::number(fuelPower, 'g', 16));
    q.addQueryItem("fuel_multiplier", QString::number(fuelMultiplier, 'g', 16));
    q.addQueryItem("optimal_mass", QString::number(optimalMass, 'g', 16));
    q.addQueryItem("base_mass", QString::number(loadout.value("UnladenMass").toDouble(), 'g', 16));

    q.addQueryItem("tank_size", QString::number(tanks.value("Main").toDouble(), 'g', 16));
    q.addQueryItem("internal_tank_size", QString::number(tanks.value("Reserve").toDouble(), 'g', 16));

    q.addQueryItem("reserve_size", "0"); // always 0??

    q.addQueryItem("max_fuel_per_jump", QString::number(maxFuelPerJump, 'g', 16));

    if (range_boost <= 0.0) q.addQueryItem("range_boost", "");
    else q.addQueryItem("range_boost", QString::number(range_boost, 'g', 16));

    q.addQueryItem("ship_build", spanshShipbuild);

    q.addQueryItem("max_time", "60");
    q.addQueryItem("cargo", QString::number(m_constParams.value("cargo").toInt()));

    q.addQueryItem("algorithm", m_constParams.value("view").toString().toLower());

    q.addQueryItem("supercharge_multiplier", QString::number(m_superchargeMultiplier));
    q.addQueryItem("injection_multiplier", QString::number(m_injectionMultipler));

    qInfo() << q.toString();

    QEventLoop loop;
    QTimer timer;
    timer.setSingleShot(true);

    QNetworkAccessManager nam;

    QUrl url = m_link;
    QNetworkRequest req(url);
    req.setRawHeader("User-Agent", "SpanshScript/1.0");
    req.setRawHeader("Referer", "https://spansh.co.uk/exact-plotter");
    req.setRawHeader("X-Requested-With", "XMLHttpRequest");
    req.setHeader(QNetworkRequest::ContentTypeHeader, "application/x-www-form-urlencoded");

    QByteArray postData = q.toString(QUrl::FullyEncoded).toUtf8();
    QNetworkReply *reply = nam.post(req, postData);
    QObject::connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    QObject::connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);

    timer.start(60000);
    loop.exec();
    timer.stop();
    if (!reply->isFinished()) {
        reply->abort();

        QMetaObject::invokeMethod(m_manager, "error",
                                  Qt::QueuedConnection,
                                  Q_ARG(QString, "Spansh Error"),
                                  Q_ARG(QString, "Exact Plotter Request"),
                                  Q_ARG(QString, "Timed out (60s)"));

        reply->deleteLater();
        return;
    }

    if (reply->error() != QNetworkReply::NoError) {
        int status = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        QByteArray errorData = reply->readAll();

        QString errText = reply->errorString();
        if (!errorData.isEmpty()) {
            QJsonParseError jerr;
            QJsonDocument jd = QJsonDocument::fromJson(errorData, &jerr);
            if (jerr.error == QJsonParseError::NoError && jd.isObject()) {
                QString msg = jd.object().value("message").toString();
                if (!msg.isEmpty()) errText = msg;
            }
        }

        qWarning() << "Spansh request failed:"
                   << "HTTP" << status
                   << errText
                   << "Body:" << errorData.left(400);

        QMetaObject::invokeMethod(m_manager, "error",
                                  Qt::QueuedConnection,
                                  Q_ARG(QString, "Spansh Error"),
                                  Q_ARG(QString, "Exact Plotter Request"),
                                  Q_ARG(QString, QString("HTTP %1: %2").arg(status).arg(errText)));

        reply->deleteLater();
        return;
    }

    QByteArray postResponse = reply->readAll();
    reply->deleteLater();

    QJsonParseError postErr;
    QJsonDocument postDoc = QJsonDocument::fromJson(postResponse, &postErr);
    if (postErr.error != QJsonParseError::NoError || !postDoc.isObject()) {
        qWarning() << "Invalid POST JSON:" << postErr.errorString() << postResponse.left(300);
        QMetaObject::invokeMethod(m_manager, "error",
                                  Qt::QueuedConnection,
                                  Q_ARG(QString, "Spansh Error"),
                                  Q_ARG(QString, "Exact Plotter Request"),
                                  Q_ARG(QString, "Invalid JSON response from Spansh (POST)"));
        return;
    }

    QJsonObject postObj = postDoc.object();
    QString job = postObj.value("job").toString();
    QString state = postObj.value("state").toString();
    QString statusStr = postObj.value("status").toString();

    if (job.isEmpty()) {
        qWarning() << "Spansh did not return a job id:" << postObj;
        QMetaObject::invokeMethod(m_manager, "error",
                                  Qt::QueuedConnection,
                                  Q_ARG(QString, "Spansh Error"),
                                  Q_ARG(QString, "Exact Plotter Request"),
                                  Q_ARG(QString, "Spansh did not return job id"));
        return;
    }

    if (statusStr == "ok" && state == "completed" && postObj.contains("result")) {
        QByteArray full = QJsonDocument(postObj).toJson(QJsonDocument::Compact);
        QMetaObject::invokeMethod(m_manager, "gotSpanshReply",
                                  Qt::QueuedConnection,
                                  Q_ARG(QByteArray, full));
        return;
    }

    QUrl resultsUrl(m_results + job);

    QElapsedTimer total;
    total.start();

    int totalTimeoutMs = 360000;
    int perGetTimeoutMs = 15000;
    int pollDelayMs = 800;

    while (total.elapsed() < totalTimeoutMs) {
        QNetworkRequest getReq(resultsUrl);
        getReq.setRawHeader("User-Agent", "SpanshScript/1.0");
        getReq.setRawHeader("Referer", "https://spansh.co.uk/exact-plotter");
        getReq.setRawHeader("X-Requested-With", "XMLHttpRequest");

        QEventLoop getLoop;
        QTimer getTimer;
        getTimer.setSingleShot(true);

        QNetworkReply *getReply = nam.get(getReq);

        QObject::connect(getReply, &QNetworkReply::finished, &getLoop, &QEventLoop::quit);
        QObject::connect(&getTimer, &QTimer::timeout, &getLoop, &QEventLoop::quit);

        getTimer.start(perGetTimeoutMs);
        getLoop.exec();
        getTimer.stop();

        if (!getReply->isFinished()) {
            getReply->abort();
            getReply->deleteLater();

            QMetaObject::invokeMethod(m_manager, "error",
                                      Qt::QueuedConnection,
                                      Q_ARG(QString, "Spansh Error"),
                                      Q_ARG(QString, "Results Polling"),
                                      Q_ARG(QString, "Timed out while polling results"));
            return;
        }

        if (getReply->error() != QNetworkReply::NoError) {
            int st = getReply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
            QString errText = getReply->errorString();
            QByteArray errBody = getReply->readAll();
            getReply->deleteLater();

            if (st == 404) {
                QThread::msleep(pollDelayMs);
                continue;
            }

            qWarning() << "Results GET failed HTTP" << st << errText << errBody.left(300);

            QMetaObject::invokeMethod(m_manager, "error",
                                      Qt::QueuedConnection,
                                      Q_ARG(QString, "Spansh Error"),
                                      Q_ARG(QString, "Results Polling"),
                                      Q_ARG(QString, QString("HTTP %1: %2").arg(st).arg(errText)));
            return;
        }

        QByteArray body = getReply->readAll();
        getReply->deleteLater();

        QJsonParseError resErr;
        QJsonDocument resDoc = QJsonDocument::fromJson(body, &resErr);
        if (resErr.error != QJsonParseError::NoError || !resDoc.isObject()) {
            QThread::msleep(pollDelayMs);
            continue;
        }

        QJsonObject resObj = resDoc.object();
        QString s = resObj.value("state").toString();
        QString st = resObj.value("status").toString();

        if (st == "ok" && s == "completed") {
            QMetaObject::invokeMethod(m_manager, "gotSpanshReply",
                                      Qt::QueuedConnection,
                                      Q_ARG(QByteArray, body));
            return;
        }

        if (st == "error" || s == "error" || s == "failed") {
            QMetaObject::invokeMethod(m_manager, "error",
                                      Qt::QueuedConnection,
                                      Q_ARG(QString, "Spansh Error"),
                                      Q_ARG(QString, "Results Polling"),
                                      Q_ARG(QString, "Spansh job failed"));
            return;
        }

        QThread::msleep(pollDelayMs);
    }

    QMetaObject::invokeMethod(m_manager, "error",
                              Qt::QueuedConnection,
                              Q_ARG(QString, "Spansh Error"),
                              Q_ARG(QString, "Results Polling"),
                              Q_ARG(QString, "Timed out waiting for Spansh job completion"));
}


