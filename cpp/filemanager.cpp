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

QStringList FileManager::getFilePathsInDirectory(const QString path, const QStringList filters)
{
    QStringList paths = {};

    QStringList currentIterPaths = { path };
    QStringList nextIterPaths = {};

    while (currentIterPaths.length() > 0) {
        for (QString iterPath : currentIterPaths) {
            QDir dir(iterPath);
            QFileInfoList iterResults = dir.entryInfoList(filters, QDir::Files | QDir::AllDirs | QDir::NoDotAndDotDot);

            qDebug() << "filemanager.cpp: Checking dir: " << iterPath;

            for (QFileInfo result : iterResults) {
                if (result.isFile()) paths << "file://" + result.filePath();
                else if (result.isDir()) nextIterPaths << result.filePath();
            }
        }

        currentIterPaths = nextIterPaths;
        nextIterPaths.clear();
    }

    return paths;
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
