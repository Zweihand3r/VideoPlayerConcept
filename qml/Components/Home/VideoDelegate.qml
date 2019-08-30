import QtQuick 2.13
import QtMultimedia 5.13

/* Cell Height: 220 */

MouseArea {
    id: rootVD
    width: 220
    height: detailText.y + detailText.height
    hoverEnabled: true; cursorShape: Qt.PointingHandCursor

    onClicked: playback.loadVideo(_id)
    onEntered: triggerPreview()
    onExited: exitPreview()

    /*
     * _thumbPath, _name, _details
     */

    Rectangle {
        id: vid_bg; width: 216; height: 110; color: "black"; anchors {
            horizontalCenter: parent.horizontalCenter
        }

        Image { source: _thumbPath; fillMode: Image.PreserveAspectCrop; anchors.fill: parent }

        Rectangle {
            color: Qt.rgba(0, 0, 0, 0.75)
            width: durationText.width; height: durationText.height; anchors {
                right: parent.right; bottom: parent.bottom; margins: 4
            }

            Text {
                id: durationText
                text: _durationStr; color: cons.color.lightGray_2
                leftPadding: 2; rightPadding: 2; font {
                    pixelSize: 12; family: "Open Sans"
                }
            }
        }

        Rectangle {
            id: watchProgress; height: 4; color: cons.color.lightGray_3; anchors {
                left: parent.left; right: parent.right; bottom: parent.bottom
            }

            Rectangle {
                height: parent.height; color: settings.accentColor
                width: _durationWatched / _duration * parent.width
            }
        }

        Rectangle {
            color: Qt.rgba(0, 0, 0, 0.85)
            opacity: _isPlaying ? 1 : 0; anchors { fill: parent }
            Behavior on opacity { OpacityAnimator { duration: 120 }}

            Text {
                anchors { centerIn: parent }
                text: "NOW PLAYING"; color: cons.color.lightGray_1; font {
                    pixelSize: 14; family: "Open Sans"
                }
            }
        }
    }

    Loader {
        id: previewLoader; width: 216; height: 110; anchors {
            horizontalCenter: parent.horizontalCenter
        }

        asynchronous: true; opacity: 0; onStatusChanged: {
            if (status === Loader.Ready) startPreviewAnim.start()
        }
    }

    Text {
        id: nameText; text: _name; color: color_primary
        wrapMode: Text.Wrap; font.pixelSize: 14; anchors {
            topMargin: 12; leftMargin: 4; rightMargin: 4
            top: vid_bg.bottom; left: parent.left; right: parent.right
        }
    }

    Text {
        id: detailText; text: _details; color: color_secondary
        wrapMode: Text.Wrap; font.pixelSize: 12; anchors {
            topMargin: 6; leftMargin: 4; rightMargin: 4
            top: nameText.bottom; left: parent.left; right: parent.right
        }
    }

    Timer {
        id: previewDelayTimer
        interval: 1200; onTriggered: {
            previewLoader.sourceComponent = previewComponent
        }
    }

    Component {
        id: previewComponent

        Rectangle {
            width: 216; height: 100; color: "black"

            Video {
                source: _vidPath; muted: true; anchors { fill: parent; margins: 0 }
                loops: MediaPlayer.Infinite; fillMode: VideoOutput.PreserveAspectCrop

                Component.onCompleted: play()
            }
        }
    }

    OpacityAnimator {
        id: startPreviewAnim
        target: previewLoader; from: 0; to: 1; duration: 360
    }

    OpacityAnimator {
        id: finishPreviewAnim
        target: previewLoader; from: 1; to: 0; duration: 180
        onStopped: exitCompleteHandler()
    }

    Component.onCompleted: {
        if (_durationWatched === -1) {
            watchProgress.visible = false
        }
    }

    function triggerPreview() {
        if (!_isPlaying) {
            previewDelayTimer.start()
        }
    }

    function exitPreview() {
        if (!_isPlaying) {
            if (previewDelayTimer.running) {
                previewDelayTimer.stop()
            } else finishPreviewAnim.start()
        }
    }

    function exitCompleteHandler() {
        previewLoader.sourceComponent = undefined
    }
}
