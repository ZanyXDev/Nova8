#include <QImage>
#include "imageprovider.h"

ImageProvider::ImageProvider()
    : QQuickImageProvider(QQuickImageProvider::Image)
{
    // Инициализируем начальные изображения
    m_images["128x16/statusbar"] = QImage(128, 16, QImage::Format_RGB32);
    m_images["128x16/statusbar"].fill(Qt::blue);

    m_images["128x128/screen"] = QImage(128, 128, QImage::Format_RGB32);
    m_images["128x128/screen"].fill(Qt::lightGray);
    m_images["64x32/screen"] = QImage(64, 32, QImage::Format_RGB32);
    m_images["64x32/screen"].fill(Qt::green);
}

ImageProvider::~ImageProvider()
{
    qDebug() << Q_FUNC_INFO << " destructor";
}

QImage ImageProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    qDebug() << Q_FUNC_INFO << " id:" <<id;
    if (m_images.contains(id)) {
        QImage image = m_images[id];
        if (size) {
            *size = image.size();
        }
        return image;
    }
    return QImage();
}
