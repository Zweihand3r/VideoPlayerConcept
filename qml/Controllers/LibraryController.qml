import QtQuick 2.13

import '../Components/Library'

Item {
    id: rootLibc; anchors {
        fill: parent
    }

    objectName: "LibC"

    property int vidBatchAddIndex: 0
    property var vidBatchAddPaths: []

    property var libPaths: [
        /*{ "path": "C:/Users/USER/Downloads", "dirFlag": true }*/
    ]

    property var videos: ({
        /*"ID": { "name": "NAME", "path": "C:/Users/USER/Downloads", "views": 0, "likes": 0, "dateAdded": Date() }*/
    })

    ThumbnailGenerator {
        id: thumbGen

        onStarted: mac.setDrawablesVisibility(false)
        onCompleted: vidBatchAddLoop()

        onDurationSet: setDuration(id, duration)
    }


    function init() {
        initialiseLibPaths()
        initialiseVideos()
    }

    function addNewVidPaths(paths) {
        paths.forEach(function(path) {
            addNewLibPath(path, false)
        })

        beginVidBatchAdd(paths)
    }

    function addNewDirPath(path) {
        addNewLibPath(path, true)
    }

    function setDuration(vid_id, duration) {
        dbc.updateVideos(vid_id, "duration", duration)
        dbc.updateVideos(vid_id, "durationStr", mac.msToTimeStr(duration))
    }

    function updateViews(vid_id) {
        const updatedViews = videos[vid_id].views + 1
        videos[vid_id].views = updatedViews
        dbc.updateVideos(vid_id, "views", updatedViews)
    }


    /* ------------------- FUNCTIONS ------------------ */

    function beginVidBatchAdd(paths) {
        vidBatchAddIndex = 0
        vidBatchAddPaths = paths
        vidBatchAddLoop()
    }

    function vidBatchAddLoop() {
        if (vidBatchAddIndex < vidBatchAddPaths.length) {
            addNewVideo(vidBatchAddPaths[vidBatchAddIndex++])
        } else {
            /* Finish */

            mac.setDrawablesVisibility(true)
        }
    }

    function addNewVideo(path) {
        const now = new Date()
        const fileInfo = fm.getFileInfo(path)
        const id = dbc.addVideo(path, fileInfo.baseName, now)

        thumbGen.generate(id, path)
        videos[id] = { "path": path, "name": fileInfo.baseName, "views": 0, "likes": 0, "dateAdded": now }
    }

    function initialiseLibPaths() {
        const _paths = dbc.getLibPaths()
        _paths.forEach(function(pathdat) {
            appendPath(pathdat.path, pathdat.dirFlag === 1)
        })

        console.log("LibraryController.qml: Initialised libPaths: ")
        for (var index in libPaths) {
            console.log(JSON.stringify(libPaths[index]))
        }
    }

    function initialiseVideos() {
        const _vids = dbc.getVideos()
        _vids.forEach(function(vid) {
            videos[vid.id] = { "name": vid.name, "path": vid.path, "durationStr": vid.durationStr, "views": vid.views, "likes": vid.likes, "dateAdded": vid.dateAdded }
        })

        console.log("LibraryController.qml: Initialised Videos: ")
        for (var id in videos) {
            console.log(id + ": " + JSON.stringify(videos[id]))
        }
    }


    /* -------------------- HELPERS ------------------- */

    function addNewLibPath(path, isDir) {
        path = formatPath(path)
        dbc.addLibPath(path, isDir)
        appendPath(path, isDir)
    }

    function appendPath(path, dirFlag) {
        libPaths.push({ "path": path, "dirFlag": dirFlag })
        library.addPath(path, dirFlag)
    }

    function formatPath(_path) {
        const path = _path.toString()
        if (path.startsWith('file://')) {
            return path.substring(7)
        } else return path
    }


    /* --------------------- DEBUG -------------------- */

    function wipeLibrary() {
        dbc.drop("LibPaths")
        dbc.drop("Videos")
        fm.deleteDirectory(fm.currentPath + "/Thumbnails")
    }
}
