#include "galaxymapitem.h"
#include <QPainter>
#include <QPen>
#include <QHash>
#include <QMouseEvent>
#include <QImage>
#include <QHash>
#include <QDirIterator>

GalaxyMapItem::GalaxyMapItem(QQuickItem *parent)
{
    setRenderTarget(QQuickPaintedItem::Image); // qml sees an image
    setAntialiasing(true);
    setAcceptHoverEvents(true);
    setAcceptedMouseButtons(Qt::RightButton);

    // load base stars

    auto loadStar = [this](QString path) {
        QImage img(path);
        if (!img.isNull()) {
            m_baseTextures.append(img.scaled(64, 64, Qt::KeepAspectRatio, Qt::SmoothTransformation));
        }
    };

    loadStar(":/qt/qml/ExplorariumContent/images/BaseStar.png");
    loadStar(":/qt/qml/ExplorariumContent/images/OrdinaryStar.png");
    loadStar(":/qt/qml/ExplorariumContent/images/GiantStar.png");
    loadStar(":/qt/qml/ExplorariumContent/images/DimStar.png");
    loadStar(":/qt/qml/ExplorariumContent/images/VeryDimStar.png");
    loadStar(":/qt/qml/ExplorariumContent/images/GlowyStar.png");
}

void GalaxyMapItem::paint(QPainter *painter)
{
    painter->setRenderHint(QPainter::Antialiasing, true);
    painter->setRenderHint(QPainter::SmoothPixmapTransform, true);

    double visibleLeft = -m_viewX / m_zoomLevel;
    double visibleTop =  -m_viewY / m_zoomLevel;
    double visibleRight = visibleLeft + (width() / m_zoomLevel);
    double visibleBottom = visibleTop + (height() / m_zoomLevel);

    double buffer = 50.0;
    QRectF visibleRect(visibleLeft - buffer, visibleTop - buffer,
                       (visibleRight - visibleLeft) + buffer*2,
                       (visibleBottom - visibleTop) + buffer*2);
    painter->save();
    painter->translate(m_viewX, m_viewY);
    painter->scale(m_zoomLevel, m_zoomLevel);
    painter->setCompositionMode(QPainter::CompositionMode_Plus);
    QPointF offset(-m_starSize/2.0, -m_starSize/2.0);

    for(qsizetype i = 0; i < m_stars.size(); i++) {
        if(!isStarVisible(m_stars[i])) {
            continue;
        }
        const auto &star = m_stars[i];
        if (!visibleRect.contains(star.screenX, star.screenY)) {
            continue;
        }
        double finalSize = m_starSize * star.sizeMultiplier;
        QPointF offset(-finalSize/2.0, -finalSize/2.0);
        painter->save();
        painter->translate(star.screenX, star.screenY);
        painter->rotate(star.rotation);
        QImage tex = getTintedTexture(star.textureIndex, star.color);
        painter->drawImage(QRectF(-finalSize/2.0, -finalSize/2.0,
                                  finalSize, finalSize),
                           tex);
        painter->restore();
    }
    painter->restore();
}

void GalaxyMapItem::setStarSize(double size)
{
    if(size == m_starSize) return;

    m_starSize = size;
    emit starSizeChanged();
    this->update();
}

void GalaxyMapItem::updateLoadedCount()
{
    int count = 0;
    for(qsizetype i = 0; i < m_stars.size(); i++) {
        const auto &star = m_stars[i];
        if(isStarVisible(star)) {
            count++;
        }
    }
    if(m_starsLoaded != count) {
        m_starsLoaded = count;
        emit starsLoadedChanged();
    }
}

QPointF GalaxyMapItem::toWorldSpace(QPointF screenPos)
{
    double worldX = (screenPos.x() - m_viewX) / m_zoomLevel;
    double worldY = (screenPos.y() - m_viewY) / m_zoomLevel;
    return QPointF(worldX, worldY);
}

QImage GalaxyMapItem::getTintedTexture(int textureIndex, const QColor &color)
{
    QString cacheKey = QString::number(textureIndex) + "_" + color.name();

    if(m_textureCache.contains(cacheKey)) {
        return m_textureCache.value(cacheKey);
    }

    if (textureIndex >= m_baseTextures.size()) return QImage();

    QImage base = m_baseTextures[textureIndex];
    QImage tinted = QImage(base.size(), QImage::Format_ARGB32_Premultiplied);
    tinted.fill(Qt::transparent);

    QPainter p(&tinted);

    p.drawImage(0,0, base);
    p.setCompositionMode(QPainter::CompositionMode_SourceIn);
    p.fillRect(tinted.rect(), color);
    p.end();

    m_textureCache.insert(cacheKey, tinted);

    return tinted;
}

void GalaxyMapItem::setSystems(QVariantList systems)
{
    if (m_baseTextures.isEmpty()) {
        qWarning() << "No star textures loaded! Galaxy map cannot render.";
        return;
    }
    if(systems == m_rawSystems) return;
    m_rawSystems = systems;
    m_stars.clear();
    m_stars.reserve(systems.size());

    for (qsizetype i = 0; i < systems.size(); ++i) { // qsizetype = long long int
        const QVariantMap map = systems.at(i).toMap();

        if(map.contains("x") && map.contains("z")) {
            QStringList categoryList = map["category"].toStringList();
            StarNode node;
            node.x = map["x"].toDouble();
            node.z = map["z"].toDouble();
            node.system_name = map["system_name"].toString();
            node.category = categoryList;
            node.categoryMessage = categoryList.join(", ");
            node.screenX = SOL_X + (node.x * LY_SCALE);
            node.screenY = SOL_Y - (node.z * LY_SCALE);
            node.color = this->getColorForCategories(categoryList);
            uint hash = qHash(node.system_name);
            node.rotation = (hash % 360);
            node.textureIndex = hash % m_baseTextures.size();
            node.sizeMultiplier = 0.8 + ((hash % 50) / 100.0);

            m_stars.append(node);
        }
    }

    emit systemsChanged();
    updateLoadedCount();
    this->update();
}

void GalaxyMapItem::toggleCategory(QString categoryName)
{
    if(categoryName.isEmpty() || categoryName.isNull()) return;
    if(!m_disallowedCategories.contains(categoryName)) {
        m_disallowedCategories.append(categoryName);
    } else {
        m_disallowedCategories.removeOne(categoryName);
    }
    updateLoadedCount();
    emit categoriesChanged();
    this->update();
}

void GalaxyMapItem::hoverMoveEvent(QHoverEvent *event)
{
    QPointF mousePos = toWorldSpace(event->position());
    double mouseX = mousePos.x();
    double mouseY = mousePos.y();

    int foundIndex = -1;
    double detectionRadius = 10;

    for (int i = 0; i < m_stars.size(); i++) {
        if (!isStarVisible(m_stars[i])) {
            continue;
        }
        const auto& star = m_stars[i];

        double dx = mouseX - star.screenX;
        double dy = mouseY - star.screenY;

        if((dx * dx + dy * dy ) < (detectionRadius * detectionRadius)) {
            foundIndex = i;
            break;
        }
    }

    if(foundIndex != m_hoveredIndex) {
        m_hoveredIndex = foundIndex;

        if(foundIndex != -1) {
            const auto& star = m_stars[foundIndex];
            emit systemHovered(star.system_name, star.categoryMessage, star.screenX, star.screenY, true);
        } else {
            emit systemHovered("", "", 0, 0, false);
        }
    }
}

void GalaxyMapItem::mousePressEvent(QMouseEvent *event)
{
    if (event->button() == Qt::RightButton) {
        QPointF mousePos = toWorldSpace(event->position());
        double mouseX = mousePos.x();
        double mouseY = mousePos.y();
        double detectionRadius = 10;

        for(int i = 0; i < m_stars.size(); i++) {
            if (!isStarVisible(m_stars[i])) {
                continue;
            }
            const auto& star = m_stars[i];
            double dx = mouseX - star.screenX;
            double dy = mouseY - star.screenY;

            if((dx * dx + dy * dy ) < (detectionRadius * detectionRadius)) {
                emit systemRightClicked(star.system_name);
                event->accept();
                return;
            }
        }
    }

    QQuickPaintedItem::mousePressEvent(event);
}

QColor GalaxyMapItem::getColorForCategories(const QStringList &categories)
{
    if (categories.isEmpty()) return QColor(Qt::white);
    QStringList sortedCats = categories;
    sortedCats.sort();
    QString signature = categories.join("");
    uint hash = qHash(signature);
    int hue = hash % 360;
    return QColor::fromHsl(hue, 240, 150);
}

bool GalaxyMapItem::isStarVisible(const StarNode &star)
{
    if (m_disallowedCategories.isEmpty()) return true;

    for(int i = 0; i < star.category.size(); i++) {
        QString category = star.category[i];
        if(!m_disallowedCategories.contains(category)) {
            return true;
        }
    }

    return false;
}


