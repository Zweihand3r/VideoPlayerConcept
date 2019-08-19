import QtQuick 2.13
import QtQuick.Dialogs 1.2
import QtGraphicalEffects 1.13

import '../Components/Basic'
import '../Components/Shared'
import '../Components/Controls'

View {
    id: rootNav; visible: true
    width: parent.width; height: 64; anchors {
        top: parent.top; topMargin: fullscreenActive ? -height : 0
    }

    property int currentIndex: 0
    property View currentItem: home

    readonly property var map: {
        99: playback, 0: home, 1: library, 2: settings,

        100: nav, 101: navbar
    }

    Rectangle { id: bg; anchors.fill: parent; color: color_background }
    DropShadow { id: bg_shadow; anchors.fill: bg; color: cons.color.lightGray_3; source: bg; radius: 8 }

    MenuButton {
        id: menuButton; anchors {
            left: parent.left; leftMargin: 4; verticalCenter: parent.verticalCenter
        }

        onClicked: navbar.present()
    }

    Logo {
        id: logo; anchors {
            left: menuButton.right; leftMargin: 4; verticalCenter: parent.verticalCenter
        }
    }

    Component.onCompleted: {
        updateTheme(settings.darkTheme)
    }

    function setCurrentIndex(navIndex) {
        if (navIndex < 100) {
            currentItem.dismiss()
            currentItem.navigatedAway()

            currentIndex = navIndex
            currentItem = map[currentIndex]

            currentItem.present()
            currentItem.navigatedTo()

            updateTheme(settings.darkTheme)
        }
    }

    /* ---------------- OVERRIDES ----------------- */

    function updateTheme(darkTheme) {
        if (currentIndex === 99) setDarkTheme()
        else {
            if (darkTheme) setDarkTheme()
            else setLightTheme()
        }
    }



    /* ------------- CLASS FUNCTIONS -------------- */

    function setDarkTheme() {
        bg.color = cons.color.darkGray_2
        bg_shadow.visible = false

        menuButton.tint = cons.color.lightGray_1

        logo.color = cons.color.lightGray_1
        logo.accent = cons.color.lightGray_1
    }

    function setLightTheme() {
        bg.color = cons.color.lightGray_1
        bg_shadow.visible = true

        menuButton.tint = cons.color.darkGray_1

        logo.color = cons.color.darkGray_1
        logo.accent = color_accent
    }


    /* ------------------- TEMP ------------------- */

    /*ImageButton {
        id: addVidButton; imageWidth: 32; imageHeight: 32
        source: 'qrc:/assets/icons/x48/video_call.png'; tint: color_primary; anchors {
            right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: 8
        }

        onClicked: fileDialog.open()
    }

    FileDialog {
        id: fileDialog
        nameFilters: ["MP4 (*.mp4)", "AVI (*.avi)"]
        onAccepted: playback.loadVideo(fileDialog.fileUrl)
    }*/
}
