#pragma once

#include <QQuickImageProvider>
#include <QPair>

class ImageProvider : public QQuickImageProvider
{

public:

    ImageProvider();
    ~ImageProvider();
    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize) override;

private:
    QMap<QString, QImage> m_images;
};
