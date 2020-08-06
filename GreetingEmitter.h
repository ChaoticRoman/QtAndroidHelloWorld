#ifndef NAVIGATIONRUNNER_H
#define NAVIGATIONRUNNER_H

#include <QObject>

class GreetingEmitter : public QObject
{
    Q_OBJECT
public:
    explicit GreetingEmitter(QObject *parent = nullptr);

public slots:
    void greet();
};

#endif // NAVIGATIONRUNNER_H
