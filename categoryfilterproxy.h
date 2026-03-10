#ifndef CATEGORYFILTERPROXY_H
#define CATEGORYFILTERPROXY_H
#include <QSortFilterProxyModel>

class CategoryFilterProxy : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(QStringList selectedCategories READ selectedCategories WRITE setSelectedCategories NOTIFY selectedCategoriesChanged FINAL)
    Q_PROPERTY(bool showOnlyClaims READ showOnlyClaims WRITE setShowOnlyClaims NOTIFY showOnlyClaimsChanged FINAL)
    Q_PROPERTY(QString cmdrName READ cmdrName WRITE setCmdrName NOTIFY cmdrNameChanged FINAL)
public:
    bool showOnlyClaims() const { return m_showOnlyClaims; }
    void setShowOnlyClaims(bool show);
    explicit CategoryFilterProxy(QObject *parent = nullptr);
    Q_INVOKABLE void toggleCategory(QString category);
    QStringList selectedCategories() const;
    QString cmdrName() const { return m_cmdrName; }
    void setCmdrName(const QString &name) { if(name != m_cmdrName) { m_cmdrName = name; emit cmdrNameChanged(); invalidateFilter(); }}
    void setSelectedCategories(const QStringList &categories);
protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;
signals:
    void selectedCategoriesChanged();
    void showOnlyClaimsChanged();
    void cmdrNameChanged();
private:
    bool m_showOnlyClaims = false;
    QString m_cmdrName;
    QStringList m_selectedCategories;
};

#endif // CATEGORYFILTERPROXY_H
