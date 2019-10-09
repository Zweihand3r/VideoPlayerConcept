import QtQuick 2.13
import QtQuick.Dialogs 1.2
import QtGraphicalEffects 1.13

import '../Components/Basic'
import '../Components/Shared'
import '../Components/Controls'

View {
    id: rootNav; objectName: "Navigation"; visible: true
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

    function back() {
        setCurrentId(navbar.currentNavId)
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

    ImageButton {
        id: addVidButton; imageWidth: 32; imageHeight: 32
        source: 'qrc:/assets/icons/x48/folder.png'; tint: color_primary; anchors {
            right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: 14
        }

        onClicked: fileDialog.open()
    }

    ImageButton {
        id: addCloudVidButton; imageWidth: 32; imageHeight: 32
        source: 'qrc:/assets/icons/x48/cloud.png'; tint: color_primary; anchors {
            right: addVidButton.left; verticalCenter: parent.verticalCenter; rightMargin: 6
        }

        onClicked: {
            selectUrlLt.present()
            addressTf.clear()
            addressTf.forceActiveFocus()
        }
    }

    FileDialog {
        id: fileDialog
        nameFilters: ["MP4 (*.mp4)", "AVI (*.avi)"]
        onAccepted: {
            const fileInfo = fm.getFileInfo(fileDialog.fileUrl)
            playback.loadExtVideo(fileDialog.fileUrl, fileInfo.baseName)
        }
    }

    View {
        id: selectUrlLt; resizable: false
        width: rootMC.width; height: rootMC.height

        MouseArea { anchors.fill: parent; onClicked: parent.dismiss() }
        Rectangle { anchors.fill: parent; color: color_background; opacity: 0.75 }

        Rectangle {
            width: 780; height: 100; color: color_content_bg; anchors {
                centerIn: parent
            }

            Text {
                id: infoText; color: color_secondary; font { pixelSize: 15 }
                text: "Type the web address of the video and hit Return ↵"; anchors {
                    horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 20
                }
            }

            Textfield {
                id: addressTf; placeholderText: "Type Web Address"; font.pixelSize: 15; anchors {
                    leftMargin: 20; topMargin: 8; rightMargin: 20
                    left: parent.left; top: infoText.bottom; right: parent.right;
                }

                Keys.onReturnPressed: {
                    playback.loadExtVideo(text.trim(), "WEB VIDEO")
                    selectUrlLt.dismiss()
                }
            }
        }
    }
}
