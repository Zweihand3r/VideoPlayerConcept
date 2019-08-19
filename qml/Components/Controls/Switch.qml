import QtQuick 2.13

Item {
    id: rootSwitch
    implicitWidth: 128
    implicitHeight: 36

    property bool checked: false

    property int switchWidth: 36
    property int switchHeight: 18

    property int fontSize: 21

    property string text: "Switch"

    property string color_text: color_primary
    property string color_switchBg: color_primary
    property string color_switchPrim: color_content_bg

    signal clicked()


    Text {
        text: parent.text; color: color_text; font {
            pixelSize: fontSize; family: "Open Sans"; weight: Font.Light
        }

        anchors {
            verticalCenter: parent.verticalCenter
        }
    }

    Rectangle {
        width: switchWidth; height: switchHeight
        color: color_switchBg; radius: height / 2; anchors {
            right: parent.right; verticalCenter: parent.verticalCenter
        }

        MouseArea {
            cursorShape: Qt.PointingHandCursor; anchors {
                fill: parent; margins: 2
            }

            onClicked: {
                checked = !checked
                rootSwitch.clicked()
            }

            Rectangle {
                id: indicator; x: checked ? parent.width - width : 0
                width: parent.height; height: width;  radius: width / 2; color: color_switchPrim
                Behavior on x { NumberAnimation { duration: 120; easing.type: Easing.OutQuad }}
            }
        }
    }
}
