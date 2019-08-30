import QtQuick 2.13

import '../Shared'

MouseArea {
    id: rootVD
    width: 480; height: 72
    hoverEnabled: true; cursorShape: Qt.PointingHandCursor

    onClicked: playback.loadVideo(_id)

    Item {
        anchors { fill: parent; bottomMargin: 1 }

        Text {
            id: indexText; text: (index + 1); color: color_secondary; anchors {
                left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 12
            }
        }

        Image {
            id: thumb; width: 74; height: 44; source: _thumbPath; fillMode: Image.PreserveAspectCrop; anchors {
                left: indexText.right; verticalCenter: parent.verticalCenter; leftMargin: 12
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
        }

        NowPlaying { anchors.fill: thumb }

        Text {
            id: nameText; text: _name; color: color_primary; font {
                pixelSize: 15; underline: containsMouse
            }

            anchors {
                left: thumb.right; verticalCenter: parent.verticalCenter; leftMargin: 20
            }
        }

        Text {
            text: _durationStr; color: color_secondary; anchors {
                right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: 12
            }
        }
    }

    Rectangle {
        width: parent.width; height: 1; color:color_divider; anchors {
            bottom: parent.bottom
        }
    }
}
