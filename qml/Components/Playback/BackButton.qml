import QtQuick 2.13
import QtQuick.Layouts 1.13

import '../Basic'

RowLayout {
    id: rootBB
    height: 44

    MouseArea {
        id: hovery
        hoverEnabled: true; cursorShape: Qt.PointingHandCursor
        Layout.preferredWidth: parent.height; Layout.preferredHeight: width

        onClicked: nav.back()

        Image {
            width: 40; height: 40
            source: 'qrc:/assets/icons/x48/arrow_back_tail.png'
            tint: cons.color.lightGray_1; fillMode: Image.Stretch; anchors {
                centerIn: parent
            }
        }
    }

    Text {
        Layout.alignment: Qt.AlignVCenter; opacity: hovery.containsMouse ? 1 : 0
        text: "Back to " + navbar.currentNavName; color: cons.color.lightGray_1; font {
            pixelSize: 23; family: "Open Sans"
        }

        Behavior on opacity { OpacityAnimator { duration: 120 }}
    }
}
