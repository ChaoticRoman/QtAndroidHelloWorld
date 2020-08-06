#include "GreetingEmitter.h"

#include <QUrl>
#include <QDebug>
#include <QtAndroid>
#include <QAndroidIntent>
#include <QAndroidJniObject>

GreetingEmitter::GreetingEmitter(QObject *parent) : QObject(parent) {}

void GreetingEmitter::greet()
{
    qDebug() << "Hello world!";
}
