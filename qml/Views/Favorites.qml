import QtQuick 2.13
import QtGraphicalEffects 1.13

import '../Components/Basic'
import '../Components/Favorites'

View {
    id: rootHis
    objectName: "Faorites"

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
                text: "Favorite Videos"; color: color_primary
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
                anchors { fill: parent; margins: 8 }

                model: favModel; delegate: VideoDelegate {
                    width: parent.width
                }
            }
        }
    }

    ListModel {
        id: favModel
        /*ListElement { _id: "ID"; _thumbPath: "PATH"; _name: "NAME"; _isPlaying: false; _duration: "DUR INT"; _durationWatched: "DUR INT"; _duationStr: "DURATION" }*/
    }

    function navigatedAway() {
        favModel.clear()
    }

    function videoLoaded(vid_id) {
        changeIsPlaying(vid_id, true)
    }

    function videoUnloaded(vid_id) {
        changeIsPlaying(vid_id, false)
    }

    function updateUI() {
        const views = dbc.getViews(usc.currentUserId, "lik")

        views.forEach(function(view) {
            const video = libc.videos[view.vid]
            favModel.append({
                                "_id": view.vid, "_name": video.name,
                                "_duration": video.duration, "_durationStr": video.durationStr, "_durationWatched": view.duration,
                                "_thumbPath": "file://" + fm.currentPath + libc.getItemThumbPath(view.vid), "_isPlaying": view.vid === playback.currentVidId && miniPlayback.active
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
