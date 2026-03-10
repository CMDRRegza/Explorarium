#include "supabaseclient.h"
#include "supabasetask.h"
#include "imgbbtask.h"
#include "calculationworker.h"
#include <QDebug>
#include <QThreadPool>
#include <QDateTime>
#include <QTimeZone>
#include <QStandardPaths>
#include <QCryptographicHash>
#include <QNetworkAccessManager>
#include <QFileInfo>
#include <QUrl>
#include <QNetworkReply>
#include <QClipboard>
#include <QGuiApplication>
#include <QtConcurrent/QtConcurrentRun>
#include <QJsonArray>

SupabaseClient::SupabaseClient(QObject *parent, JournalManager *manager)
    : QObject{parent}
{
    qInfo() << this << "Constructed";
    m_systemsModel = new SystemsModel(this);
    m_updateTimer = new QTimer(this);
    m_categoryModel = new CategoryModel(this);
    m_systemsModel->setClient(this);
    m_manager = manager;

    QString cacheRoot = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
    m_cachePath = cacheRoot + "/img_cache";

    QDir dir(m_cachePath);
    if(!dir.exists()) {
        dir.mkpath(".");
    }

    connect(this, &SupabaseClient::imageCached, m_systemsModel, [this](){
        emit m_systemsModel->layoutChanged();
    });

    connect(m_manager, &JournalManager::locationChanged, this, &SupabaseClient::MergeAndUpdateModel);
    m_updateTimer->setInterval(60000);
    connect(m_updateTimer, &QTimer::timeout, this, &SupabaseClient::onInterval);
    refresh();
    updateCacheSizeFormatted();
}

void SupabaseClient::fetchAllSystems()
{
    qInfo() << "Fetching all systems from Supabase...";

    SupabaseTask *task = new SupabaseTask(this,
                                          SupabaseTask::FETCH_SYSTEMS,
                                          QVariantMap(),
                                          m_supabaseUrl,
                                          m_anonKey);
    QThreadPool::globalInstance()->start(task);
}

void SupabaseClient::claimSystem(QString systemName, QString cmdrName)
{
    qInfo() << "Uploading: " << systemName << " Using params: " << cmdrName << " To supabase...";
    QVariantMap params;
    params["system_name"] = systemName;
    params["cmdr_name"] = cmdrName;
    params["claimed"] = true;

    SupabaseTask *task = new SupabaseTask(this,
                                          SupabaseTask::CLAIM_SYSTEM,
                                          params,
                                          m_supabaseUrl,
                                          m_anonKey);
    QThreadPool::globalInstance()->start(task);
}

void SupabaseClient::unclaimSystem(QString systemName, QString cmdrName)
{
    qInfo() << "Unclaiming: " << systemName << " Using params: " << cmdrName << " To supabase...";
    QVariantMap params;
    params["system_name"] = systemName;
    params["cmdr_name"] = cmdrName;
    params["claimed"] = false;

    SupabaseTask *task = new SupabaseTask(this,
                                          SupabaseTask::UNCLAIM_SYSTEM,
                                          params,
                                          m_supabaseUrl,
                                          m_anonKey);
    QThreadPool::globalInstance()->start(task);
}

void SupabaseClient::addContribution(QString systemName, QString cmdrName, QString title, QString desc, QString imageUrl)
{
    qInfo() << "Adding contribution for:" << systemName;

    QVariantMap params;
    params["system_name"] = systemName;
    params["cmdr_name"] = cmdrName;
    params["title"] = title;
    params["description"] = desc;
    params["main_image_url"] = imageUrl;
    SupabaseTask *task = new SupabaseTask(this,
                                          SupabaseTask::ADD_CONTRIBUTION,
                                          params,
                                          m_supabaseUrl,
                                          m_anonKey);
    QThreadPool::globalInstance()->start(task);
}

void SupabaseClient::uploadScreenshot(QString systemName, QString cmdrName, QString imageUrl)
{
    qInfo() << "Starting ImgBB upload for:" << imageUrl;
    m_pendingSystem = systemName;
    m_pendingCmdr = cmdrName;
    ImgBBTask *task = new ImgBBTask(this, imageUrl);

    connect(task, &ImgBBTask::UploadFinished, this, &SupabaseClient::onImgbbSuccess);
    connect(task, &ImgBBTask::UploadFailed, this, [=](QString err){
        onError("Uploading Screenshot", "Upload Failed", err);
    });

    QThreadPool::globalInstance()->start(task);
}

double SupabaseClient::getFileSizeMB(const QString &fileUrl)
{
    QUrl url(fileUrl);
    QFileInfo info(url.isLocalFile() ? url.toLocalFile() : fileUrl);
    return info.size() / (1024.0 * 1024.0);
}

QString SupabaseClient::getCachedImage(QString url)
{
    if(url.isEmpty()) return "images/recordsBg.png";
    if(!url.startsWith("http")) return url;

    QString localpath = getLocalPathFromUrl(url);
    if(QFile::exists(localpath)) {
        return "file:///" + localpath;
    }

    if(!m_activeDownloads.contains(url)) {
        downloadImage(url);
    }

    return "images/recordsBg.png";
}

void SupabaseClient::fetchCategoryImages()
{
    qInfo() << "Fetching category images from Supabase...";

    SupabaseTask *task = new SupabaseTask(this,
                                          SupabaseTask::FETCH_CATEGORY_IMAGES,
                                          QVariantMap(),
                                          m_supabaseUrl,
                                          m_anonKey);
    QThreadPool::globalInstance()->start(task);
}

void SupabaseClient::fetchDbData()
{
    qInfo() << "Fetching database data from Supabase...";

    SupabaseTask *task = new SupabaseTask(this,
                                          SupabaseTask::FETCH_DB_METADATA,
                                          QVariantMap(),
                                          m_supabaseUrl,
                                          m_anonKey);
    QThreadPool::globalInstance()->start(task);
}

void SupabaseClient::fetchSystemStatus(const QString &systemName, const qint64 &id64)
{
    qInfo() << "Fetching live status for:" << systemName;
    m_pendingSystem = systemName;

    QVariantMap params;
    params["system_name"] = systemName;
    params["id64"] = id64;

    SupabaseTask *task = new SupabaseTask(this,
                                          SupabaseTask::FETCH_SINGLE_SYSTEM,
                                          params,
                                          m_supabaseUrl,
                                          m_anonKey);
    QThreadPool::globalInstance()->start(task);
}

void SupabaseClient::removeCache()
{
    QDir dir(m_cachePath);
    if(dir.exists()) {
        dir.removeRecursively();
    } else {
        qWarning() << "Doesn't exist... creating now";
    }

    dir.mkpath(".");
    updateCacheSizeFormatted();
}

QVariantList SupabaseClient::rawSystems() const
{
    QVariantList list;
    list.reserve(m_allSystems.size());
    for (qsizetype i = 0; i < m_allSystems.size(); i++) {
        QVariantMap map = m_allSystems[i];
        QString system_name = map["system_name"].toString();
        if(m_systemCategory.contains(system_name)) {
            map["category"] = m_systemCategory.value(system_name);
        } else {
            map["category"] = QStringList();
        }
        list.append(map);
    }
    return list;
}

void SupabaseClient::fetchShipData()
{
    qInfo() << "Fetching ship data from Supabase...";
    SupabaseTask *task = new SupabaseTask(this,
                                          SupabaseTask::SHIP_BUILD,
                                          QVariantMap(),
                                          m_supabaseUrl,
                                          m_anonKey);
    QThreadPool::globalInstance()->start(task);
}

void SupabaseClient::fetchContributions()
{
    qInfo() << "Fetching contribution data from Supabase...";
    SupabaseTask *task = new SupabaseTask(this,
                                          SupabaseTask::FETCH_CONTRIBUTIONS,
                                          QVariantMap(),
                                          m_supabaseUrl,
                                          m_anonKey);
    QThreadPool::globalInstance()->start(task);
}

void SupabaseClient::saveSystemImage(QString systemName, QString cmdrName, QString imageUrl)
{
    qInfo() << "Manually saving image to DB:" << imageUrl;
    QVariantMap params;
    params["system_name"] = systemName;
    params["uploaded_by"] = cmdrName;
    params["image_url"] = imageUrl;

    SupabaseTask *task = new SupabaseTask(this,
                                          SupabaseTask::UPLOAD_IMAGE,
                                          params,
                                          m_supabaseUrl,
                                          m_anonKey);
    QThreadPool::globalInstance()->start(task);
}

void SupabaseClient::fetchSystemImages()
{
    qInfo() << "Fetching image data from Supabase...";
    SupabaseTask *task = new SupabaseTask(this,
                                          SupabaseTask::FETCH_SYSTEM_IMAGES,
                                          QVariantMap(),
                                          m_supabaseUrl,
                                          m_anonKey);
    QThreadPool::globalInstance()->start(task);
}

void SupabaseClient::removeScreenshot(QString systemName, QString cmdrName, QString imageUrl)
{
    qInfo() << "Preparing to remove image link:" << imageUrl;

    QVariantMap params;
    params["system_name"] = systemName;
    params["cmdr_name"] = cmdrName;
    params["image_url"] = imageUrl;

    SupabaseTask *task = new SupabaseTask(this,
                                          SupabaseTask::REMOVE_IMAGE,
                                          params,
                                          m_supabaseUrl,
                                          m_anonKey);
    QThreadPool::globalInstance()->start(task);
}

void SupabaseClient::refresh()
{
    m_catred = false;
    m_sysred = false;
    m_contred = false;
    m_imagred = false;

    fetchAllSystems();
    fetchCategoryImages();
    fetchDbData();
    fetchContributions();
    fetchSystemImages();
}

void SupabaseClient::texttoClipboard(QString text)
{
    QClipboard *clipboard = QGuiApplication::clipboard();
    clipboard->setText(text);
    qInfo() << "Set text to clipboard:" << text;
}

QVariantMap SupabaseClient::getSystem(QString systemName)
{
    return m_mergedCache.value(systemName, QVariantMap());
}

int SupabaseClient::YourClaimed() const
{
    QString myName = m_manager->commanderName();
    int count = 0;

    auto i = m_claimsMap.constBegin();
    while(i != m_claimsMap.constEnd()) {
        if(i.value() == myName) {
            count++;
        }
        i++;
    }
    return count;
}

double SupabaseClient::calculateDistance(double x, double y, double z, double cmdrX, double cmdrY, double cmdrZ)
{
    double dx = x - cmdrX;
    double dy = y - cmdrY;
    double dz = z - cmdrZ;
    return qSqrt(dx*dx + dy*dy + dz*dz);
}

// void SupabaseClient::onSystemsLoaded(QVariantList systems, QVariantList claims, QVariantList)
// {
//     m_allSystems.clear();
//     m_systemCategory.clear();
//     m_systemBodyDetails.clear();

//     for(int i = 0; i < systems.size(); i++) {
//         QVariantMap row = systems[i].toMap();
//         QString name = row["system_name"].toString();

//         QString rawCat = row["category"].toString();
//         QStringList systemTags = rawCat.split(",", Qt::SkipEmptyParts);
//         for(QString &t : systemTags) t = t.trimmed();

//         m_systemCategory[name] = systemTags;
//         m_allSystems.append(row);

//         QVariant bodiesVar = row["bodies"];
//         QVariantList bodiesList = bodiesVar.toList();

//         for(int t = 0; t < systemTags.size(); t++) {
//             QString currentTag = systemTags[t];
//             QString combinedBodyText = "";

//             for(int b = 0; b < bodiesList.size(); b++) {
//                 QVariantMap bodyData = bodiesList[b].toMap();

//                 if(bodyData.contains("name")) {
//                     combinedBodyText += "[" + bodyData["name"].toString() + "]\n";
//                 } else if(bodyData.contains("BodyName")) {
//                     combinedBodyText += "[" + bodyData["BodyName"].toString() + "]\n";
//                 }

//                 const QList<QString> keys = bodyData.keys();
//                 for(const QString &key : keys) {
//                     if (key == "name" || key == "BodyName") continue;

//                     QVariant val = bodyData.value(key);

//                     if (val.isNull()) {
//                         continue;
//                     }

//                     if (val.typeId() == QMetaType::QString && val.toString().isEmpty()) {
//                         continue;
//                     }

//                     if (val.userType() == QMetaType::QVariantList) {
//                         combinedBodyText += "• " + key + " :\n";
//                         QVariantList subList = val.toList();

//                         for(int l = 0; l < subList.size(); l++) {
//                             QVariant subItem = subList[l];
//                             if(subItem.userType() == QMetaType::QVariantMap) {
//                                 QVariantMap subMap = subItem.toMap();
//                                 for(auto it = subMap.begin(); it != subMap.end(); ++it) {
//                                     combinedBodyText += "    - " + it.key() + " : " + it.value().toString() + "\n";
//                                 }
//                             } else {
//                                 combinedBodyText += "    - " + subItem.toString() + "\n";
//                             }
//                         }
//                     } else {
//                         combinedBodyText += "• " + key + " : " + val.toString() + "\n";
//                     }
//                 }
//                 combinedBodyText += "\n";
//             }

//             qDebug() << "\n=== FULL CARD CONTENT FOR:" << name << "[" << currentTag << "] ===";
//             qDebug().noquote() << combinedBodyText;
//             qDebug() << "==========================================\n";

//             QVariantMap card;
//             card["tag"] = currentTag;
//             card["body"] = combinedBodyText.trimmed();

//             QVariantList currentStack = m_systemBodyDetails[name].toList();
//             currentStack.append(card);
//             m_systemBodyDetails[name] = currentStack;
//         }
//     }

//     QMap<QString, QString> claimsMap;
//     for(int i = 0; i < claims.size(); i++) {
//         QVariantMap c = claims[i].toMap();
//         claimsMap[c["system_name"].toString()] = c["cmdr_name"].toString();
//     }
//     m_claimsMap = claimsMap;

//     emit systemsLoaded();
//     emit ClaimCountChanged();
//     m_sysred = true;
//     if (m_catred && m_sysred && m_contred && m_imagred) {
//         MergeAndUpdateModel();
//     }
// }

void SupabaseClient::onSystemsLoaded(QVariantList systems, QVariantList claims, QVariantList)
{
    m_allSystems.clear();
    m_systemCategory.clear();
    m_systemBodyDetails.clear();

    QSet<QString> processedSystemsForList;

    for(int i = 0; i < systems.size(); i++) {
        QVariantMap row = systems[i].toMap();
        QString name = row["system_name"].toString();

        if (!processedSystemsForList.contains(name)) {
            m_allSystems.append(row);
            processedSystemsForList.insert(name);
        }

        QString rawCat = row["category"].toString();
        QStringList rowTags = rawCat.split(",", Qt::SkipEmptyParts);
        for(QString &t : rowTags) t = t.trimmed();

        QStringList allKnownTags = m_systemCategory[name];
        for(const QString &t : std::as_const(rowTags)) {
            if(!allKnownTags.contains(t)) {
                allKnownTags.append(t);
            }
        }
        m_systemCategory[name] = allKnownTags;

        QVariant bodiesVar = row["bodies"];
        QVariantList bodiesList = bodiesVar.toList();

        for(int t = 0; t < rowTags.size(); t++) {
            QString currentTag = rowTags[t];
            QString combinedBodyText = "";

            for(int b = 0; b < bodiesList.size(); b++) {
                QVariantMap bodyData = bodiesList[b].toMap();

                if(bodyData.contains("name")) {
                    combinedBodyText += "[" + bodyData["name"].toString() + "]\n";
                } else if(bodyData.contains("BodyName")) {
                    combinedBodyText += "[" + bodyData["BodyName"].toString() + "]\n";
                }

                const QList<QString> keys = bodyData.keys();
                for(const QString &key : keys) {
                    if (key == "name" || key == "BodyName") continue;

                    QVariant val = bodyData.value(key);

                    if (val.isNull()) continue; // Skip nulls

                    if (val.userType() == QMetaType::QVariantList) {
                        combinedBodyText += "• " + key + " :\n";
                        QVariantList subList = val.toList();

                        for(int l = 0; l < subList.size(); l++) {
                            QVariant subItem = subList[l];
                            if(subItem.userType() == QMetaType::QVariantMap) {
                                QVariantMap subMap = subItem.toMap();
                                for(auto it = subMap.begin(); it != subMap.end(); ++it) {
                                    combinedBodyText += "    - " + it.key() + " : " + it.value().toString() + "\n";
                                }
                            } else {
                                combinedBodyText += "    - " + subItem.toString() + "\n";
                            }
                        }
                    } else {
                        combinedBodyText += "• " + key + " : " + val.toString() + "\n";
                    }
                }
                combinedBodyText += "\n";
            }

            QVariantMap card;
            card["tag"] = currentTag;
            card["body"] = combinedBodyText.trimmed();

            QVariantList currentStack = m_systemBodyDetails[name].toList();
            currentStack.append(card);
            m_systemBodyDetails[name] = currentStack;
        }
    }

    QMap<QString, QString> claimsMap;
    for(int i = 0; i < claims.size(); i++) {
        QVariantMap c = claims[i].toMap();
        claimsMap[c["system_name"].toString()] = c["cmdr_name"].toString();
    }
    m_claimsMap = claimsMap;

    emit systemsLoaded();
    emit ClaimCountChanged();
    m_sysred = true;
    if (m_catred && m_sysred && m_contred && m_imagred) {
        MergeAndUpdateModel();
    }
}

void SupabaseClient::onCategoryLoaded(QVariantMap categoryImages)
{
    m_categoryImages = categoryImages;

    QList<QVariantMap> categoryList;
    for(auto it = categoryImages.begin(); it != categoryImages.end(); ++it) {
        QVariantMap item;
        item["category_name"] = it.key();
        item["category_image"] = it.value();
        categoryList.append(item);
    }
    m_categoryModel->setCategoryData(categoryList);

    qInfo() << "Category images loaded:" << m_categoryImages.size() << "categories";
    m_catred = true;
    if (m_catred && m_sysred && m_contred && m_imagred) {
        MergeAndUpdateModel();
    }
    emit categoryImagesChanged();
}

void SupabaseClient::MergeAndUpdateModel()
{
    CalculationWorker* worker = new CalculationWorker(
        m_allSystems,
        m_systemCategory,
        m_claimsMap,
        m_categoryImages,
        m_contributions,
        m_systemImages,
        m_systemBodyDetails,
        m_gecUrlsMap,
        m_manager->coordinates(),
        (int)m_sortMode
        );
    connect(worker, &CalculationWorker::resultReady, this, &SupabaseClient::onWorkerFinished);
    worker->setAutoDelete(true);
    QThreadPool::globalInstance()->start(worker);

    // m_mergedCache.clear();

    // QList<QVariantMap> mergedSystems;
    // for(int i = 0; i < m_allSystems.size(); i++) {
    //     QVariantMap system = m_allSystems[i];
    //     QString sysName = system["system_name"].toString();


    //     //category image


    //     system["category"] = m_systemCategory.value(sysName, QStringList());
    //     system["claimed_by"] = m_claimsMap.value(sysName, "");
    //     QStringList systemCategory = m_systemCategory.value(sysName, QStringList());
    //     if (!systemCategory.isEmpty()) {
    //         QString firstTag = systemCategory.first();
    //         system["category_image"] = m_categoryImages.value(firstTag, "images/recordsBg.png");
    //     } else {
    //         system["category_image"] = "images/recordsBg.png";
    //     }


    //     //contribs


    //     if(m_contributions.contains(sysName)) {
    //         QVariantMap contrib = m_contributions[sysName].toMap();

    //         QString contribTitle = contrib["title"].toString();
    //         if (contribTitle.isEmpty()) {
    //             system["title"] = sysName;
    //         } else {
    //             system["title"] = contribTitle;
    //         }

    //         QString contribDesc = contrib["description"].toString();
    //         if (contribDesc.isEmpty()) {
    //             system["description"] = "No description available.";
    //         } else {
    //             system["description"] = contribDesc;
    //         }

    //         QString contribImg = contrib["main_image_url"].toString();
    //         if (contribImg.isEmpty()) {
    //             system["main_image"] = system["category_image"];
    //         } else {
    //             system["main_image"] = contribImg;
    //         }

    //         QString cmdrname = contrib["cmdr_name"].toString();
    //         if(cmdrname.isEmpty()) {
    //             system["cmdr_name"] = "Unknown";
    //         } else {
    //             system["cmdr_name"] = cmdrname;
    //         }
    //     } else {
    //         system["title"] = sysName;
    //         system["description"] = "No description available for this system...";
    //         system["main_image"] = system["category_image"];
    //         system["cmdr_name"] = "Unknown";
    //     }


    //     // images


    //     QVariantList carouselList;
    //     QString mainImg = system["main_image"].toString();

    //     if (!mainImg.isEmpty()) {
    //         carouselList.append(mainImg);
    //     }

    //     if(m_systemImages.contains(sysName)) {
    //         QVariantList galleryList = m_systemImages[sysName].toList();

    //         for (int k = 0; k < galleryList.size(); k++) {
    //             QString imgUrl = galleryList[k].toString();
    //             if (imgUrl != mainImg) {
    //                 carouselList.append(imgUrl);
    //             }
    //         }
    //     }

    //     system["images"] = carouselList;

    //     //body details

    //     if (m_systemBodyDetails.contains(sysName)) {
    //         system["body_details"] = m_systemBodyDetails[sysName];
    //     } else {
    //         system["body_details"] = QVariantList();
    //     }

    //     QList<double> cmdrCoords = m_manager->coordinates();
    //     if (cmdrCoords.size() >= 3) {
    //         double sysX = system["x"].toDouble();
    //         double sysY = system["y"].toDouble();
    //         double sysZ = system["z"].toDouble();

    //         double distance = calculateDistance(sysX, sysY, sysZ,
    //                                             cmdrCoords[0], cmdrCoords[1], cmdrCoords[2]);

    //         system["distance"] = QString::number(distance, 'f', 1) + " LY";
    //     } else {
    //         system["distance"] = "Unknown";
    //     }
    //     m_mergedCache[sysName] = system;
    //     mergedSystems.append(system);
    // }
    // switch(m_sortMode) {
    // case SortMode::SortByClosestDistance:
    //     std::sort(mergedSystems.begin(), mergedSystems.end(),
    //               [](const QVariantMap &a, const QVariantMap &b) {
    //                   QString distA = a["distance"].toString();
    //                   QString distB = b["distance"].toString();

    //                   double numA = distA.split(" ")[0].toDouble();
    //                   double numB = distB.split(" ")[0].toDouble();

    //                   return numA < numB;
    //               });
    //     break;

    // case SortMode::SortByFurthestDistance:
    //     std::sort(mergedSystems.begin(), mergedSystems.end(),
    //               [](const QVariantMap &a, const QVariantMap &b) {
    //                   QString distA = a["distance"].toString();
    //                   QString distB = b["distance"].toString();

    //                   double numA = distA.split(" ")[0].toDouble();
    //                   double numB = distB.split(" ")[0].toDouble();

    //                   return numA > numB;
    //               });
    //     break;
    // }

    // m_systemsModel->setSystemsData(mergedSystems);
    // emit systemsLoaded();
    // if(!m_initialLoadComplete) {
    //     m_initialLoadComplete = true;
    //     emit supabaseClientComplete();
    // }
}

void SupabaseClient::onClaimSuccess(QString systemName, QString cmdrName)
{
    qInfo() << "Claim is successful! " << systemName;
    emit claimUpdated(true, QString("claimed_" + systemName));
    m_claimsMap[systemName] = cmdrName;
    emit ClaimCountChanged();
    MergeAndUpdateModel();
}

void SupabaseClient::onContributionsLoaded(QVariantList contributions)
{
    m_contributions.clear();

    for(int i = 0; i < contributions.size(); i++) {
        QVariantMap row = contributions[i].toMap();
        QString sysName = row["system_name"].toString();

        m_contributions.insert(sysName, row);
    }

    qInfo() << "Mapped" << m_contributions.size() << "contributions";
    m_contred = true;
    if (m_catred && m_sysred && m_contred && m_imagred) {
        MergeAndUpdateModel();
    }
}

void SupabaseClient::onImagesLoaded(QVariantList images)
{
    m_systemImages.clear();

    for(int i = 0; i < images.size(); i++) {
        QVariantMap row = images[i].toMap();
        QString sysName = row["system_name"].toString();
        QString url = row["image_url"].toString();

        QVariantList currentList = m_systemImages[sysName].toList();
        currentList.append(url);
        m_systemImages[sysName] = currentList;
    }

    qInfo() << "Mapped images for" << m_systemImages.size() << "systems";
    m_imagred = true;
    if (m_catred && m_sysred && m_contred && m_imagred) {
        MergeAndUpdateModel();
    }
}

void SupabaseClient::onUnclaimSuccess(QString systemName)
{
    qInfo() << "Unclaim is successful! " << systemName;
    emit claimUpdated(true, QString("unclaimed_" + systemName));
    m_claimsMap.remove(systemName);
    emit ClaimCountChanged();
    MergeAndUpdateModel();
}

void SupabaseClient::onWorkerFinished(QList<QVariantMap> sortedList)
{
    m_mergedCache.clear();
    for(const QVariantMap &map : sortedList) {
        m_mergedCache[map["system_name"].toString()] = map;
    }

    m_systemsModel->setSystemsData(sortedList);
    emit systemsLoaded();

    if(!m_initialLoadComplete) {
        m_initialLoadComplete = true;
        emit supabaseClientComplete();
    }
}

void SupabaseClient::onImageRemoved(QString url)
{
    qInfo() << "Image remove is successful!";
    for (auto it = m_systemImages.begin(); it != m_systemImages.end(); ++it) {
        QVariantList imageList = it.value().toList();
        if (imageList.contains(url)) {
            imageList.removeOne(url);
            m_systemImages.insert(it.key(), imageList);
            MergeAndUpdateModel();
            return;
        }
    }
}

void SupabaseClient::onInterval()
{
    QDateTime dbTime = QDateTime::fromString(m_lastupdated, Qt::ISODate);
    dbTime.setTimeZone(QTimeZone::utc());
    dbTime = dbTime.toLocalTime();
    QDateTime now = QDateTime::currentDateTime();
    qint64 seconds = dbTime.secsTo(now);

    if (seconds < 60) {
        m_time = QString::number(seconds) + " seconds ago";
    } else if (seconds < 3600) {
        int minutes = seconds / 60;
        m_time = QString::number(minutes) + " minutes ago";
    } else if (seconds < 86400) {
        int hours = seconds / 3600;
        m_time = QString::number(hours) + " hours ago";
    } else {
        int days = seconds / 86400;
        m_time = QString::number(days) + " days ago";
    }
    emit TimeChanged();
    if(m_isnew == false) {
        fetchDbData();
    } else {
        m_isnew = !m_isnew;
        return;
    }
}

void SupabaseClient::onShipBuildLoaded(QJsonArray data)
{
    qInfo() << "Successfully downloaded.. Throwing to spanshplotter.";       
    emit shipbuildloadedez(data);
}

void SupabaseClient::setSortMode(SupabaseClient::SortMode mode)
{
    if(mode != m_sortMode) {
        m_sortMode = mode;
        qInfo() << "Changed m_sortMode to " << mode;
        MergeAndUpdateModel();
        emit SortModeChanged();
    }
}

void SupabaseClient::onDbLoaded(QVariantList data)
{
    if(!data.isEmpty()) {
        m_newthisweek = data[0].toInt();
        QString lastupdated = data[1].toString();
        if (!m_lastupdated.isEmpty() && m_lastupdated != lastupdated) {
            refresh();
        }
        if(m_lastupdated.isEmpty()) {
            m_lastupdated = lastupdated;
            onInterval();
            m_updateTimer->start();
        }
        m_lastupdated = lastupdated;
        emit dbDataChanged();
    }
}

void SupabaseClient::onError(QString title, QString operation, QString error)
{
    qWarning() << "Error during: " << operation << " With error: " << error;
    emit errorOccurred(error, title, operation);
}

void SupabaseClient::onBackError(QString operation, QString title, QString error)
{
    qInfo() << operation << title << error;
    emit backerroroccurred(operation, title, error);
}

void SupabaseClient::onContributionsAdded(QVariantMap data)
{
    QString sysName = data["system_name"].toString();
    qInfo() << "Contribution added successfully for" << sysName;

    m_contributions.insert(sysName, data);
    MergeAndUpdateModel();
    emit contributionUpdated(sysName);
}

void SupabaseClient::onSingleSystemLoaded(QVariantMap data)
{
    qInfo() << data;
    QString systemName;
    QVariantMap claimsRow = data["claims"].toMap();
    if (!claimsRow.isEmpty()) {
        systemName = claimsRow["system_name"].toString();
    } else if (!data["user_contributions"].toMap().isEmpty()) {
        systemName = data["user_contributions"].toMap()["system_name"].toString();
    } else if (!m_pendingSystem.isEmpty()) {
        systemName = m_pendingSystem;
        m_pendingSystem.clear();
    } else {
        qInfo() << "Received single system update but couldn't identify the system name. ";
    }

    qInfo() << "Updating local cache for " << systemName;

    if (claimsRow.isEmpty()) { // Checking for claims. If empty remove it from the map.
        if (m_claimsMap.contains(systemName)) m_claimsMap.remove(systemName);
    } else {
        m_claimsMap.insert(systemName, claimsRow["cmdr_name"].toString());
    }

    QVariantMap contribRow = data["user_contributions"].toMap();
    if (contribRow.isEmpty()) { // Contributions, same logic.
        if (m_contributions.contains(systemName)) m_contributions.remove(systemName);
    } else {
        m_contributions.insert(systemName, contribRow);
    }

    QVariantList imgRows = data["system_images"].toList();
    QVariantList cleanUrls;
    for(int i = 0; i < imgRows.size(); i++) {
        QVariant v = imgRows[i];
        cleanUrls.append(v.toMap()["image_url"].toString());
    }
    m_systemImages.insert(systemName, cleanUrls);

    QString gecUrl = data.value("gec_url").toString();
    if (gecUrl.isEmpty()) {
        m_gecUrlsMap.remove(systemName);
    } else {
        m_gecUrlsMap.insert(systemName, gecUrl);
    }

    MergeAndUpdateModel(); // automatically updates m_mergedCache. Most important line here.

    emit singleSystemDataUpdated(systemName); // Asks Ui to update itself.
}

void SupabaseClient::onImgbbSuccess(QString link)
{
    qInfo() << "Image hosted successfully at:" << link << "Saving link to Supabase.";
    emit screenshotReady(link);
    m_pendingSystem.clear();
    m_pendingCmdr.clear();
}

void SupabaseClient::onImageSaved(QVariantMap confirmedData)
{
    QString sysName = confirmedData["system_name"].toString();
    QString newUrl = confirmedData["image_url"].toString();

    qInfo() << "Image link saved to DB. Updating local cache for:" << sysName;

    QVariantList currentList = m_systemImages.value(sysName).toList();
    currentList.append(newUrl);
    m_systemImages.insert(sysName, currentList);
    MergeAndUpdateModel();
}

QString SupabaseClient::getLocalPathFromUrl(QString url)
{
    QByteArray hash = QCryptographicHash::hash(url.toUtf8(), QCryptographicHash::Md5);
    QString filename = hash.toHex();

    QUrl qUrl(url);
    QFileInfo info(qUrl.path());
    QString extension = info.suffix();

    if (extension.isEmpty() || extension.length() > 4) {
        extension = "jpg";
    }

    return QDir::cleanPath(m_cachePath + QDir::separator() + filename + "." + extension);
}

void SupabaseClient::updateCacheSizeFormatted()
{
    qint64 totalsize = 0;
    QDir dir(m_cachePath);

    if(dir.exists()) {
        QFileInfoList list = dir.entryInfoList(QDir::Files);
        for(int i = 0; i < list.size(); i++) {
            QFileInfo file = list[i];
            totalsize += file.size();
        }
    }

    QString string = QString();
    if(totalsize < 1024) {
        string = QString::number(totalsize) + " B";
    } else if(totalsize < 1024 * 1024) {
        string = QString::number(totalsize / 1024.0, 'f', 1) + " KB";
    } else {
        string = QString::number(totalsize / (1024.0 * 1024.0), 'f', 1) + " MB";
    }

    if(m_cacheSize != string) {
        m_cacheSize = string;
        emit cacheSizeChanged();
    }
}

void SupabaseClient::downloadImage(QString url)
{
    if (m_activeDownloads.contains(url)) return;
    m_activeDownloads.insert(url);
    QNetworkAccessManager *netManager = new QNetworkAccessManager(this);
    QNetworkRequest request(url);

    request.setHeader(QNetworkRequest::UserAgentHeader,
                      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36");
    request.setRawHeader("Referer", "https://www.imghippo.com/");
    request.setAttribute(QNetworkRequest::RedirectPolicyAttribute, QNetworkRequest::NoLessSafeRedirectPolicy);

    QNetworkReply *reply = netManager->get(request);

    connect(reply, &QNetworkReply::finished, this, [=]() {

        if (reply->error() != QNetworkReply::NoError) {
            qWarning() << "Download Error:" << url << "Reason:" << reply->errorString();
            m_activeDownloads.remove(url);
            reply->deleteLater();
            netManager->deleteLater();
            return;
        }

        int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        if (statusCode != 200 && statusCode != 301 && statusCode != 302) {
            qWarning() << "HTTP Error" << statusCode << ":" << url;
            m_activeDownloads.remove(url);
            reply->deleteLater();
            netManager->deleteLater();
            return;
        }

        QString savePath = getLocalPathFromUrl(url);
        QFile file(savePath);

        QByteArray data = reply->readAll();
        if (data.isEmpty()) {
            qWarning() << "Received empty data for:" << url;
            m_activeDownloads.remove(url);
            reply->deleteLater();
            netManager->deleteLater();
            return;
        }

        if (file.open(QIODevice::WriteOnly)) {
            file.write(data);
            file.close();
            updateCacheSizeFormatted();
            qInfo() << "Cached:" << url << "to" << savePath;

            emit imageCached(url);
        } else {
            qWarning() << "File Write Error:" << file.errorString() << "Path:" << savePath;
        }

        m_activeDownloads.remove(url);
        reply->deleteLater();
        netManager->deleteLater();
    });
}
