#ifndef GALAXYMAPITEM_H
#define GALAXYMAPITEM_H

#include <QObject>
#include <QQuickPaintedItem>
#include <QImage>
#include <QHash>

class GalaxyMapItem : public QQuickPaintedItem
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QVariantList systems READ systems WRITE setSystems NOTIFY systemsChanged FINAL)
    Q_PROPERTY(double viewX READ viewX WRITE setViewX NOTIFY viewChanged FINAL)
    Q_PROPERTY(double viewY READ viewY WRITE setViewY NOTIFY viewChanged FINAL)
    Q_PROPERTY(double zoomLevel READ zoomLevel WRITE setZoomLevel NOTIFY viewChanged FINAL)
    Q_PROPERTY(double mapWidth MEMBER m_mapWidth)
    Q_PROPERTY(double mapHeight MEMBER m_mapHeight)
    Q_PROPERTY(QStringList disallowedCategories READ disallowedCategories NOTIFY categoriesChanged FINAL)
    Q_PROPERTY(double starSize READ starSize WRITE setStarSize NOTIFY starSizeChanged FINAL)
    Q_PROPERTY(int starsLoaded READ starsLoaded NOTIFY starsLoadedChanged FINAL)
public:
    explicit GalaxyMapItem(QQuickItem *parent = nullptr);
    void paint(QPainter *painter) override;

    double starSize() const { return m_starSize; }
    void setStarSize(double size);
    void updateLoadedCount();

    Q_INVOKABLE void setSystems(QVariantList systems);
    Q_INVOKABLE QVariantList systems() { return m_rawSystems; };
    Q_INVOKABLE void toggleCategory(QString categoryName);
    Q_INVOKABLE bool isCategoryVisible(QString categoryName) {
        return !m_disallowedCategories.contains(categoryName);
    }

    int starsLoaded() const { return m_starsLoaded; }

    QStringList disallowedCategories() const { return m_disallowedCategories; }
    double viewX() const { return m_viewX; }
    double viewY() const { return m_viewY; }
    double zoomLevel() const { return m_zoomLevel; }

    void setViewX(double x) {
        if (m_viewX != x) { m_viewX = x; emit viewChanged(); update(); }
    }
    void setViewY(double y) {
        if (m_viewY != y) { m_viewY = y; emit viewChanged(); update(); }
    }
    void setZoomLevel(double z) {
        if (m_zoomLevel != z) { m_zoomLevel = z; emit viewChanged(); update(); }
    }

protected:
    void hoverMoveEvent(QHoverEvent *event) override;
    void mousePressEvent(QMouseEvent *event) override;
signals:
    void systemsChanged();
    void systemHovered(QString systemName, QString categoryMessage, double x, double y, bool active);
    void systemRightClicked(QString systemName);
    void viewChanged();
    void categoriesChanged();
    void starSizeChanged();
    void starsLoadedChanged();
private:
    struct StarNode {
        double x = 0;
        double z = 0;
        QString system_name = "";
        QString categoryMessage = "";
        QStringList category;
        double screenX = 0;
        int textureIndex = 0;
        double screenY = 0;
        QColor color;
        double sizeMultiplier = 0;
        qreal rotation = 0;
    };

    double m_starSize = 60;

    double m_viewX = 0;
    double m_viewY = 0;
    double m_zoomLevel = 1.0;
    double m_mapWidth = 20000;
    double m_mapHeight = 20000;

    QPointF toWorldSpace(QPointF screenPos);

    QVariantList m_rawSystems;
    QVector<QImage> m_baseTextures;
    QHash<QString, QImage> m_textureCache;
    QImage getTintedTexture(int textureIndex, const QColor &color);
    QList<StarNode> m_stars{};
    QColor getColorForCategories(const QStringList &categories);

    int m_hoveredIndex = -1; // -1 means no hovered stars

    QStringList m_disallowedCategories{};
    bool isStarVisible(const StarNode &star);

    int m_starsLoaded = 0;

    static constexpr double SOL_X = 10000.0;
    static constexpr double SOL_Y = 12500.0;
    static constexpr double LY_SCALE = 0.1;
};

#endif // GALAXYMAPITEM_H
