#ifndef CALCULATIONWORKER_H
#define CALCULATIONWORKER_H

#include <QObject>
#include <QRunnable>
#include <QVariantMap>
#include <QList>
#include <QtMath>

class CalculationWorker : public QObject, public QRunnable
{
    Q_OBJECT
public:
    CalculationWorker(QList<QVariantMap> systems,
                      QMap<QString, QStringList> categories,
                      QMap<QString, QString> claims,
                      QVariantMap catImages,
                      QVariantMap contribs,
                      QVariantMap sysImages,
                      QMap<QString, QVariantList> bodies,
                      QMap<QString, QString> gecUrls,
                      QList<double> coords,
                      int sortMode);

    void run() override;

signals:
    void resultReady(QList<QVariantMap> sortedList);

private:
    QList<QVariantMap> m_systems;
    QMap<QString, QStringList> m_categories;
    QMap<QString, QString> m_claims;
    QVariantMap m_catImages;
    QVariantMap m_contribs;
    QVariantMap m_sysImages;
    QMap<QString, QString> m_gecUrls;
    QMap<QString, QVariantList> m_bodies;
    QList<double> m_coords;
    int m_sortMode;
};

#endif // CALCULATIONWORKER_H
