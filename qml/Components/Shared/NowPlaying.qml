import QtQuick 2.13

Rectangle {
    id: rootNp
    opacity: _isPlaying ? 1 : 0
    color: Qt.rgba(0, 0, 0, 0.85)
    Behavior on opacity { OpacityAnimator { duration: 120 }}

    Text {
        anchors { fill: parent }
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap; lineHeight: 0.8
        text: "NOW PLAYING"; color: cons.color.lightGray_1; font {
            pixelSize: 14; family: "Open Sans"
        }
    }
}
