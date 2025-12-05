#pragma once

#include <QObject>
#include <QMap>

class Keyboard : public QObject
{
    Q_OBJECT
public:
    explicit Keyboard(QObject *parent = nullptr);
    int getPressedKey() const;

signals:

private:
      QMap<int, bool> m_keys;
};
