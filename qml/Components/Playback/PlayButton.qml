import QtQuick 2.13
import QtMultimedia 5.13

import '../Basic'

MouseArea {
    id: rootPb
    implicitWidth: 44
    implicitHeight: 44
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    property bool playActive: vic.playbackState === MediaPlayer.PlayingState

    Image {
        anchors { fill: parent; margins: 10 }
        tint: cons.color.lightGray_1; source: {
            if (playActive) return 'qrc:/assets/icons/x32/pause.png'
            else return 'qrc:/assets/icons/x32/play.png'
        }
    }

    onClicked: {
        if (playActive) vic.pause()
        else vic.play()
    }
}
