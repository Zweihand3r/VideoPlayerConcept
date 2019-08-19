#include "filemanager.h"

FileManager::FileManager(QObject *parent) : QObject(parent)
{

}

void FileManager::createDirectory(const QString path)
{
    QDir dir(path);
    if (!dir.exists()) {
        dir.mkpath(".");
    }
}

void FileManager::deleteDirectory(const QString path)
{
    QDir dir(path);
    if (dir.exists()) {
        dir.removeRecursively();
    } else {
        qDebug() << "filemanager.cpp: No directory exists at" << path;
    }
}

QJsonObject FileManager::getFileInfo(const QString path)
{
    QFileInfo info(path);

    QJsonObject fileInfo = {
        { "absoluteFilePath", info.absoluteFilePath() },
        { "absolutePath", info.absolutePath() },
        { "baseName", info.baseName() },
        { "bundleName", info.bundleName() },
        { "completeBaseName", info.completeBaseName() },
        { "completeSuffix", info.completeSuffix() },
        { "group", info.group() },

        { "fileName", info.fileName() },
        { "filePath", info.filePath() },
        { "size", info.size() },
        { "suffix", info.suffix() }
    };

    return  fileInfo;
}
