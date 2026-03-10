#include "categorymodel.h"

CategoryModel::CategoryModel(QObject *parent)
{
    qInfo() << this << "Constructed";
}

int CategoryModel::rowCount(const QModelIndex &parent) const
{
    return m_categories.size();
}

QVariant CategoryModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_categories.size())
        return QVariant();
    QVariantMap category = m_categories[index.row()];
    switch(role) {
    case CategoryRoles::CategoryNameRole: return category["category_name"];
    case CategoryRoles::CategoryImageRole: return category["category_image"];
    default: return QVariant();
    }
}

QHash<int, QByteArray> CategoryModel::roleNames() const
{
    QHash<int, QByteArray> hash;
    hash[CategoryNameRole] = "category_name";
    hash[CategoryImageRole] = "category_image";
    return hash;
}

void CategoryModel::setCategoryData(QList<QVariantMap> categories)
{
    if(!categories.isEmpty()) {
        beginResetModel();
        m_categories = categories;
        endResetModel();
    }
}

