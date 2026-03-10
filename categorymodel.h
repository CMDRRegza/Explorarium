#ifndef CATEGORYMODEL_H
#define CATEGORYMODEL_H
#include <QAbstractListModel>

class CategoryModel : public QAbstractListModel
{
public:
    explicit CategoryModel(QObject *parent = nullptr);
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;
public slots:
    void setCategoryData(QList<QVariantMap> categories);
private:
    enum CategoryRoles {
        CategoryNameRole = Qt::UserRole + 1,
        CategoryImageRole
    };
    QList<QVariantMap> m_categories;
};

#endif // CATEGORYMODEL_H
