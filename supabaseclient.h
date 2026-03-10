#ifndef SUPABASECLIENT_H
#define SUPABASECLIENT_H

#include <QObject>
#include "categorymodel.h"
#include "systemsmodel.h"
#include "journalmanager.h"
#include <QTimer>

class SupabaseClient : public QObject
{
    Q_OBJECT
    Q_PROPERTY(SystemsModel *systemsModel READ systemsModel CONSTANT)
    Q_PROPERTY(CategoryModel *categoryModel READ categoryModel CONSTANT)
    Q_PROPERTY(QVariantMap categoryImages READ categoryImages NOTIFY categoryImagesChanged FINAL)
    Q_PROPERTY(int NewThisWeek READ newthisweek NOTIFY dbDataChanged FINAL)
    Q_PROPERTY(QString lastUpdated READ lastUpdated NOTIFY TimeChanged FINAL)
    Q_PROPERTY(SortMode sortMode READ sort WRITE setSortMode NOTIFY SortModeChanged FINAL)
    Q_PROPERTY(int totalSystems READ totalSystems NOTIFY systemsLoaded FINAL)
    Q_PROPERTY(QString cacheSize READ cacheSizeString NOTIFY cacheSizeChanged FINAL)
    Q_PROPERTY(QVariantList rawSystems READ rawSystems NOTIFY systemsLoaded)
    Q_PROPERTY(int YourClaimed READ YourClaimed NOTIFY ClaimCountChanged FINAL)
    Q_PROPERTY(int ClaimedSystems READ ClaimedSystems NOTIFY ClaimCountChanged FINAL)
public:
    enum SortMode {
        SortByClosestDistance,
        SortByFurthestDistance // more later
    };
    Q_ENUM(SortMode)
    explicit SupabaseClient(QObject *parent = nullptr, JournalManager *manager = nullptr);
    Q_INVOKABLE void fetchAllSystems();
    Q_INVOKABLE void claimSystem(QString systemName, QString cmdrName);
    Q_INVOKABLE void unclaimSystem(QString systemName, QString cmdrName);
    Q_INVOKABLE void addContribution(QString systemName, QString cmdrName, QString title,
                                     QString desc, QString imageUrl);
    Q_INVOKABLE void uploadScreenshot(QString systemName, QString cmdrName, QString imageUrl);
    Q_INVOKABLE double getFileSizeMB(const QString &fileUrl);
    Q_INVOKABLE QString getCachedImage(QString url);
    Q_INVOKABLE void fetchCategoryImages();
    Q_INVOKABLE void fetchDbData();
    Q_INVOKABLE void fetchSystemStatus(const QString &systemName, const qint64 &id64);
    Q_INVOKABLE void removeCache();
    QVariantList rawSystems() const;
    void fetchShipData();
    Q_INVOKABLE void fetchContributions();
    Q_INVOKABLE void saveSystemImage(QString systemName, QString cmdrName, QString imageUrl);
    Q_INVOKABLE void fetchSystemImages();
    Q_INVOKABLE void removeScreenshot(QString systemName, QString cmdrName, QString imageUrl);
    Q_INVOKABLE void refresh();
    Q_INVOKABLE void texttoClipboard(QString text);
    Q_INVOKABLE QVariantMap getSystem(QString systemName);
    SystemsModel* systemsModel() const { return m_systemsModel; }
    CategoryModel* categoryModel() const { return m_categoryModel; }
    int YourClaimed() const;
    int ClaimedSystems() const { return m_claimsMap.size(); }
    int newthisweek() const { return m_newthisweek; }
    int totalSystems() const { return m_allSystems.size(); }
    QVariantMap categoryImages() const { return m_categoryImages; }
    SortMode sort() const { return m_sortMode; }
    QString lastUpdated() const { return m_time; }
    QString cacheSizeString() const { return m_cacheSize; }

    Q_INVOKABLE double calculateDistance(double x, double y, double z, double cmdrX, double cmdrY, double cmdrZ);
public slots:
    void onSystemsLoaded(QVariantList systems, QVariantList claims, QVariantList category);
    void onCategoryLoaded(QVariantMap categoryImages);
    void onClaimSuccess(QString systemName, QString cmdrName);
    void onContributionsLoaded(QVariantList contributions);
    void onImagesLoaded(QVariantList images);
    void onUnclaimSuccess(QString systemName);
    void onWorkerFinished(QList<QVariantMap> sortedList);
    void onImageRemoved(QString url);
    void onInterval();
    void onShipBuildLoaded(QJsonArray data);
    void setSortMode(SupabaseClient::SortMode mode);
    void MergeAndUpdateModel();
    void onDbLoaded(QVariantList data);
    void onError(QString operation, QString title, QString error);
    void onBackError(QString operation, QString title, QString error);
    void onContributionsAdded(QVariantMap data);
    void onSingleSystemLoaded(QVariantMap data); // new
    void onImgbbSuccess(QString link);
    void onImageSaved(QVariantMap confirmedData);
signals:
    void categoryImagesChanged();
    void errorOccurred(QString error, QString title, QString operation);
    void dbDataChanged();
    void TimeChanged();
    void SortModeChanged();
    void imageCached(QString url);
    void claimUpdated(bool success, QString message);
    void systemsLoaded();
    void shipbuildloadedez(QJsonArray data);
    void backerroroccurred(QString operation, QString title, QString error);
    void supabaseClientComplete();
    void contributionUpdated(QString systemName);
    void screenshotReady(QString url);
    void imagesChanged(QString url, QString system);
    void cacheSizeChanged();
    void ClaimCountChanged();
    void singleSystemDataUpdated(QString systemName);
private:
    SortMode m_sortMode = SortMode::SortByClosestDistance; // default value

    JournalManager *m_manager;
    QTimer *m_updateTimer;
    SystemsModel *m_systemsModel;
    CategoryModel *m_categoryModel;

    QString m_cacheSize = "0.0 B";

    bool m_initialLoadComplete = false;

    const QString m_supabaseUrl = "https://oduelomkzdlxvenwjeui.supabase.co";
    const QString m_anonKey = "sb_publishable_wRxCE9xKgOLmkVx5cpR0Tw_w5tuc3yq";

    QVariantMap m_categoryImages;
    QVariantMap m_systemImages;
    QVariantMap m_contributions;

    QHash<QString, QVariantMap> m_mergedCache;

    QString m_pendingSystem;
    QString m_pendingCmdr;

    QList<QVariantMap> m_allSystems;
    QList<QVariantMap> m_allClaims;
    QMap<QString, QString> m_gecUrlsMap;
    QMap<QString, QVariantList> m_systemBodyDetails;
    QMap<QString, QStringList> m_systemCategory;

    int m_newthisweek = 0;

    QString m_lastupdated = "";
    QString m_time = "";

    bool m_sysred = false;
    bool m_catred = false;
    bool m_contred = false;
    bool m_imagred = false;
    bool m_isnew = true;

    QString m_cachePath;
    QSet<QString> m_activeDownloads;

    QMap<QString, QString> m_claimsMap;

    QString getLocalPathFromUrl(QString url);
    void updateCacheSizeFormatted();
    void downloadImage(QString url);
};

#endif // SUPABASECLIENT_H
