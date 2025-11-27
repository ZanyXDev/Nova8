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
    QImage * m_firstScreen;
    QImage * m_secondScreen;

    int m_bordersize;
    int m_width;
    int m_height;
};
