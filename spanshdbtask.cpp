#include "spanshdbtask.h"
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


SpanshDBTask::SpanshDBTask(SpanshPlotter *manager, QString id64, QString task, QString systemName)
{
    m_manager = manager;
    m_id64 = id64;
    m_task = task;
    m_systemName = systemName;
    setAutoDelete(true);
}

void SpanshDBTask::run()
{
    qInfo() << "SpanshDBTask running on" << QThread::currentThread() << " with task: " << m_task;
    if(m_task == "system" && !m_id64.isEmpty()) {
        systemTask();
    }
    if(m_task == "edsm" && !m_systemName.isEmpty()) {
        edsmTask();
    }
}

void SpanshDBTask::systemTask()
{
    QEventLoop loop;
    QTimer timer;
    QNetworkAccessManager manager;
    timer.setSingleShot(true);

    QString endpoint = m_systemLink + m_id64;
    QUrl url(endpoint);

    QNetworkRequest request(url);
    request.setRawHeader("User-Agent", "Explorarium/1.0");
    request.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::AlwaysNetwork);
    QNetworkReply *reply = manager.get(request);
    QObject::connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    QObject::connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
    timer.start(10000);
    loop.exec();
    timer.stop();
    if (!reply->isFinished()) {
        reply->abort();
        return;
    }
    int httpStatus = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    QNetworkReply::NetworkError netError = reply->error();
    if (netError != QNetworkReply::NoError && httpStatus != 404) {
        qWarning() << "Network Error:" << reply->errorString();
        return;
    }

    QByteArray responseData = reply->readAll();
    QJsonDocument doc = QJsonDocument::fromJson(responseData);
    QJsonObject obj = doc.object();
    QVariantMap result;

    if (obj.contains("record")) {
        obj = obj.value("record").toObject();
    }

    if(!obj.contains("error")) {
        if(obj.contains("name")) {
            result["name"] = obj.value("name").toVariant();
        } else {
            result["name"] = QVariant("Unknown System");
        }

        if(obj.contains("updated_at")) {
            result["updated_at"] = obj.value("updated_at").toVariant();
        } else {
            result["updated_at"] = QVariant("Unknown Date");
        }

        if(obj.contains("body_count")) {
            result["full_body_count"] = obj.value("body_count").toVariant();
        } else {
            result["full_body_count"] = QVariant("??");
        }

        QJsonArray bodies = obj.value("bodies").toArray();
        int body_count = bodies.size();

        result["body_count"] = QVariant(body_count);
    } else {
        result["error"] = obj.value("error").toVariant();
        qInfo() << "Spansh Error found:" << result["error"].toString();
    }
    result["id"] = QVariant("spansh");
    qInfo() << "Fetched" << result.size() << "from Spansh";
    QMetaObject::invokeMethod(m_manager, "targetLoadingBay",
                              Qt::QueuedConnection,
                              Q_ARG(QVariantMap, result));
}

void SpanshDBTask::edsmTask()
{
    QEventLoop loop;
    QTimer timer;
    QNetworkAccessManager manager;
    timer.setSingleShot(true);

    QString endpoint = m_edsmLink;
    QUrl url(endpoint);

    QUrlQuery query;
    query.addQueryItem("systemName", m_systemName);
    url.setQuery(query);

    QNetworkRequest request(url);
    request.setRawHeader("User-Agent", "Explorarium/1.0");
    request.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::AlwaysNetwork);
    QNetworkReply *reply = manager.get(request);
    QObject::connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    QObject::connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
    timer.start(10000);
    loop.exec();
    timer.stop();
    if (!reply->isFinished()) {
        reply->abort();
        return;
    }
    int httpStatus = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    QNetworkReply::NetworkError netError = reply->error();
    if (netError != QNetworkReply::NoError && httpStatus != 404) {
        qWarning() << "Network Error:" << reply->errorString();
        return;
    }

    QByteArray responseData = reply->readAll();
    QJsonDocument doc = QJsonDocument::fromJson(responseData);
    QJsonObject obj = doc.object();
    QVariantMap result;

    if(obj.isEmpty()) {
        result["error"] = "empty";
    } else {
        if(obj.contains("name")) {
            result["name"] = obj.value("name").toVariant();
        } else {
            result["name"] = QVariant("Unknown System");
        }

        if(obj.contains("bodyCount")) {
            result["fullbodycount"] = obj.value("bodyCount").toVariant();
        } else {
            result["fullbodycount"] = QVariant("??");
        }

        if (obj.contains("bodies")) {
            QJsonArray bodies = obj.value("bodies").toArray();
            result["bodycount"] = !bodies.isEmpty() ? bodies.size() : 0;
            if (!bodies.isEmpty()) {
                QJsonObject star = bodies[0].toObject();
                if (!star.isEmpty()) {
                    if (star.contains("discovery")) {
                        QJsonObject discovery = star.value("discovery").toObject();
                        result["commander"] = discovery.value("commander").toVariant();
                        result["date"] = discovery.value("date").toVariant();
                    }
                }
            } else {
                result["commander"] = QVariant("Unknown CMDR");
                result["date"] = QVariant("Unknown Date");
            }
        } else {
            result["commander"] = QVariant("Unknown CMDR");
            result["date"] = QVariant("Unknown Date");
            result["bodycount"] = QVariant(0);
        }
    }
    result["id"] = QVariant("edsm");
    qInfo() << "Fetched" << result.size() << "from Spansh";
    // reply->deleteLater();
    QMetaObject::invokeMethod(m_manager, "targetLoadingBay",
                              Qt::QueuedConnection,
                              Q_ARG(QVariantMap, result));
}

