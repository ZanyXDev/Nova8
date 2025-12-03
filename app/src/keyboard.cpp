#include "keyboard.h"

Keyboard::Keyboard(QObject *parent)
    : QObject{parent}
{}

int Keyboard::getPressedKey() const
{
    int pressedKey = -1;
    for (auto it = m_keys.constKeyValueBegin();it != m_keys.constKeyValueEnd(); ++it){
        if ( it->second == true ) {
            pressedKey = it->first;
            break;
        }
    }

    return pressedKey;
}
