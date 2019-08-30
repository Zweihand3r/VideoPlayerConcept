import QtQuick 2.13
import QtGraphicalEffects 1.13

import '../Components/Basic'
import '../Components/History'

View {
    id: rootHis
    objectName: "History"

    Item {
        width: parent.width / 2; anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top; bottom: parent.bottom; margins: 20
        }

        Rectangle { id: bg; anchors.fill: parent; color: color_content_bg; radius: 4 }
        DropShadow { id: bg_shadow; anchors.fill: bg; color: cons.color.lightGray_3; source: bg; radius: 6 }

        Item {
            id: header; width: parent.width; height: 54

            Text {
                text: "Watch History"; color: color_primary
                font { family: "Nickainley"; pixelSize: 29; weight: Font.Light } anchors {
                    centerIn: parent; verticalCenterOffset: -4
                }
            }

            Rectangle {
                width: header.width; height: 2; color:color_divider; anchors {
                    horizontalCenter: parent.horizontalCenter; bottom: parent.bottom
                }
            }
        }

        Item {
            clip: true; anchors {
                left: parent.left; top: header.bottom; right: parent.right; bottom: parent.bottom
            }

            ListView {
                spacing: 12; anchors {
                    fill: parent; margins: 12
                }

                model: historyModel; delegate: VideoDelegate {
                    width: parent.width
                }
            }
        }
    }

    ListModel {
        id: historyModel
        /*ListElement { _id: "ID"; _thumbPath: "PATH"; _name: "NAME"; _isPlaying: false; _duration: "DUR INT"; _durationWatched: "DUR INT"; _duationStr: "DURATION"; _details: "DETAILS" }*/
    }

    function navigatedAway() {
        historyModel.clear()
    }

    function videoLoaded(vid_id) {
        changeIsPlaying(vid_id, true)
    }

    function videoUnloaded(vid_id) {
        changeIsPlaying(vid_id, false)
    }

    function updateUI() {
        const views = dbc.getViews(usc.currentUserId, "his")

        views.forEach(function(view) {
            const video = libc.videos[view.vid]
            historyModel.append({
                                    "_id": view.vid, "_name": video.name, "_details": getDetails(view),
                                    "_duration": video.duration, "_durationStr": video.durationStr, "_durationWatched": view.duration,
                                    "_thumbPath": "file://" + fm.currentPath + libc.getItemThumbPath(view.vid), "_isPlaying": view.vid === playback.currentVidId
                                })
        })
    }

    function updateTheme(darkTheme) {
        if (darkTheme) {
            bg_shadow.visible = false
        } else {
            bg_shadow.visible = true
        }
    }

    function getDetails(view) {
        const timeStr = mac.getDateElapsedSince(view.lastWatched)
        return "Watched " + timeStr
    }

    function changeIsPlaying(vid_id, isPlaying) {
        if (visible && vid_id > -1) {
            for (var index = 0; index < historyModel.count; index++) {
                if (vid_id === historyModel.get(index)._id) {
                    historyModel.setProperty(index, "_isPlaying", isPlaying)
                    return
                }
            }
        }
    }
}
