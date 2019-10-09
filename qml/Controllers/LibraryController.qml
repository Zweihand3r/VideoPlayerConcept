import QtQuick 2.13

import '../Components/Library'

Item {
    id: rootLibc; anchors {
        fill: parent
    }

    objectName: "LibC"

    property bool debugThumbnailProcessing: false

    property int vidBatchAddIndex: 0
    property var vidBatchAddPaths: []

    readonly property string thumbDirPath: "Thumbnails" + (debug_build ? "_Deb" : "")

    property var libPaths: [
        /*{ "path": "C:/Users/USER/Downloads", "dirFlag": true }*/
    ]

    property var videos: ({
        /*"ID": { "name": "NAME", "path": "C:/Users/USER/Downloads", "views": 0, "likes": 0, "dateAdded": Date() }*/
    })

    ThumbnailGenerator {
        id: thumbGen

        onCompleted: vidBatchAddLoop()
        onErrorEncountered: vidBatchAddLoop(errorStr, currentGenId)
        onDurationSet: setDuration(id, duration)
    }


    function init() {
        initialiseLibPaths()
        initialiseVideos()
    }

    function getItemThumbPath(id) {
        return "/" + thumbDirPath + "/thumb_" + id + ".png"
    }

    function addNewVidPaths(paths) {
        var addPaths = []
        paths.forEach(function(path) {
            if (checkDuplicateFilePath(path)) {
                console.log("LibraryController.qml: Video at path \'" + path + "\' already exists in library")
            } else addPaths.push(path)
        })

        if (addPaths.length > 0) {
            addPaths.forEach(function(path) {
                addNewLibPath(path, false)
            })

            beginVidBatchAdd(addPaths)
        }
    }

    function addNewDirPath(path) {
        for (var index = 0; index < libPaths.length; index++) {
            const libPath = libPaths[index].path
            const addPath = formatPath(path)

            if (addPath.indexOf(libPath) > -1) {
                console.log("LibraryController.qml: Contents of directory \'" + addPath + "\' if any already exists in library")
                return
            }
        }

        addNewLibPath(path, true)

        const vidPaths = fm.getFilePathsInDirectory(formatPath(path), ["*.mp4"])
        beginVidBatchAdd(vidPaths)
    }

    function setDuration(vid_id, duration) {
        dbc.updateVideo(vid_id, "duration", duration)
        videos[vid_id].duration = duration

        const durationStr = mac.msToTimeStr(duration)
        dbc.updateVideo(vid_id, "durationStr", durationStr)
        videos[vid_id].durationStr = durationStr
    }

    function updateGlobalViews(vid_id) {
        const updatedViews = videos[vid_id].views + 1
        videos[vid_id].views = updatedViews
        dbc.updateVideo(vid_id, "views", updatedViews)
    }

    function updateGlobalLikes(vid_id, liked) {
        const updatedLikes = videos[vid_id].likes + (liked ? 1 : -1)
        videos[vid_id].likes = updatedLikes
        dbc.updateVideo(vid_id, "likes", updatedLikes)
    }


    /* ------------------- FUNCTIONS ------------------ */

    function checkDuplicateFilePath(path) {
        for (const key in videos) {
            if (path === videos[key].path) return true
        }

        return false
    }

    function beginVidBatchAdd(paths) {
        vidBatchAddIndex = 0
        vidBatchAddPaths = []

        paths.forEach(function(path) {
            if (checkDuplicateFilePath(path)) {
                console.log("LibraryController.qml: Video at path " + path + " already exists in library")
            } else vidBatchAddPaths.push(path)
        })

        vidBatchAddLoop()

        if (debugThumbnailProcessing) {
            mac.setDrawablesVisibility(false)
        } else loadProg.start(paths.length)
    }

    function vidBatchAddLoop(errorStr, id) {
        if (errorStr !== undefined) {
            console.log("LibraryController.qml: Could not add video at path " + videos[id].path + ": " + errorStr)

            dbc.deleteVideo(id)
            delete videos[id]
        }

        if (vidBatchAddIndex < vidBatchAddPaths.length) {
            addNewVideo(vidBatchAddPaths[vidBatchAddIndex++])
            loadProg.incrementProgress()
        } else {
            /* Finish */

            if (!debugThumbnailProcessing) {
                loadProg.incrementProgress()
                removeDuplicateLibPaths()

                mac.executeAfter(500, loadProg.dismiss)
            } else mac.setDrawablesVisibility(true)
        }
    }

    function addNewVideo(path) {
        const now = new Date()
        const fileInfo = fm.getFileInfo(path)
        const id = dbc.addVideo(path, fileInfo.baseName, now)

        thumbGen.generate(id, path)
        videos[id] = { "path": path, "name": fileInfo.baseName, "views": 0, "likes": 0, "dateAdded": now }

        console.log("LibraryController.qml: Adding video: " + JSON.stringify(videos[id]))
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
            videos[vid.id] = {
                "name": vid.name, "path": vid.path, "duration": vid.duration,
                "durationStr": vid.durationStr, "views": vid.views, "likes": vid.likes, "dateAdded": vid.dateAdded
            }
        })

        console.log("LibraryController.qml: Initialised Videos: ")
        for (var id in videos) {
            console.log(id + ": " + JSON.stringify(videos[id]))
        }
    }

    function removeDuplicateLibPaths() {
        /* Need to write better function for this */

        /*libPaths.forEach(function(libPath) {
            if (!libPath.dirFlag) {
                for (var key in videos) {
                    if ("file://" + libPath.path === videos[key].path) {
                        console.log("LibraryController.qml: found duplicate: " + libPath.path)
                        dbc.deleteLibPath(libPath.path)
                    }
                }
            }
        })

        library.clearLibPaths()
        initialiseLibPaths()*/
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
        fm.deleteDirectory(fm.currentPath + thumbDirPath)
    }
}
