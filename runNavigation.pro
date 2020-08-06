QT += core quick androidextras

CONFIG += c++11

DEFINES += QT_DEPRECATED_WARNINGS
DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        GreetingEmitter.cpp \
        main.cpp

HEADERS += \
    GreetingEmitter.h

RESOURCES += qml.qrc
