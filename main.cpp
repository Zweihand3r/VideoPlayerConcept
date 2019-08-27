#include <QQmlContext>
#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "cpp/filemanager.h"

#define DEBUG_BUILD true

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    bool debug_build = DEBUG_BUILD;

#if DEBUG_BUILD
    engine.setOfflineStoragePath("OfflineStorage_Deb");
#else
    engine.setOfflineStoragePath("OfflineStorage");
#endif

    FileManager *fm = new FileManager();
    engine.rootContext()->setContextProperty("fm", fm);

    engine.rootContext()->setContextProperty("debug_build", debug_build);

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
