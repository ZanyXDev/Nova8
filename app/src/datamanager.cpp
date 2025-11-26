#include "datamanager.h"

DataManager::DataManager(QObject *parent)
    : QObject{parent}
    ,m_maxTest(0)
{
}

DataManager::~DataManager()
{

}

int DataManager::getMaxTest() const
{
    return m_maxTest;
}

void DataManager::setMaxTest(int newMaxTest)
{
    if (m_maxTest == newMaxTest)
        return;
    m_maxTest = newMaxTest;
    emit maxTestChanged();
}
