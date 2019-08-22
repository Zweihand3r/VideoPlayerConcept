import QtQuick 2.13

import '../Components/Basic'

View {
    id: rootLp

    property int max: 0
    property int progress: 0

    MouseArea { anchors.fill: parent; onClicked: forceActiveFocus() }
    Rectangle { anchors.fill: parent; color: color_background; opacity: 0.75 }

    Rectangle {
        id: progressBg;
        width: 180; height: 14; radius: height / 2; anchors {
            centerIn: parent
        }

        color: "transparent"; border {
            width: 2; color: color_primary
        }

        Item {
            anchors { fill: parent; margins: 4 }

            Rectangle {
                height: parent.height; radius: height / 2
                width: parent.width * progress / max; color: color_primary
            }
        }
    }

    function start(_max) {
        max = _max
        progress = 0

        present()
    }

    function incrementProgress() {
        progress += 1
    }
}
