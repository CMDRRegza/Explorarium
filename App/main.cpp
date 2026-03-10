// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>
#include <QSslConfiguration>
#include <QtGlobal>
#include <QQuickWindow>

#include "autogen/environment.h"
#include "loadingscreenmanager.h"
#include "supabaseclient.h"
#include "journalmanager.h"
#include "categoryfilterproxy.h"
#include "galaxymapitem.h"
#include "spanshplotter.h"

int main(int argc, char *argv[])
{
    set_qt_environment();
    QApplication app(argc, argv);
    qRegisterMetaType<QList<QVariantMap>>("QList<QVariantMap>");
    qRegisterMetaType<QJsonArray>("QJsonArray");
    app.setWindowIcon(QIcon(":/qt/qml/ExplorariumContent/images/logo.png"));
    app.setOrganizationName("Explorarium");
    app.setApplicationName("ExplorariumApp");
    app.setApplicationVersion("v1.0-beta");

    QQmlApplicationEngine engine;
    LoadingScreenManager *manager = new LoadingScreenManager(&app);
    JournalManager *jmanager = new JournalManager(&app);
    SupabaseClient *smanager = new SupabaseClient(&app, jmanager);
    CategoryFilterProxy *pmanager = new CategoryFilterProxy(&app);
    SpanshPlotter *spmanager = new SpanshPlotter(&app);
    pmanager->setSourceModel(smanager->systemsModel());

    QObject::connect(smanager, &SupabaseClient::backerroroccurred, spmanager, &SpanshPlotter::error);
    QObject::connect(jmanager, &JournalManager::targetEvent, spmanager, &SpanshPlotter::gotTargetEvent);
    QObject::connect(smanager, &SupabaseClient::shipbuildloadedez, spmanager, &SpanshPlotter::loadingbaydataplease);
    smanager->fetchShipData();
    QObject::connect(smanager, &SupabaseClient::supabaseClientComplete, manager,
                     &LoadingScreenManager::supabaseClientCompleted);

    jmanager->onNewFile();

    const QUrl url("qrc:/qt/qml/ExplorariumContent/App.qml");
    QObject::connect(
                &engine, &QQmlApplicationEngine::objectCreated, &app,
                [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.rootContext()->setContextProperty("loadingScreenManager", manager);
    engine.rootContext()->setContextProperty("JournalManager", jmanager);
    engine.rootContext()->setContextProperty("SupabaseClient", smanager);
    engine.rootContext()->setContextProperty("applicationVersion", app.applicationVersion());
    engine.rootContext()->setContextProperty("CategoryProxy", pmanager);
    engine.rootContext()->setContextProperty("SpanshPlotter", spmanager);

    qmlRegisterType<GalaxyMapItem>("Explorarium.Native", 1, 0, "GalaxyMap");

    engine.addImportPath(QCoreApplication::applicationDirPath() + "/qml");
    engine.addImportPath(":/");
    engine.load(url);
    engine.load("qrc:/qt/qml/ExplorariumContent/LoadingScreen.qml");
    engine.load("qrc:/qt/qml/ExplorariumContent/PopupWindow.qml");
    for (QObject *obj : engine.rootObjects()) {
        if (obj->objectName() == "PopupWindow") {
            if (auto *win = qobject_cast<QQuickWindow *>(obj)) {
                win->setFlag(Qt::WindowTransparentForInput, true);
            }
            break;
        }
    }

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
