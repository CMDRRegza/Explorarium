#include "calculationworker.h"

CalculationWorker::CalculationWorker(QList<QVariantMap> systems,
                                     QMap<QString, QStringList> categories,
                                     QMap<QString, QString> claims,
                                     QVariantMap catImages,
                                     QVariantMap contribs,
                                     QVariantMap sysImages,
                                     QMap<QString, QVariantList> bodies,
                                     QMap<QString, QString> gecUrls,
                                     QList<double> coords,
                                     int sortMode)
{
    m_systems = systems;
    m_categories = categories;
    m_claims = claims;
    m_catImages = catImages;
    m_contribs = contribs;
    m_gecUrls = gecUrls;
    m_sysImages = sysImages;
    m_bodies = bodies;
    m_coords = coords;
    m_sortMode = sortMode;
}

void CalculationWorker::run()
{
    QList<QVariantMap> calculatedList;
    for(int i = 0; i < m_systems.size(); i++) {
        QVariantMap system = m_systems[i];
        QString sysName = system["system_name"].toString();

        QStringList catList = m_categories.value(sysName, QStringList());
        system["category"] = catList;
        if (!catList.isEmpty()) {
            system["category_image"] = m_catImages.value(catList.first(), "images/recordsBg.png");
        } else {
            system["category_image"] = "images/recordsBg.png";
        }

        system["claimed_by"] = m_claims.value(sysName, "");
        system["gec_url"] = m_gecUrls.value(sysName, "");


        if (m_contribs.contains(sysName)) {
            QVariantMap c = m_contribs[sysName].toMap();
            system["title"] = c["title"].toString().isEmpty() ? sysName : c["title"];
            system["description"] = c["description"].toString().isEmpty() ? "No description..." : c["description"];
            system["main_image"] = c["main_image_url"].toString().isEmpty() ? system["category_image"] : c["main_image_url"];
            system["cmdr_name"] = c["cmdr_name"].toString().isEmpty() ? "Unknown" : c["cmdr_name"];
        } else {
            system["title"] = sysName;
            system["description"] = "No description available for this system...";
            system["main_image"] = system["category_image"];
            system["cmdr_name"] = "Unknown";
        }

        QVariantList carousel;
        QString mainImg = system["main_image"].toString();
        if (!mainImg.isEmpty()) carousel.append(mainImg);

        if (m_sysImages.contains(sysName)) {
            QVariantList gallery = m_sysImages[sysName].toList();
            for(int i = 0; i < gallery.size(); i++) {
                QVariant v = gallery[i];
                if (v.toString() != mainImg) carousel.append(v);
            }
        }
        system["images"] = carousel;

        system["body_details"] = m_bodies.value(sysName, QVariantList());

        if (m_coords.size() >= 3) {
            double dist = qSqrt(qPow(system["x"].toDouble() - m_coords[0], 2) +
                                qPow(system["y"].toDouble() - m_coords[1], 2) +
                                qPow(system["z"].toDouble() - m_coords[2], 2));

            system["distance_val"] = dist;
            system["distance"] = QString::number(dist, 'f', 1) + " LY";
        } else {
            system["distance_val"] = 99999999.0;
            system["distance"] = "Unknown";
        }

        calculatedList.append(system);
    }

    if (m_sortMode == 0) {
        std::sort(calculatedList.begin(), calculatedList.end(), [](const QVariantMap &a, const QVariantMap &b){
            return a["distance_val"].toDouble() < b["distance_val"].toDouble();
        });
    } else {
        std::sort(calculatedList.begin(), calculatedList.end(), [](const QVariantMap &a, const QVariantMap &b){
            return a["distance_val"].toDouble() > b["distance_val"].toDouble();
        });
    }

    emit resultReady(calculatedList);
}
