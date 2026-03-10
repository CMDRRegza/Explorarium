#ifndef SUPABASETASK_H
#define SUPABASETASK_H

#include <QObject>
#include <QRunnable>
#include "supabaseclient.h"

class SupabaseTask : public QRunnable
{
public:
    enum Operation {
        FETCH_SYSTEMS,
        FETCH_SINGLE_SYSTEM,
        FETCH_CATEGORY_IMAGES,
        CLAIM_SYSTEM,
        UNCLAIM_SYSTEM,
        FETCH_DB_METADATA,
        FETCH_CONTRIBUTIONS,
        FETCH_SYSTEM_IMAGES,
        ADD_CONTRIBUTION,
        UPLOAD_IMAGE,
        REMOVE_IMAGE,
        SHIP_BUILD
    };
    SupabaseTask(SupabaseClient *client, Operation op, QVariantMap params, QString url, QString key);
    void FetchSystems();
    void FetchCategoryImages();
    void FetchDbMetaData();
    void FetchContributions();
    void FetchSystemImages();
    void ClaimSystem();
    void UnclaimSystem();
    void AddContributions();
    void UploadImage();
    void RemoveImage();
    void FetchShipBuild();
    void FetchSingleSystem();
    void run() override;
private:
    SupabaseClient *m_client;
    Operation m_operation;
    QVariantMap m_params;
    QString m_url;
    QString m_key;
};

#endif // SUPABASETASK_H
