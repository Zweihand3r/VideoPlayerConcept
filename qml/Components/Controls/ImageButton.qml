import QtQuick 2.13

import '../Basic'

MouseArea {
    id: rootIb
    implicitWidth: 44
    implicitHeight: 44
    cursorShape: Qt.PointingHandCursor

    onPressed: pressAnim.start()
    onReleased: releaseAnim.start()

    property color tapColor: tint

    property alias imageWidth: image.width
    property alias imageHeight: image.height

    property alias source: image.source
    property alias tint: image.tint
    property alias fillMode: image.fillMode

    property int imageHorizontalOffset: 0
    property int imageVerticalOffset: 0

    Image {
        id: image
        tint: cons.color.lightGray_1; anchors {
            centerIn: parent
            horizontalCenterOffset: imageHorizontalOffset
            verticalCenterOffset: imageVerticalOffset
        }
    }

    Rectangle {
        id: tapIndicator
        scale: 0.8; opacity: 0.0
        color: tapColor; radius: width / 2; anchors {
            fill: parent
        }
    }

    ParallelAnimation {
        id: pressAnim
        ScaleAnimator { target: tapIndicator; from: 0.64; to: 1; duration: 92; easing.type: Easing.OutQuad }
        OpacityAnimator { target: tapIndicator; from: 0; to: 0.44; duration: 54; easing.type: Easing.OutQuad }
    }

    ParallelAnimation {
        id: releaseAnim
        ScaleAnimator { target: tapIndicator; from: 1; to: 0.84; duration: 240; easing.type: Easing.InQuad }
        OpacityAnimator { target: tapIndicator; from: 0.44; to: 0; duration: 240; easing.type: Easing.InQuad }
    }
}
