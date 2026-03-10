#include "categoryfilterproxy.h"
// #include "journalmanager.h"
#include "systemsmodel.h"

void CategoryFilterProxy::setShowOnlyClaims(bool show)
{
    if(m_showOnlyClaims != show) {
        m_showOnlyClaims = show;
        emit showOnlyClaimsChanged();
        invalidateFilter();
    }
}

CategoryFilterProxy::CategoryFilterProxy(QObject *parent)
{
    qInfo() << this << "Constructed";
}

void CategoryFilterProxy::toggleCategory(QString category)
{
    if(category.isEmpty() || category.isNull()) {
        return;
    }

    if(m_selectedCategories.contains(category)) {
        m_selectedCategories.removeOne(category);
    } else {
        m_selectedCategories.append(category);
    }
    emit selectedCategoriesChanged();
    invalidateFilter();
}

QStringList CategoryFilterProxy::selectedCategories() const
{
    return m_selectedCategories;
}

void CategoryFilterProxy::setSelectedCategories(const QStringList &categories)
{
    if(categories.isEmpty()) return;
    if (m_selectedCategories == categories) return;
    m_selectedCategories = categories;
    emit selectedCategoriesChanged();
    invalidateFilter();
}

bool CategoryFilterProxy::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    QModelIndex index = sourceModel()->index(source_row, 0, source_parent);

    if(m_showOnlyClaims) {
        QVariantMap systemData = sourceModel()->data(index, SystemsModel::SystemDataRole).toMap();
        QString claimant = systemData["claimed_by"].toString();

        if(claimant != m_cmdrName) {
            return false;
        }
    }

    if(m_selectedCategories.isEmpty()) {return true;}

    QVariant categoryData = sourceModel()->data(index, SystemsModel::CategoryRole);
    QStringList systemCategories = categoryData.toStringList();

    qDebug() << "Row" << source_row << "has categories:" << systemCategories;
    qDebug() << "Checking against selected:" << m_selectedCategories;

    for(int i = 0; i < m_selectedCategories.size(); i++) {
        if(systemCategories.contains(m_selectedCategories[i])) {
            return true;
        }
    }
    return false;
}
