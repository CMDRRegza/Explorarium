#ifndef ROUTETASK_H
#define ROUTETASK_H

#include <QObject>
#include <QRunnable>
#include <QVariantMap>
#include <QJsonObject>
#include <QJsonArray>
#include "spanshplotter.h"

class RouteTask : public QObject, public QRunnable
{
    Q_OBJECT
public:
    RouteTask(SpanshPlotter *manager, QString sourceSystem,
              QString destinationSystem,
              QJsonObject shipBuild,
              QVariantMap constParams, QJsonArray shipData);
    void run() override;
signals:
    void routeReady(QVariantMap result);
    void routeError(QString title, QString context, QString details);
private:
    SpanshPlotter *m_manager;
    QString m_source;
    QString m_destination;
    QJsonObject m_shipBuild;
    QVariantMap m_constParams;
    QJsonArray m_shipData;
    int m_superchargeMultiplier = 4;
    int m_injectionMultipler = 2;

    QJsonObject extractShipBuild(QString value);
    double jsonToDouble(const QJsonValue &v, double fallback = 0.0);
    double optimalMassGrabber();

    const QString m_link = "https://spansh.co.uk/api/generic/route";
    const QString m_results = "https://spansh.co.uk/api/results/";
};

#endif // ROUTETASK_H
