#include "engine.h"

Engine::Engine(QObject *parent)
    : QObject{parent}
    , m_imageProvider (nullptr )
    , m_scale (2)
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
