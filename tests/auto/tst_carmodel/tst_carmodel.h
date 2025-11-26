#pragma once

#include <QObject>

// add necessary includes here
#include <QAbstractItemModelTester>
//#include "src/carmodel.h"

class TestCarModel: public QObject
{
    Q_OBJECT

public:
    TestCarModel();
    ~TestCarModel();

private slots:
    // вызывается перед первой тестовой функцией
    void initTestCase();
    // вызывается перед каждой тестовой функцией
    void init();
    // вызывается после каждой тестовой функции
    void cleanup(){};
    // вызывается после последней тестовой функции
    void cleanupTestCase(){};

private:
    //CarModel m_model;
    QAbstractItemModelTester* m_tester;
};

