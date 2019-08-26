import QtQuick 2.13
import QtQuick.Dialogs 1.2
import QtGraphicalEffects 1.13

import '../Components/Basic'
import '../Components/Shared'
import '../Components/Controls'

View {
    id: rootNav; visible: true
    width: parent.width; height: 64; resizable: false; anchors {
        top: parent.top; topMargin: fullscreenActive ? -height : 0
    }

    property string currentId: cons.nav.home
    property View currentItem: home

    readonly property var map: {
        "playback": playback,

        "home": home,
        "history": history,
        "favorites": favorites,
        "library": library,
        "settings": settings,

        "nav": nav, "navbar": navbar
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

    function setCurrentId(navId) {
        if (map[navId]) {
            currentItem.dismiss()
            currentItem.navigatedAway()

            currentId = navId
            currentItem = map[navId]

            currentItem.present()
            currentItem.navigatedTo()

            updateTheme(settings.darkTheme)
        }
    }

    /* ---------------- OVERRIDES ----------------- */

    function updateTheme(darkTheme) {
        if (currentId === cons.nav.playback) setDarkTheme()
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
