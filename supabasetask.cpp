#include "supabasetask.h"
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

SupabaseTask::SupabaseTask(SupabaseClient *client, Operation op, QVariantMap params, QString url, QString key)
{
    qInfo() << this << "Constructed for operation: " << op;
    m_operation = op;
    m_client = client;
    m_key = key;
    m_url = url;
    m_params = params;
}

void SupabaseTask::FetchSystems()
{
    QEventLoop loop;
    QTimer timer;
    QEventLoop loop2;
    QTimer timer2;
    QNetworkAccessManager manager;
    timer.setSingleShot(true);
    timer2.setSingleShot(true);

    QString endpoint = m_url + "/rest/v1/systems?select=*";
    QUrl url(endpoint);

    QNetworkRequest request(url);
    request.setRawHeader("apikey", m_key.toUtf8());
    request.setRawHeader("Authorization", ("Bearer " + m_key).toUtf8());
    request.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::AlwaysNetwork);

    QNetworkReply *reply = manager.get(request);
    QObject::connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    QObject::connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
    timer.start(60000);
    loop.exec();
    timer.stop();
    if (!reply->isFinished()) {
        reply->abort();
        QMetaObject::invokeMethod(m_client, "onError",
                                  Qt::QueuedConnection,
                                  Q_ARG(QString, "Failed to Fetch Systems"),
                                  Q_ARG(QString, "Fetching Systems"),
                                  Q_ARG(QString, "Timed out"));
        reply->deleteLater();
        return;
    }

    if(reply->error() != QNetworkReply::NoError) {
        QByteArray errorData = reply->readAll();
        QJsonDocument errorDoc = QJsonDocument::fromJson(errorData);
        QString detailedError = errorDoc.object().value("message").toString();
        QString errorMsg = detailedError.isEmpty() ? reply->errorString() : detailedError;
        qWarning() << "Error: " << errorMsg;
        QMetaObject::invokeMethod(m_client, "onError",
                                  Qt::QueuedConnection,
                                  Q_ARG(QString, "Failed to Fetch Systems"),
                                  Q_ARG(QString, "Fetching Systems"),
                                  Q_ARG(QString, errorMsg));
        reply->deleteLater();
        return;
    }

    QByteArray responseData = reply->readAll();
    QJsonDocument doc = QJsonDocument::fromJson(responseData);
    QJsonArray array = doc.array();

    QVariantList systems = array.toVariantList();
    qInfo() << "Fetched" << systems.size() << "systems";
    reply->deleteLater();

    QString endpoint2 = m_url + "/rest/v1/claims?select=*&claimed=eq.true";
    QUrl claimsUrl = QUrl(endpoint2);
    QNetworkRequest request2(claimsUrl);
    request2.setRawHeader("apikey", m_key.toUtf8());
    request2.setRawHeader("Authorization", ("Bearer " + m_key).toUtf8());
    request2.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::AlwaysNetwork);

    QNetworkReply *reply2 = manager.get(request2);
    QObject::connect(reply2, &QNetworkReply::finished, &loop2, &QEventLoop::quit);
    QObject::connect(&timer2, &QTimer::timeout, &loop2, &QEventLoop::quit);
    timer2.start(60000);
    loop2.exec();
    timer2.stop();
    if (!reply2->isFinished()) {
        reply2->abort();
        QMetaObject::invokeMethod(m_client, "onError",
                                  Qt::QueuedConnection,
                                  Q_ARG(QString, "Failed to Fetch Claims"),
                                  Q_ARG(QString, "Fetching Claims"),
                                  Q_ARG(QString, "Timed out"));
        reply2->deleteLater();
        return;
    }

    if (reply2->error() != QNetworkReply::NoError) {
        QByteArray errorData2 = reply2->readAll();
        QJsonDocument errorDoc2 = QJsonDocument::fromJson(errorData2);
        QString detailedError2 = errorDoc2.object().value("message").toString();
        QString errorMsg2 = detailedError2.isEmpty() ? reply2->errorString() : detailedError2;
        qWarning() << "Error: " << errorMsg2;
        QMetaObject::invokeMethod(m_client, "onError",
                                  Qt::QueuedConnection,
                                  Q_ARG(QString, "Failed to Fetch Claims"),
                                  Q_ARG(QString, "Fetching Claims"),
                                  Q_ARG(QString, errorMsg2));
        reply2->deleteLater();
        return;
    }

    QVariantList claims = QJsonDocument::fromJson(reply2->readAll()).array().toVariantList();
    qInfo() << "Fetched" << claims.size() << "claims";
    reply2->deleteLater();
    QMetaObject::invokeMethod(m_client, "onSystemsLoaded",
                              Qt::QueuedConnection,
                              Q_ARG(QVariantList, systems),
                              Q_ARG(QVariantList, claims),
                              Q_ARG(QVariantList, QVariantList()));
}

void SupabaseTask::FetchCategoryImages()
{
    QEventLoop loop;
    QTimer timer;
    QNetworkAccessManager manager;
    timer.setSingleShot(true);

    QString endpoint = m_url + "/rest/v1/category_images?select=*";
    QUrl url(endpoint);

    QNetworkRequest request(url);
    request.setRawHeader("apikey", m_key.toUtf8());
    request.setRawHeader("Authorization", ("Bearer " + m_key).toUtf8());
    request.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::AlwaysNetwork);
    QNetworkReply *reply = manager.get(request);
    QObject::connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    QObject::connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
    timer.start(60000);
    loop.exec();
    timer.stop();
    if (!reply->isFinished()) {
        reply->abort();
        QMetaObject::invokeMethod(m_client, "onError",
                                  Qt::QueuedConnection,
                                  Q_ARG(QString, "Failed to Fetch Category Images"),
                                  Q_ARG(QString, "Fetching Category Images"),
                                  Q_ARG(QString, "Timed out"));
        reply->deleteLater();
        return;
    }
    if(reply->error() != QNetworkReply::NoError) {
        QByteArray errorData = reply->readAll();
        QJsonDocument errorDoc = QJsonDocument::fromJson(errorData);
        QString detailedError = errorDoc.object().value("message").toString();
        QString errorMsg = detailedError.isEmpty() ? reply->errorString() : detailedError;
        qWarning() << "Error: " << errorMsg;
        QMetaObject::invokeMethod(m_client, "onError",
                                  Qt::QueuedConnection,
                                  Q_ARG(QString, "Failed to Fetch Category Images"),
                                  Q_ARG(QString, "Fetching Category Images"),
                                  Q_ARG(QString, errorMsg));
        reply->deleteLater();
        return;
    }

    QByteArray responseData = reply->readAll();
    QJsonDocument doc = QJsonDocument::fromJson(responseData);
    QJsonArray array = doc.array();
    QVariantMap categoryImages;

    for(int i = 0; i < array.size(); i++) {
        QJsonObject obj = array[i].toObject();
        QString category = obj["tag"].toString();
        QString url = obj["background_url"].toString();
        categoryImages[category] = url;
    }

    qInfo() << "Fetched" << categoryImages.size() << "categoryImages";
    reply->deleteLater();
    QMetaObject::invokeMethod(m_client, "onCategoryLoaded",
                              Qt::QueuedConnection,
                              Q_ARG(QVariantMap, categoryImages));
}

void SupabaseTask::FetchSingleSystem() // fix empty data
{
    QEventLoop loop;
    QTimer timer;
    QEventLoop loop2;
    QTimer timer2;
    QEventLoop loop3;
    QTimer timer3;
    QEventLoop loop4;
    QTimer timer4;
    QNetworkAccessManager manager;
    timer.setSingleShot(true);
    timer2.setSingleShot(true);
    timer3.setSingleShot(true);
    timer4.setSingleShot(true);

    QVariantMap data;

    // claims table

    QString endpoint = m_url + "/rest/v1/claims";
    QUrl url(endpoint);

    QUrlQuery query;

    query.addQueryItem("system_name", "eq." + m_params["system_name"].toString());
    query.addQueryItem("claimed", "eq.true");
    url.setQuery(query);

    QNetworkRequest request(url);
    request.setRawHeader("apikey", m_key.toUtf8());
    request.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::AlwaysNetwork);
    request.setRawHeader("Authorization", ("Bearer " + m_key).toUtf8());
    QNetworkReply *reply = manager.get(request);
    QObject::connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    QObject::connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
    timer.start(60000);
    loop.exec();
    timer.stop();
    if (!reply->isFinished()) {
        reply->abort();
        QMetaObject::invokeMethod(m_client, "onError",
                                  Qt::QueuedConnection,
                                  Q_ARG(QString, "Failed to Fetch Current System Claims"),
                                  Q_ARG(QString, "Fetching Current System Claims"),
                                  Q_ARG(QString, "Timed out"));
        reply->deleteLater();
        return;
    }
    if(reply->error() != QNetworkReply::NoError) {
        QByteArray errorData = reply->readAll();
        QJsonDocument errorDoc = QJsonDocument::fromJson(errorData);
        QString detailedError = errorDoc.object().value("message").toString();
        QString errorMsg = detailedError.isEmpty() ? reply->errorString() : detailedError;
        qWarning() << "Error: " << errorMsg;
        QMetaObject::invokeMethod(m_client, "onError",
                                  Qt::QueuedConnection,
                                  Q_ARG(QString, "Failed to Fetch Current System Claims"),
                                  Q_ARG(QString, "Fetching Current System Claims"),
                                  Q_ARG(QString, errorMsg));
        reply->deleteLater();
        return;
    }
    QByteArray responseData = reply->readAll();
    QJsonDocument doc = QJsonDocument::fromJson(responseData);
    QJsonArray table = doc.array();
    if(table.isEmpty()) {
        qInfo() << "System is currently unclaimed.";
        data["claims"] = QVariantMap();
    } else {
        QJsonObject systemRow = table[0].toObject();
        data["claims"] = systemRow.toVariantMap();
    }
    reply->deleteLater();

    // system images

    QString endpoint2 = m_url + "/rest/v1/system_images";
    QUrl url2(endpoint2);

    QUrlQuery query2;

    query2.addQueryItem("system_name", "eq." + m_params["system_name"].toString());
    url2.setQuery(query2);

    QNetworkRequest request2(url2);
    request2.setRawHeader("apikey", m_key.toUtf8());
    request2.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::AlwaysNetwork);
    request2.setRawHeader("Authorization", ("Bearer " + m_key).toUtf8());
    QNetworkReply *reply2 = manager.get(request2);
    QObject::connect(reply2, &QNetworkReply::finished, &loop2, &QEventLoop::quit);
    QObject::connect(&timer2, &QTimer::timeout, &loop2, &QEventLoop::quit);
    timer2.start(60000);
    loop2.exec();
    timer2.stop();
    if (!reply2->isFinished()) {
        reply2->abort();
        QMetaObject::invokeMethod(m_client, "onError",
                                  Qt::QueuedConnection,
                                  Q_ARG(QString, "Failed to Fetch Current System Images"),
                                  Q_ARG(QString, "Fetching Current System Images"),
                                  Q_ARG(QString, "Timed out"));
        reply2->deleteLater();
        return;
    }
    if(reply2->error() != QNetworkReply::NoError) {
        QByteArray errorData2 = reply2->readAll();
        QJsonDocument errorDoc2 = QJsonDocument::fromJson(errorData2);
        QString detailedError2 = errorDoc2.object().value("message").toString();
        QString errorMsg2 = detailedError2.isEmpty() ? reply2->errorString() : detailedError2;
        qWarning() << "Error: " << errorMsg2;
        QMetaObject::invokeMethod(m_client, "onError",
                                  Qt::QueuedConnection,
                                  Q_ARG(QString, "Failed to Fetch Current System Images"),
                                  Q_ARG(QString, "Fetching Current System Images"),
                                  Q_ARG(QString, errorMsg2));
        reply2->deleteLater();
        return;
    }
    QByteArray responseData2 = reply2->readAll();
    QJsonDocument doc2 = QJsonDocument::fromJson(responseData2);
    QJsonArray systemimagestable = doc2.array();
    data["system_images"] = systemimagestable.toVariantList();
    reply2->deleteLater();

    // user contribs

    QString endpoint3 = m_url + "/rest/v1/user_contributions";
    QUrl url3(endpoint3);

    QUrlQuery query3;

    query3.addQueryItem("system_name", "eq." + m_params["system_name"].toString());
    url3.setQuery(query3);

    QNetworkRequest request3(url3);
    request3.setRawHeader("apikey", m_key.toUtf8());
    request3.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::AlwaysNetwork);
    request3.setRawHeader("Authorization", ("Bearer " + m_key).toUtf8());
    QNetworkReply *reply3 = manager.get(request3);
    QObject::connect(reply3, &QNetworkReply::finished, &loop3, &QEventLoop::quit);
    QObject::connect(&timer3, &QTimer::timeout, &loop3, &QEventLoop::quit);
    timer3.start(60000);
    loop3.exec();
    timer3.stop();
    if (!reply3->isFinished()) {
        reply3->abort();
        QMetaObject::invokeMethod(m_client, "onError",
                                  Qt::QueuedConnection,
                                  Q_ARG(QString, "Failed to Fetch Current System Contributions"),
                                  Q_ARG(QString, "Fetching Current System Contributions"),
                                  Q_ARG(QString, "Timed out"));
        reply3->deleteLater();
        return;
    }
    if(reply3->error() != QNetworkReply::NoError) {
        QByteArray errorData3 = reply3->readAll();
        QJsonDocument errorDoc3 = QJsonDocument::fromJson(errorData3);
        QString detailedError3 = errorDoc3.object().value("message").toString();
        QString errorMsg3 = detailedError3.isEmpty() ? reply3->errorString() : detailedError3;
        qWarning() << "Error: " << errorMsg3;
        QMetaObject::invokeMethod(m_client, "onError",
                                  Qt::QueuedConnection,
                                  Q_ARG(QString, "Failed to Fetch Current System Images"),
                                  Q_ARG(QString, "Fetching Current System Images"),
                                  Q_ARG(QString, errorMsg3));
        reply3->deleteLater();
        return;
    }
    QByteArray responseData3 = reply3->readAll();
    QJsonDocument doc3 = QJsonDocument::fromJson(responseData3);
    QJsonArray contribs = doc3.array();
    if (contribs.isEmpty()) {
        data["user_contributions"] = QVariantMap();
    } else {
        QJsonObject row = contribs[0].toObject();
        data["user_contributions"] = row.toVariantMap();
    }
    reply3->deleteLater();

    // gec

    QString endpoint4 = "https://edastro.com/gec/json/id64/" + m_params["id64"].toString();
    QUrl url4(endpoint4);

    QNetworkRequest request4(url4);
    request4.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request4.setRawHeader("User-Agent", "ExplorariumApp");
    QNetworkReply *reply4 = manager.get(request4);
    QObject::connect(reply4, &QNetworkReply::finished, &loop4, &QEventLoop::quit);
    QObject::connect(&timer4, &QTimer::timeout, &loop4, &QEventLoop::quit);
    timer4.start(60000);
    loop4.exec();
    timer4.stop();
    reply4->deleteLater();
    if (!reply4->isFinished()) {
        reply4->abort();
        QMetaObject::invokeMethod(m_client, "onError",
                                  Qt::QueuedConnection,
                                  Q_ARG(QString, "Failed to Fetch GEC Data"),
                                  Q_ARG(QString, "Fetching GEC Data"),
                                  Q_ARG(QString, "Timed out"));
        return;
    }
    if(reply4->error() != QNetworkReply::NoError) {
        QByteArray errorData4 = reply4->readAll();
        QJsonDocument errorDoc4 = QJsonDocument::fromJson(errorData4);
        QString detailedError4 = errorDoc4.object().value("message").toString();
        QString errorMsg4 = detailedError4.isEmpty() ? reply4->errorString() : detailedError4;
        qWarning() << "Error: " << errorMsg4;
        QMetaObject::invokeMethod(m_client, "onError",
                                  Qt::QueuedConnection,
                                  Q_ARG(QString, "Failed to Fetch GEC Data"),
                                  Q_ARG(QString, "Fetching GEC Data"),
                                  Q_ARG(QString, errorMsg4));
        return;
    }
    QByteArray responseData4 = reply4->readAll();
    QJsonDocument doc4 = QJsonDocument::fromJson(responseData4);
    QJsonObject gecData = doc4.object();
    if (gecData.isEmpty()) {
        data["gec_url"] = QString();
    } else {
        data["gec_url"] = gecData.value("poiUrl").toString();
    }
    QMetaObject::invokeMethod(m_client, "onSingleSystemLoaded",
                              Qt::QueuedConnection,
                              Q_ARG(QVariantMap, data));
}

void SupabaseTask::FetchDbMetaData()
{
    QEventLoop loop;
    QTimer timer;
    QNetworkAccessManager manager;
    timer.setSingleShot(true);

    QString endpoint = m_url + "/rest/v1/db_metadata?select=*";
    QUrl url(endpoint);

    QNetworkRequest request(url);
    request.setRawHeader("apikey", m_key.toUtf8());
    request.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::AlwaysNetwork);
    request.setRawHeader("Authorization", ("Bearer " + m_key).toUtf8());
    QNetworkReply *reply = manager.get(request);
    QObject::connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    QObject::connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
    timer.start(60000);
    loop.exec();
    timer.stop();
    if (!reply->isFinished()) {
        reply->abort();
        QMetaObject::invokeMethod(m_client, "onError",
                                  Qt::QueuedConnection,
                                  Q_ARG(QString, "Failed to Fetch Database Status"),
                                  Q_ARG(QString, "Fetching Database Status"),
                                  Q_ARG(QString, "Timed out"));
        reply->deleteLater();
        return;
    }
    if(reply->error() != QNetworkReply::NoError) {
        QByteArray errorData = reply->readAll();
        QJsonDocument errorDoc = QJsonDocument::fromJson(errorData);
        QString detailedError = errorDoc.object().value("message").toString();
        QString errorMsg = detailedError.isEmpty() ? reply->errorString() : detailedError;
        qWarning() << "Error: " << errorMsg;
        QMetaObject::invokeMethod(m_client, "onError",
                                  Qt::QueuedConnection,
                                  Q_ARG(QString, "Failed to Fetch Database Status"),
                                  Q_ARG(QString, "Fetching Database Status"),
                                  Q_ARG(QString, errorMsg));
        reply->deleteLater();
        return;
    }
    QByteArray responseData = reply->readAll();
    QJsonDocument doc = QJsonDocument::fromJson(responseData);
    QJsonArray array = doc.array();
    QJsonObject metadata = array[0].toObject();
    int newThisWeek = metadata["new_this_week"].toInt();
    QString lastUpdated = metadata["last_updated"].toString();
    QVariantList dbData;
    dbData.append(newThisWeek);
    dbData.append(lastUpdated);
    reply->deleteLater();
    QMetaObject::invokeMethod(m_client, "onDbLoaded",
                              Qt::QueuedConnection,
                              Q_ARG(QVariantList, dbData));
}

void SupabaseTask::FetchContributions()
{
    QEventLoop loop;
    QTimer timer;
    QNetworkAccessManager manager;
    timer.setSingleShot(true);

    QString endpoint = m_url + "/rest/v1/user_contributions?select=*";
    QUrl url = QUrl(endpoint);

    QNetworkRequest request(url);
    request.setRawHeader("apikey", m_key.toUtf8());
    request.setRawHeader("Authorization", ("Bearer " + m_key).toUtf8());
    request.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::AlwaysNetwork);
    QNetworkReply *reply = manager.get(request);
    QObject::connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    QObject::connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
    timer.start(60000);
    loop.exec();
    timer.stop();
    if (!reply->isFinished()) {
        reply->abort();
        QMetaObject::invokeMethod(m_client, "onError",
                                  Qt::QueuedConnection,
                                  Q_ARG(QString, "Failed to Fetch Contributions"),
                                  Q_ARG(QString, "Fetching Contributions"),
                                  Q_ARG(QString, "Timed out"));
        reply->deleteLater();
        return;
    }
    if(reply->error() != QNetworkReply::NoError) {
        QByteArray errorData = reply->readAll();
        QJsonDocument errorDoc = QJsonDocument::fromJson(errorData);
        QString detailedError = errorDoc.object().value("message").toString();
        QString errorMsg = detailedError.isEmpty() ? reply->errorString() : detailedError;
        qWarning() << "Error: " << errorMsg;
        QMetaObject::invokeMethod(m_client, "onError",
                                  Qt::QueuedConnection,
                                  Q_ARG(QString, "Failed to Fetch Contributions"),
                                  Q_ARG(QString, "Fetching Contributions"),
                                  Q_ARG(QString, errorMsg));
        reply->deleteLater();
        return;
    }
    QByteArray responseData = reply->readAll();
    QJsonDocument doc = QJsonDocument::fromJson(responseData);
    QJsonArray array = doc.array();
    QVariantList fulldata = array.toVariantList();
    qInfo() << "Fetched" << fulldata.size() <<  "contributions";
    reply->deleteLater();
    QMetaObject::invokeMethod(m_client, "onContributionsLoaded",
                              Qt::QueuedConnection,
                              Q_ARG(QVariantList, fulldata));
}

void SupabaseTask::FetchShipBuild()
{
    QEventLoop loop;
    QTimer timer;
    timer.setSingleShot(true);
    QNetworkAccessManager manager;

    QString endpoint = m_url + "/rest/v1/ship_build?select=*";
    QUrl url = QUrl(endpoint);

    QNetworkRequest request(url);
    request.setRawHeader("apikey", m_key.toUtf8());
    request.setRawHeader("Authorization", ("Bearer " + m_key).toUtf8());
    request.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::AlwaysNetwork);
    QNetworkReply *reply = manager.get(request);
    QObject::connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    QObject::connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
    timer.start(60000);
    loop.exec();
    timer.stop();

    if (!reply->isFinished()) {
        reply->abort();
        QMetaObject::invokeMethod(m_client, "onBackError",
                                  Qt::QueuedConnection,
                                  Q_ARG(QString, "Failed to Fetch Ship Build"),
                                  Q_ARG(QString, "Fetching Ship Build"),
                                  Q_ARG(QString, "Timed out"));
        reply->deleteLater();
        return;
    }
    if(reply->error() != QNetworkReply::NoError) {
        QByteArray errorData = reply->readAll();
        QJsonDocument errorDoc = QJsonDocument::fromJson(errorData);
        QString detailedError = errorDoc.object().value("message").toString();
        QString errorMsg = detailedError.isEmpty() ? reply->errorString() : detailedError;
        qWarning() << "Error: " << errorMsg;
        QMetaObject::invokeMethod(m_client, "onBackError",
                                  Qt::QueuedConnection,
                                  Q_ARG(QString, "Failed to Fetch Ship Build"),
                                  Q_ARG(QString, "Fetching Ship Build"),
                                  Q_ARG(QString, errorMsg));
        reply->deleteLater();
        return;
    }
    QByteArray responseData = reply->readAll();
    QJsonDocument doc = QJsonDocument::fromJson(responseData);
    QJsonArray array = doc.array();
    QMetaObject::invokeMethod(m_client, "onShipBuildLoaded", Qt::QueuedConnection, Q_ARG(QJsonArray, array));
}

void SupabaseTask::FetchSystemImages()
{
    QEventLoop loop;
    QTimer timer;
    QNetworkAccessManager manager;
    timer.setSingleShot(true);

    QString endpoint = m_url + "/rest/v1/system_images?select=*";
    QUrl url = QUrl(endpoint);

    QNetworkRequest request(url);
    request.setRawHeader("apikey", m_key.toUtf8());
    request.setRawHeader("Authorization", ("Bearer " + m_key).toUtf8());
    request.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::AlwaysNetwork);
    QNetworkReply *reply = manager.get(request);
    QObject::connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    QObject::connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
    timer.start(60000);
    loop.exec();
    timer.stop();
    if (!reply->isFinished()) {
        reply->abort();
        QMetaObject::invokeMethod(m_client, "onError",
                                  Qt::QueuedConnection,
                                  Q_ARG(QString, "Failed to Fetch System Images"),
                                  Q_ARG(QString, "Fetching System Images"),
                                  Q_ARG(QString, "Timed out"));
        reply->deleteLater();
        return;
    }
    if(reply->error() != QNetworkReply::NoError) {
        QByteArray errorData = reply->readAll();
        QJsonDocument errorDoc = QJsonDocument::fromJson(errorData);
        QString detailedError = errorDoc.object().value("message").toString();
        QString errorMsg = detailedError.isEmpty() ? reply->errorString() : detailedError;
        qWarning() << "Error: " << errorMsg;
        QMetaObject::invokeMethod(m_client, "onError",
                                  Qt::QueuedConnection,
                                  Q_ARG(QString, "Failed to Fetch System Images"),
                                  Q_ARG(QString, "Fetching System Images"),
                                  Q_ARG(QString, errorMsg));
        reply->deleteLater();
        return;
    }
    QByteArray responseData = reply->readAll();
    QJsonDocument doc = QJsonDocument::fromJson(responseData);
    QJsonArray array = doc.array();
    QVariantList fulldata = array.toVariantList();
    qInfo() << "Fetched" << fulldata.size() <<  "images";
    reply->deleteLater();
    QMetaObject::invokeMethod(m_client, "onImagesLoaded",
                              Qt::QueuedConnection,
                              Q_ARG(QVariantList, fulldata));
}

void SupabaseTask::ClaimSystem()
{
    QEventLoop loop;
    QTimer timer;
    QNetworkAccessManager manager;
    timer.setSingleShot(true);

    QString endpoint = m_url + "/rest/v1/claims?on_conflict=system_name&select=*";
    QUrl url = QUrl(endpoint);

    QNetworkRequest request(url);
    request.setRawHeader("apikey", m_key.toUtf8());
    request.setRawHeader("Authorization", ("Bearer " + m_key).toUtf8());
    request.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::AlwaysNetwork);
    request.setRawHeader("Prefer", "resolution=merge-duplicates,return=representation");
    request.setRawHeader("Cmdr-Name", m_params["cmdr_name"].toString().toUtf8());
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    QJsonObject requestParams = QJsonObject::fromVariantMap(m_params);
    QJsonDocument doc(requestParams);
    QByteArray data = doc.toJson();
    QNetworkReply *reply = manager.post(request, data);
    QObject::connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    QObject::connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
    timer.start(60000);
    loop.exec();
    timer.stop();
    if (!reply->isFinished()) {
        reply->abort();
        QMetaObject::invokeMethod(m_client, "onError",
                                  Qt::QueuedConnection,
                                  Q_ARG(QString, "Could not Claim"),
                                  Q_ARG(QString, "Claiming a system"),
                                  Q_ARG(QString, "Timed out"));
        reply->deleteLater();
        return;
    };
    if(reply->error() != QNetworkReply::NoError) {
        QByteArray errorData = reply->readAll();
        QJsonDocument errorDoc = QJsonDocument::fromJson(errorData);
        QString detailedError = errorDoc.object().value("message").toString().toUtf8();
        QString errorMsg = detailedError.isEmpty() ? reply->errorString() : detailedError;
        qWarning() << "Error: " << errorMsg;
        QMetaObject::invokeMethod(m_client, "onError",
                                  Qt::QueuedConnection,
                                  Q_ARG(QString, "Could Not Claim"),
                                  Q_ARG(QString, "Claiming a system"),
                                  Q_ARG(QString, errorMsg));
        reply->deleteLater();
        return;
    }
    QByteArray responseData = reply->readAll();
    QJsonDocument document = QJsonDocument::fromJson(responseData);
    QJsonArray array = document.array();
    QVariantList fulldata = array.toVariantList();
    QString systemName;
    QString cmdrName;
    for(int i = 0; i < fulldata.size(); i++) {
        QVariantMap minidata = fulldata[i].toMap();
        if(minidata["system_name"].toString() == m_params["system_name"].toString()) {
            systemName = minidata["system_name"].toString();
            cmdrName = minidata["cmdr_name"].toString();
        }
    }
    qInfo() << "Fetched" << fulldata.size() <<  "images";
    reply->deleteLater();
    QMetaObject::invokeMethod(m_client, "onClaimSuccess",
                              Qt::QueuedConnection,
                              Q_ARG(QString, systemName),
                              Q_ARG(QString, cmdrName));
}

void SupabaseTask::UnclaimSystem()
{
    QEventLoop loop;
    QTimer timer;
    QNetworkAccessManager manager;
    timer.setSingleShot(true);

    QString endpoint = m_url + "/rest/v1/claims?system_name=eq." + QUrl::toPercentEncoding(m_params["system_name"].toString())
                       + "&cmdr_name=eq." + QUrl::toPercentEncoding(m_params["cmdr_name"].toString());
    QUrl url = QUrl(endpoint);

    QNetworkRequest request(url);
    request.setRawHeader("apikey", m_key.toUtf8());
    request.setRawHeader("Authorization", ("Bearer " + m_key).toUtf8());
    request.setRawHeader("Cmdr-Name", m_params["cmdr_name"].toString().toUtf8());
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::AlwaysNetwork);
    QJsonObject requestParams = QJsonObject::fromVariantMap(m_params);
    QJsonDocument doc(requestParams);
    QByteArray data = doc.toJson();
    QNetworkReply *reply = manager.sendCustomRequest(request, "PATCH", data);
    QObject::connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    QObject::connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
    timer.start(60000);
    loop.exec();
    timer.stop();
    if (!reply->isFinished()) {
        reply->abort();
        QMetaObject::invokeMethod(m_client, "onError",
                                  Qt::QueuedConnection,
                                  Q_ARG(QString, "Could not Unclaim"),
                                  Q_ARG(QString, "Unclaiming a System"),
                                  Q_ARG(QString, "Timed out"));
        reply->deleteLater();
        return;
    }

    if(reply->error() != QNetworkReply::NoError) {
        QByteArray errorData = reply->readAll();
        QJsonDocument errorDoc = QJsonDocument::fromJson(errorData);
        QString detailedError = errorDoc.object().value("message").toString();
        QString errorMsg = detailedError.isEmpty() ? reply->errorString() : detailedError;

        qWarning() << "Error: " << errorMsg;
        QMetaObject::invokeMethod(m_client, "onError",
                                  Qt::QueuedConnection,
                                  Q_ARG(QString, "Could Not Unclaim"),
                                  Q_ARG(QString, "Unclaiming a System"),
                                  Q_ARG(QString, errorMsg));
        reply->deleteLater();
        return;
    }
    reply->deleteLater();
    QMetaObject::invokeMethod(m_client, "onUnclaimSuccess",
                              Qt::QueuedConnection,
                              Q_ARG(QString, m_params["system_name"].toString()));
}

void SupabaseTask::AddContributions()
{
    QEventLoop loop;
    QTimer timer;
    QNetworkAccessManager manager;
    timer.setSingleShot(true);

    QString endpoint = m_url + "/rest/v1/user_contributions?on_conflict=system_name,cmdr_name";
    QUrl url = QUrl(endpoint);

    QNetworkRequest request(url);
    request.setRawHeader("apikey", m_key.toUtf8());
    request.setRawHeader("Authorization", ("Bearer " + m_key).toUtf8());
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("Prefer", "resolution=merge-duplicates,return=representation");
    request.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::AlwaysNetwork);

    QJsonObject requestParams = QJsonObject::fromVariantMap(m_params);
    QJsonDocument doc(requestParams);
    QByteArray data = doc.toJson();

    QNetworkReply *reply = manager.post(request, data);
    QObject::connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    QObject::connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
    timer.start(60000);
    loop.exec();
    timer.stop();
    if (!reply->isFinished()) {
        reply->abort();
        QMetaObject::invokeMethod(m_client, "onError",
                                  Qt::QueuedConnection,
                                  Q_ARG(QString, "Could Not Add Contribution"),
                                  Q_ARG(QString, "Adding a contribution"),
                                  Q_ARG(QString, "Timed out"));
        reply->deleteLater();
        return;
    }

    if(reply->error() != QNetworkReply::NoError) {
        QByteArray errorData = reply->readAll();
        QJsonDocument errorDoc = QJsonDocument::fromJson(errorData);
        QString detailedError = errorDoc.object().value("message").toString();
        QString errorMsg = detailedError.isEmpty() ? reply->errorString() : detailedError;

        qWarning() << "Error: " << errorMsg;
        QMetaObject::invokeMethod(m_client, "onError",
                                  Qt::QueuedConnection,
                                  Q_ARG(QString, "Could Not Add Contribution"),
                                  Q_ARG(QString, "Adding a contribution"),
                                  Q_ARG(QString, errorMsg));
        reply->deleteLater();
        return;
    }

    QByteArray responseData = reply->readAll();
    QJsonDocument responseDoc = QJsonDocument::fromJson(responseData);
    QVariantList resultList = responseDoc.array().toVariantList();
    QVariantMap confirmedData;
    if(!resultList.isEmpty()) {
        confirmedData = resultList.first().toMap();
    }

    reply->deleteLater();
    QMetaObject::invokeMethod(m_client, "onContributionsAdded",
                              Qt::QueuedConnection,
                              Q_ARG(QVariantMap, confirmedData));
}

void SupabaseTask::UploadImage()
{
    QEventLoop loop;
    QTimer timer;
    timer.setSingleShot(true);
    QNetworkAccessManager manager;

    QString endpoint = m_url + "/rest/v1/system_images";
    QUrl url = QUrl(endpoint);

    QNetworkRequest request(url);
    request.setRawHeader("apikey", m_key.toUtf8());
    request.setRawHeader("Authorization", ("Bearer " + m_key).toUtf8());
    request.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::AlwaysNetwork);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("Prefer", "return=representation");

    QJsonObject requestParams = QJsonObject::fromVariantMap(m_params);
    QJsonDocument doc(requestParams);
    QByteArray data = doc.toJson();

    QNetworkReply *reply = manager.post(request, data);
    QObject::connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    QObject::connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
    timer.start(60000);
    loop.exec();
    timer.stop();
    if (!reply->isFinished()) {
        reply->abort();
        QMetaObject::invokeMethod(m_client, "onError",
                                  Qt::QueuedConnection,
                                  Q_ARG(QString, "Could Not Upload Image"),
                                  Q_ARG(QString, "Uploading an image"),
                                  Q_ARG(QString, "Timed out"));
        reply->deleteLater();
        return;
    }

    if(reply->error() != QNetworkReply::NoError) {
        QByteArray errorData = reply->readAll();
        QJsonDocument errorDoc = QJsonDocument::fromJson(errorData);
        QString detailedError = errorDoc.object().value("message").toString();
        QString errorMsg = detailedError.isEmpty() ? reply->errorString() : detailedError;
        qWarning() << "Error: " << errorMsg;
        QMetaObject::invokeMethod(m_client, "onError",
                                  Qt::QueuedConnection,
                                  Q_ARG(QString, "Could Not Upload Image"),
                                  Q_ARG(QString, "Uploading an image"),
                                  Q_ARG(QString, errorMsg));
        reply->deleteLater();
        return;
    }

    QByteArray responseData = reply->readAll();
    QJsonDocument responseDoc = QJsonDocument::fromJson(responseData);
    QJsonArray resultArray = responseDoc.array();
    if (!resultArray.isEmpty()) {
        QJsonValue firstValue = resultArray.first();
        QVariantMap confirmedData = firstValue.toObject().toVariantMap();
        QMetaObject::invokeMethod(m_client, "onImageSaved",
                                  Qt::QueuedConnection,
                                  Q_ARG(QVariantMap, confirmedData));
    } else {
        qWarning() << "Database returned an empty array on successful image save.";
    }
    reply->deleteLater();
}

void SupabaseTask::RemoveImage()
{
    QEventLoop loop;
    QTimer timer;
    timer.setSingleShot(true);
    QNetworkAccessManager manager;
    QString imageUrl = m_params["image_url"].toString().trimmed();
    QString cmdrName = m_params["cmdr_name"].toString().trimmed();

    QUrl url(m_url + "/rest/v1/system_images");
    QUrlQuery endpoint;

    endpoint.addQueryItem("image_url", "eq." + imageUrl);
    endpoint.addQueryItem("uploaded_by", "eq." + cmdrName);

    url.setQuery(endpoint);
    QNetworkRequest request(url);
    request.setRawHeader("apikey", m_key.toUtf8());
    request.setRawHeader("Authorization", ("Bearer " + m_key).toUtf8());
    request.setRawHeader("Prefer", "return=representation");
    request.setRawHeader("Cmdr-Name", cmdrName.toUtf8());
    request.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::AlwaysNetwork);
    QNetworkReply *reply = manager.deleteResource(request);
    QObject::connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    QObject::connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
    timer.start(60000);
    loop.exec();
    timer.stop();
    if (!reply->isFinished()) {
        reply->abort();
        QMetaObject::invokeMethod(m_client, "onError",
                                  Qt::QueuedConnection,
                                  Q_ARG(QString, "Could Not Remove Image"),
                                  Q_ARG(QString, "Removing an image"),
                                  Q_ARG(QString, "Timed out"));
        reply->deleteLater();
        return;
    }

    if(reply->error() != QNetworkReply::NoError) {
        QByteArray errorData = reply->readAll();
        QJsonDocument errorDoc = QJsonDocument::fromJson(errorData);
        QString detailedError = errorDoc.object().value("message").toString();
        QString errorMsg = detailedError.isEmpty() ? reply->errorString() : detailedError;
        qWarning() << "Error: " << errorMsg;
        QMetaObject::invokeMethod(m_client, "onError",
                                  Qt::QueuedConnection,
                                  Q_ARG(QString, "Could Not Remove Image"),
                                  Q_ARG(QString, "Removing an image"),
                                  Q_ARG(QString, errorMsg));
        reply->deleteLater();
        return;
    }
    QByteArray responseData = reply->readAll();
    QJsonDocument doc = QJsonDocument::fromJson(responseData);
    QJsonArray arr = doc.array();

    if (arr.isEmpty()) {
        qWarning() << "DELETE Request succeeded, but 0 rows were deleted. URL mismatch?";
        qWarning() << "Tried to delete:" << imageUrl;
    } else {
        qInfo() << "Successfully deleted row(s):" << arr.size();
    }
    reply->deleteLater();
    QMetaObject::invokeMethod(m_client, "onImageRemoved",
                              Qt::QueuedConnection,
                              Q_ARG(QString, imageUrl));
}

void SupabaseTask::run()
{
    qInfo() << this << "Running on: " << QThread::currentThread();

    switch (m_operation) {
    case FETCH_SYSTEMS:
        FetchSystems();
        break;
    case FETCH_CATEGORY_IMAGES:
        FetchCategoryImages();
        break;
    case CLAIM_SYSTEM:
        ClaimSystem();
        break;
    case UNCLAIM_SYSTEM:
        UnclaimSystem();
        break;
    case FETCH_DB_METADATA:
        FetchDbMetaData();
        break;
    case FETCH_CONTRIBUTIONS:
        FetchContributions();
        break;
    case FETCH_SYSTEM_IMAGES:
        FetchSystemImages();
        break;
    case ADD_CONTRIBUTION:
        AddContributions();
        break;
    case UPLOAD_IMAGE:
        UploadImage();
        break;
    case REMOVE_IMAGE:
        RemoveImage();
        break;
    case SHIP_BUILD:
        FetchShipBuild();
        break;
    case FETCH_SINGLE_SYSTEM:
        FetchSingleSystem();
        break;
    }
}
