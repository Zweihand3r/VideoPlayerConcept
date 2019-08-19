import QtQuick 2.13
import QtQuick.Controls 2.5

Slider {
    id: rootVSl

    background: Rectangle {
        x: rootVSl.leftPadding
        y: rootVSl.topPadding + rootVSl.availableHeight / 2 - height / 2
        implicitWidth: 200; implicitHeight: 4; color: "#676767"
        width: rootVSl.availableWidth; height: implicitHeight; radius: 2

        Rectangle {
            width: rootVSl.visualPosition * parent.width
            height: parent.height; color: cons.color.lightGray_1; radius: 2
        }
    }

    handle: Rectangle {
        x: rootVSl.leftPadding + rootVSl.visualPosition * (rootVSl.availableWidth - width)
        y: rootVSl.topPadding + rootVSl.availableHeight / 2 - height / 2
        implicitWidth: 12; implicitHeight: 12; radius: 6
        color: rootVSl.pressed ? "#f0f0f0" : "#f6f6f6"
        border.color: "#bdbebf"
    }
}
