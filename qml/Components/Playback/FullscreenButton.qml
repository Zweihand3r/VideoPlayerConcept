import QtQuick 2.13

import '../Basic'

MouseArea {
    id: rootFb
    implicitWidth: 44
    implicitHeight: 44
    hoverEnabled: true

    Image {
        id: icon; width: parent.width; height: parent.height; anchors {
            centerIn: parent
        }

        tint: cons.color.lightGray_1; source: {
            if (!fullscreenActive) return 'qrc:/assets/icons/x48/fullscreen.png'
            else return 'qrc:/assets/icons/x48/fullscreen_exit.png'
        }
    }

    SequentialAnimation {
        id: expandAnim

        ScaleAnimator { target: icon; from: 1.0; to: 1.2; duration: 160 }
        ScaleAnimator { target: icon; from: 1.2; to: 1.0; duration: 160 }
    }

    SequentialAnimation {
        id: shrinkAnim

        ScaleAnimator { target: icon; from: 1.0; to: 0.8; duration: 160 }
        ScaleAnimator { target: icon; from: 0.8; to: 1.0; duration: 160 }
    }

    onClicked: toggleFullscreen()

    onEntered: {
        if (fullscreenActive) shrinkAnim.start()
        else expandAnim.start()
    }
}
