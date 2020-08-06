#include "GreetingEmitter.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

int main(int argc, char *argv[])
{
    // This attribute must be set before QGuiApplication is constructed.
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    // Main event loop and friends.
    QGuiApplication app(argc, argv);

    // Load and instatiate QML
    QQmlApplicationEngine engine("qrc:/main.qml");

    // Register our class instance in the QML context
    GreetingEmitter greetingEmitter;
    engine.rootContext()->setContextProperty("greetingEmitter", &greetingEmitter);

    return app.exec();
}
