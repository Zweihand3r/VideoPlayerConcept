import QtQuick 2.13
import QtQuick.LocalStorage 2.13

Item {
    id: rootDbc; anchors {
        fill: parent
    }

    objectName: "DBController"

    property var db: LocalStorage.openDatabaseSync("VideoPlayerConceptDB", "1.0", "Storage for video indexing and User details", 1000000)


    function init() {
        db.transaction(function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS LibPaths(path VARCHAR, dirFlag BIT)')

            tx.executeSql('CREATE TABLE IF NOT EXISTS Videos(
                id INTEGER PRIMARY KEY AUTOINCREMENT, path VARCHAR, name VARCHAR, duration INT, durationStr CHAR, views INT, likes INT, dateAdded DATETIME
            )')
        })
    }

    function addLibPath(path, isDir) {
        db.transaction(function(tx) {
            tx.executeSql('INSERT INTO LibPaths VALUES(?, ?)', [path, isDir])
        })
    }

    function addVideo(path, name, dateAdded) {
        var insertId
        db.transaction(function(tx) {
            const res = tx.executeSql('INSERT INTO Videos(path, name, views, likes, dateAdded) VALUES(?, ?, ?, ?, ?)', [path, name, 0, 0, dateAdded])
            insertId = res.insertId
        })
        return insertId
    }

    function getLibPaths() {
        var libPaths = []
        db.transaction(function(tx) {
            const res = tx.executeSql('SELECT * FROM LibPaths')
            for (var index = 0; index < res.rows.length; index++) {
                libPaths.push(res.rows.item(index))
            }
        })

        return libPaths
    }

    function getVideos() {
        var videos = []
        db.transaction(function(tx) {
            const res = tx.executeSql('SELECT * FROM Videos')
            for (var index = 0; index < res.rows.length; index++) {
                videos.push(res.rows.item(index))
            }
        })

        return videos
    }

    function updateVideos(id, key, value) {
        db.transaction(function(tx) {
            const query = 'UPDATE Videos SET ' + key + '=? WHERE id=?'
            tx.executeSql(query, [value, id])
        })
    }


    /* ------------------------- DEBUG ------------------------ */

    function drop(table) {
        if (table === undefined) {
            console.log("DatabaseController.qml: No table name specified")
            return
        }

        db.transaction(function(tx) {
            const query = "DROP TABLE " + table
            tx.executeSql(query)
        })
    }

    function log(table) {
        if (table === undefined) {
            console.log("DatabaseController.qml: No table name specified")
            return
        }

        db.transaction(function(tx) {
            const query = "SELECT * FROM " + table
            const res = tx.executeSql(query)

            _console.log("DatabaseController.qml: TABLE " + table + ":")
            for (var index = 0; index < res.rows.length; index++) {
                _console.log(JSON.stringify(res.rows.item(index)))
            }
        })
    }
}
