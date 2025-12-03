#pragma once

#include <QObject>
#include <QImage>

#ifdef QT_DEBUG
#include <QDebug>
#endif


class ImageProvider;

class Engine : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int scale READ getScale WRITE setScale NOTIFY scaleChanged)
    Q_PROPERTY(int devType READ getDevType WRITE setDevType NOTIFY devTypeChanged)
    Q_PROPERTY(int virtScreenWidth READ getVirtScreenWidth WRITE setVirtScreenWidth NOTIFY virtScreenWidthChanged)
    Q_PROPERTY(int virtScreenHeight READ getVirtScreenHeight WRITE setVirtScreenHeight NOTIFY virtScreenHeightChanged)
public:

    explicit Engine(QObject *parent = nullptr);
    void setImageProvider(ImageProvider* provider);

    int getScale() const;
    void setScale(int newScale);

    int getDevType() const;
    void setDevType(int newDevType);

    int getVirtScreenWidth() const;
    void setVirtScreenWidth(int newVirtScreenWidth);

    int getVirtScreenHeight() const;
    void setVirtScreenHeight(int newVirtScreenHeight);

signals:
    void imageScreenChanged();
    void imageStatusBarChanged();
    void scaleChanged();

    void devTypeChanged();

    void virtScreenWidthChanged();

    void virtScreenHeightChanged();

private:
    ImageProvider* m_imageProvider = nullptr;
    int m_scale;
    int m_devType;
    int m_virtScreenWidth;
    int m_virtScreenHeight;

    void initDevice();

};
