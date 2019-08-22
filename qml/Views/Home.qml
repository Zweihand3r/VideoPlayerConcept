import QtQuick 2.13

import '../Components/Home'
import '../Components/Basic'

View {
    id: rootHm
    visible: true
    objectName: "Home"

    property bool initialised: false

    property int possibleColumnCount: 0

    property string color_secondary: cons.color.lightGray_3

    onWidthChanged: possibleColumnCount = Math.floor(width / 220)

    GridView {
        id: videosGV; width: cellWidth * possibleColumnCount; anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top; bottom: parent.bottom; topMargin: 32
        }

        cellWidth: 220; cellHeight: 220
        model: videoModel; delegate: VideoDelegate {}
    }

    ListModel {
        id: videoModel
        /*ListElement { _id: ID; _thumbPath: 'PATH'; _name: "NAME"; _durationStr: "DURATION; _details: "DETAILS" }*/
    }

    Timer {
        /* Init Timer. (Dirty fix yes I know) */
        running: true; interval: 100; onTriggered: {
            initialised = true
            updateUI()
        }
    }

    function updateUI() {
        if (initialised) {
            const durMap = {}
            const views = dbc.getViews(usc.currentUserId, "dur")
            views.forEach(function(view) {
                durMap[view.vid] = view.duration
            })

            videoModel.clear()
            for (var id in libc.videos) {
                const video = libc.videos[id]
                const durationWatched = durMap[id] ? durMap[id] : -1
                videoModel.append({
                                      "_id": id,
                                      "_name": video.name, "_details": getDetails(video), "_vidPath": video.path,
                                      "_thumbPath": "file://" + fm.currentPath + "/Thumbnails/thumb_" + id + ".png",
                                      "_duration": video.duration, "_durationStr": video.durationStr, "_durationWatched": durationWatched
                                  })
            }
        }
    }

    function updateTheme(darkTheme) {
        if (darkTheme) {
            color_secondary = cons.color.lightGray_3
        } else {
            color_secondary = cons.color.darkGray_3
        }
    }

    function getDetails(video) {
        const viewStr = mac.formatNumber(video.views)
        const diff = Math.floor((Date.now() - (new Date(video.dateAdded)).getTime()) / 1000)

        if (diff < 60) {
            var dateStr = Math.floor(diff) + " seconds ago"
        } else if (diff >= 60 && diff < 3600) {
            dateStr = Math.floor(diff / 60) + " minutes ago"
        } else if (diff >= 3600 && diff < 86400) {
            dateStr = Math.floor(diff / 3600) + " hours ago"
        } else if (diff >= 86400 && diff < 2592000) {
            dateStr = Math.floor(diff / 86400) + " days ago"
        } else if (diff >= 2592000 && diff < 31536000) {
            dateStr = Math.floor(diff / 2592000) + " months ago"
        } else {
            dateStr = Math.floor(diff / 31536000) + " years ago"
        }

        return viewStr + " views • " + dateStr
    }
}
