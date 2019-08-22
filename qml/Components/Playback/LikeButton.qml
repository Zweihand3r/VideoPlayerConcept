import QtQuick 2.13

import '../Basic'

MouseArea {
    id: rootLb
    implicitWidth: 44 + countText.implicitWidth
    implicitHeight: 44; hoverEnabled: true

    property int count: 0

    property bool checked: false

    Image {
        id: icon; x: 3; y: 3; width: 38; height: 38
        tint: checked ? settings.accentColor : cons.color.lightGray_1; source: {
            if (checked) return 'qrc:/assets/icons/x48/favorite.png'
            else return 'qrc:/assets/icons/x48/favorite_border.png'
        }
    }

    Text {
        id: countText; font.pixelSize: 15; anchors {
            left: icon.right; verticalCenter: icon.verticalCenter; leftMargin: 2
        }

        text: mac.formatNumber(count); color: cons.color.lightGray_1
    }

    onClicked: {
        checked = !checked
        count += checked ? 1 : -1

        updateView()
        libc.updateGlobalLikes(currentVidId, checked)
    }
}
