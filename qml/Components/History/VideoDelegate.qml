import QtQuick 2.13
import QtQuick.Layouts 1.13

import '../Shared'

MouseArea {
    id: rootVD
    width: 480; height: 80
    hoverEnabled: true; cursorShape: Qt.PointingHandCursor

    onClicked: playback.loadVideo(_id)

    Image {
        id: thumb; width: 140; height: 80
        source: _thumbPath; fillMode: Image.PreserveAspectCrop; anchors {
            verticalCenter: parent.verticalCenter
        }

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
    }

    NowPlaying { anchors.fill: thumb }

    ColumnLayout {
        spacing: 0; anchors {
            verticalCenter: parent.verticalCenter
            left: thumb.right; leftMargin: 12; right: parent.right; rightMargin: 8
        }

        Text {
            Layout.fillWidth: true
            text: _name; color: color_primary
            wrapMode: Text.Wrap; font {
                pixelSize: 25; family: "Open Sans"; weight: Font.Light
            }
        }

        Text {
            Layout.fillWidth: true
            text: _details; color: color_secondary
            wrapMode: Text.Wrap; font.pixelSize: 12
        }
    }
}
