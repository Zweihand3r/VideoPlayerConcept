#ifndef FILEMANAGER_H
#define FILEMANAGER_H

#include <QDir>
#include <QDebug>
#include <QObject>
#include <QFileInfo>
#include <QJsonObject>

class FileManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString currentPath READ currentPath CONSTANT)

public:
    explicit FileManager(QObject *parent = nullptr);

    QString currentPath() { return QDir::currentPath(); }

signals:

public slots:
    void createDirectory(const QString path);
    void deleteDirectory(const QString path);

    QJsonObject getFileInfo(const QString path);
};

#endif // FILEMANAGER_H
