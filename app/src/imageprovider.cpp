#include <QtConcurrent>
#include <QFuture>

#include <QPainter>
#include <QColor>
#include <QRandomGenerator>
#include <QImage>


ImageProvider::ImageProvider()
    : QQuickImageProvider(QQuickImageProvider::Image)
{
}

ImageProvider::~ImageProvider()
{
    qDebug() << Q_FUNC_INFO << " destructor";
}

QImage ImageProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    return QImage();
}
