import QtQuick 2.13

import '../Basic'

MouseArea {
    id: rootMPB
    implicitWidth: 44
    implicitHeight: 44
    hoverEnabled: true

    Image {
        id: icon; anchors {
            fill: parent; margins: 4
        }

        tint: cons.color.lightGray_1
        source: 'qrc:/assets/icons/x48/picture_in_picture.png'
    }
}
