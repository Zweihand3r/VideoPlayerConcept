import QtQuick 2.13

import '../Components/Home'
import '../Components/Basic'

View {
    id: rootHm
    visible: true
    objectName: "Home"

    property bool initialised: false

    property int possibleColumnCount: 0

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
        /*ListElement { _id: ID; _vidPath: "PATH"; _thumbPath: 'PATH'; _name: "NAME"; _duration: "DUR INT"; _durationWatched: "DUR INT"; _durationStr: "DURATION; _details: "DETAILS" }*/
    }

    Timer {
        /* Init Timer. (Dirty fix yes I know) */
        running: true; interval: 100; onTriggered: {
            initialised = true
            updateUI()
        }
    }

    function navigatedAway() {
        videoModel.clear()
    }

    function updateUI() {
        if (initialised) {
            const durMap = {}
            const views = dbc.getViews(usc.currentUserId, "dur")
            views.forEach(function(view) {
                durMap[view.vid] = view.duration
            })

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

    function getDetails(video) {
        const viewStr = mac.formatNumber(video.views)
        const dateStr = mac.getDateElapsedSince(video.dateAdded)

        return viewStr + " views • " + dateStr
    }
}
