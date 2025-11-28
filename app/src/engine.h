#pragma once

#include <QObject>
#include<QImage>

#ifdef QT_DEBUG
#include <QDebug>
#endif

class ImageProvider;


class Engine : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int scale READ getScale WRITE setScale NOTIFY scaleChanged)

public:
    explicit Engine(QObject *parent = nullptr);
    void setImageProvider(ImageProvider* provider);

    int getScale() const;
    void setScale(int newScale);

signals:
    void imageScreenChanged();
    void imageStatusBarChanged();

    void scaleChanged();

private:
    ImageProvider* m_imageProvider = nullptr;
    int m_scale;
};
