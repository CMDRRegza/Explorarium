#ifndef SYSTEMSMODEL_H
#define SYSTEMSMODEL_H

#include <QObject>
#include <QAbstractListModel>

class SupabaseClient;

class SystemsModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum SystemRoles {
        SystemNameRole = Qt::UserRole + 1,
        TitleRole,
        MainImageRole,
        CategoryRole,
        DistanceRole,
        CategoryImageRole,
        SystemDataRole
    };
    explicit SystemsModel(QObject *parent = nullptr);
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    void setClient(SupabaseClient* client);
    QHash<int, QByteArray> roleNames() const override;
public slots:
    void setSystemsData(QList<QVariantMap> systems);
private:
    QList<QVariantMap> m_systems;
    SupabaseClient* m_client = nullptr;
};

#endif // SYSTEMSMODEL_H
