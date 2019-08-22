import QtQuick 2.13

import '../Basic'

Item {
    id: rootPd
    width: pathsLv.width
    height: 28

    Item {
        /* Content */ anchors {
            fill: parent; leftMargin: 8; rightMargin: 8
        }

        Image {
            id: icon
            width: 18; height: width; tint: color_primary; anchors {
                left: parent.left; verticalCenter: parent.verticalCenter
            }
        }

        Text {
            text: _path; color: color_primary; font {
                pixelSize: 13; family: "Open Sans"
            }

            anchors {
                left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 28
            }
        }
    }

    /*Rectangle {
        id: div; height: 1; color: color_divider; anchors {
            leftMargin: -8; rightMargin: -8
            bottom: parent.bottom; left: parent.left; right: parent.right
        }
    }*/

    Component.onCompleted: {
        if (_dirFlag) {
            icon.width = 16
            icon.source = 'qrc:/assets/icons/x48/folder.png'
        } else {
            icon.source = 'qrc:/assets/icons/x48/video.png'
        }
    }
}
