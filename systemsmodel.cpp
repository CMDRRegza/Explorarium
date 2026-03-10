#include "systemsmodel.h"
#include "supabaseclient.h"
#include <QDebug>
#include <QByteArray>
#include <QHash>

SystemsModel::SystemsModel(QObject *parent)
    : QAbstractListModel{parent}
{
    qInfo() << this << "Constructed";
}

int SystemsModel::rowCount(const QModelIndex &parent) const
{
    return m_systems.size();
}

QVariant SystemsModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_systems.size())
        return QVariant();

    QVariantMap system = m_systems[index.row()];
    switch(role) {
    case SystemNameRole: return system["system_name"];
    case CategoryRole: return system["category"];
    case DistanceRole: return system["distance"];
    case MainImageRole: return system["main_image"];
    case TitleRole: return system["title"];
    case CategoryImageRole: {
        QString rawUrl = system["category_image"].toString();
        return rawUrl;
    };
    case SystemDataRole: return system;
    default: return QVariant();
    }
}

void SystemsModel::setClient(SupabaseClient *client)
{
    m_client = client;
}

QHash<int, QByteArray> SystemsModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[SystemNameRole] = "system_name";
    roles[CategoryRole] = "category";
    roles[DistanceRole] = "distance";
    roles[TitleRole] = "title";
    roles[MainImageRole] = "main_image";
    roles[CategoryImageRole] = "category_image";
    roles[SystemDataRole] = "systemData";
    return roles;
}

void SystemsModel::setSystemsData(QList<QVariantMap> systems)
{
    if (m_systems.size() != systems.size()) {
        beginResetModel();
        m_systems = systems;
        endResetModel();
        return;
    }
    m_systems = systems;
    QModelIndex topLeft = createIndex(0, 0);
    QModelIndex bottomRight = createIndex(m_systems.size() - 1, 0);

    emit dataChanged(topLeft, bottomRight);
}
