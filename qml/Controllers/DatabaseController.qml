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
            /* ----- LIBRARY ----- */
            tx.executeSql('CREATE TABLE IF NOT EXISTS LibPaths(path VARCHAR, dirFlag BIT)')

            tx.executeSql('CREATE TABLE IF NOT EXISTS Videos(
                id INTEGER PRIMARY KEY AUTOINCREMENT, path VARCHAR, name VARCHAR, duration INT, durationStr CHAR, views INT, likes INT, dateAdded DATETIME
            )')

            /* ------ USERS ------ */
            tx.executeSql('CREATE TABLE IF NOT EXISTS Users(
                id INTEGER PRIMARY KEY AUTOINCREMENT, username VARCHAR, password VARCHAR, dateCreated DATETIME
            )')

            if (tx.executeSql('SELECT * FROM Users').rows.length < 1) {
                tx.executeSql('INSERT INTO Users(username, password, dateCreated) VALUES(?, ?, ?)', ["DEFAULT", "DEFAULT", new Date()])
            }

            /* ------ VIEWS ------ */
            tx.executeSql('CREATE TABLE IF NOT EXISTS Views(
                id INTEGER PRIMARY KEY AUTOINCREMENT, uid INT, vid INT, duration INT, liked BIT, lastWatched DATETIME
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

    function getUser(id) {
        var user = {}
        db.transaction(function(tx) {
            const res = tx.executeSql('SELECT * FROM Users WHERE id=?', [id])
            user = res.rows.item(0)
        })
        return user
    }

    function getViews(uid, type) {
        /* type- dur: duration, his: history, lik: likes */

        switch (type) {
        case "dur": var query = 'SELECT vid, duration FROM Views WHERE uid=?'; break
        case "his": query = 'SELECT vid, duration, lastWatched FROM Views WHERE uid=? ORDER BY lastWatched DESC'; break
        case "lik": query = 'SELECT vid, duration FROM Views WHERE uid=? AND liked=1'; break
        }

        var views = []
        db.transaction(function(tx) {
            const res = tx.executeSql(query, [uid])
            for (var index = 0; index < res.rows.length; index++) {
                views.push(res.rows.item(index))
            }
        })
        return views
    }

    function getViewById(id) {
        var view = {}
        db.transaction(function(tx) {
            const res = tx.executeSql('SELECT * FROM Views WHERE id=?', [id])
            view = res.rows.item(0)
        })
        return view
    }

    function getView(uid, vid) {
        var view = {}
        db.transaction(function(tx) {
            const res = tx.executeSql('SELECT * FROM Views WHERE uid=? AND vid=?', [uid, vid])
            if (res.rows.length > 0) view = res.rows.item(0)
        })
        return view
    }

    function createView(uid, vid) {
        var insertId
        db.transaction(function(tx) {
            const res = tx.executeSql('INSERT INTO Views(uid, vid, duration, liked, lastWatched) Values(?, ?, ?, ?, ?)', [uid, vid, 0, 0, new Date()])
            insertId = res.insertId
        })
        return insertId
    }

    function updateView(id, duration, liked) {
        db.transaction(function(tx) {
            tx.executeSql('UPDATE Views SET duration=?, liked=?, lastWatched=? WHERE id=?', [duration, liked, new Date(), id])
        })
    }

    function updateVideo(id, key, value) {
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
