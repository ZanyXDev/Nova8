#pragma once

#include <QObject>
#include <QDebug>
#include <QtQml/qqml.h>
#include <QVariantMap>
#include <QVariant>


// "Детальное описание алгоритма смотри в тетрадке у Хуня"

class DataManager : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    //Q_PROPERTY(BoardModel* boardModel READ boardModel CONSTANT)
    Q_PROPERTY(int maxTest READ getMaxTest WRITE setMaxTest NOTIFY maxTestChanged)
public:
    explicit DataManager(QObject *parent = nullptr);
    ~DataManager();

    int getMaxTest() const;
    void setMaxTest(int newMaxTest);

signals:
    void dataChanged();
    void errorInfo(const QString &info);
    void maxTestChanged();
private:
    int m_maxTest;
};
