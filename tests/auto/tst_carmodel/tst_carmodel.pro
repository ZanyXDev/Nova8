QT += testlib
TEMPLATE = app

TARGET = io.github.zanyxdev.tst_carmodel

CONFIG += console qt
CONFIG += testcase
CONFIG += no_testcase_installs
CONFIG -= app_bundle


INCLUDEPATH += ../../../app/
#include(../../../app/tst_carmodel.pri)

HEADERS += \
            tst_carmodel.h
SOURCES +=  \                       
            main.cpp \
            tst_carmodel.cpp

# Force C++17 if available
contains(QT_CONFIG, c++1z): CONFIG += c++1z
# Enable CCache
load(ccache)
