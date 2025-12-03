#pragma once
#include <QObject>

class VirtualDevice
{
    Q_GADGET
public:
    explicit VirtualDevice();
    enum Type {
        NoValue    = 0,
        Chip8      = 1000,
        Chip48     = 1010,
        SuperChip  = 1020,
        Nova8      = 1030
     };
    Q_ENUM(Type)
};
