#include "engine.h"
#include "virtualdevice.h"

Engine::Engine(QObject *parent)
    : QObject{parent}
    , m_imageProvider ( nullptr )
    , m_scale ( 4 )
    , m_devType ( VirtualDevice::Chip8 )
    , m_virtScreenWidth ( 64 )
    , m_virtScreenHeight  ( 32 )
{

}

void Engine::setImageProvider(ImageProvider *provider)
{
    if ( nullptr == provider ) {
        qCritical() <<  Q_FUNC_INFO << "Empty pointer";
    }
    m_imageProvider = provider;
}

int Engine::getScale() const
{
    return m_scale;
}

void Engine::setScale(int newScale)
{
    if (m_scale == newScale)
        return;
    m_scale = newScale;
    emit scaleChanged();
}

int Engine::getDevType() const
{
    return m_devType;
}

void Engine::setDevType(int newDevType)
{
    if (m_devType == newDevType)
        return;

    m_devType = ((VirtualDevice::Chip8 == newDevType) ||  ((VirtualDevice::Nova8 == newDevType)) ) ?
                    newDevType : VirtualDevice::Chip8 ;
    this->initDevice();
    emit devTypeChanged();
}

int Engine::getVirtScreenWidth() const
{
    return m_virtScreenWidth;
}

void Engine::setVirtScreenWidth(int newVirtScreenWidth)
{
    if (m_virtScreenWidth == newVirtScreenWidth)
        return;
    m_virtScreenWidth = newVirtScreenWidth;
    emit virtScreenWidthChanged();
}

int Engine::getVirtScreenHeight() const
{
    return m_virtScreenHeight;
}

void Engine::setVirtScreenHeight(int newVirtScreenHeight)
{
    if (m_virtScreenHeight == newVirtScreenHeight)
        return;
    m_virtScreenHeight = newVirtScreenHeight;
    emit virtScreenHeightChanged();
}

void Engine::initDevice()
{
    if (VirtualDevice::Chip8 == m_devType){
        setVirtScreenWidth( 64 );
        setVirtScreenHeight( 32 );
    }else{
        setVirtScreenWidth( 128 );
        setVirtScreenHeight( 128 );
    }
}
