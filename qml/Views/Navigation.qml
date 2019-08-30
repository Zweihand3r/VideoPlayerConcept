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
        source: 'qrc:/assets/icons/x48/folder.png'; tint: color_secondary; anchors {
            right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: 14
        }

        onClicked: fileDialog.open()
    }

    ImageButton {
        id: addCloudVidButton; imageWidth: 32; imageHeight: 32
        source: 'qrc:/assets/icons/x48/cloud.png'; tint: color_secondary; anchors {
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

    /*
     - SOME YOUTUBE DOWNLOAD LINKS -
     https://r5---sn-a5meknsd.googlevideo.com/videoplayback?expire=1566923796&ei=swdlXcHTOcPKkgafqq6ACQ&ip=69.147.248.110&id=o-AILbSpcLmfX8HYoWXkZH3kfvZg0tSAQYHa2mvqgrUJfp&itag=18&source=youtube&requiressl=yes&mm=31%2C29&mn=sn-a5meknsd%2Csn-a5msen7s&ms=au%2Crdu&mv=m&mvi=4&pl=23&initcwndbps=4001250&mime=video%2Fmp4&gir=yes&clen=12645047&ratebypass=yes&dur=276.851&lmt=1538599572351131&mt=1566902110&fvip=5&c=WEB&txp=5531432&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Cmime%2Cgir%2Cclen%2Cratebypass%2Cdur%2Clmt&sig=ALgxI2wwRAIgdLYhO_5356KScyBltU8U1F6mNcsYbYnoct0LhuxRa9sCIGu1TodpDwZMuZqQsYcqIbiwENQOCYX2e8rF7-nIyhAq&lsparams=mm%2Cmn%2Cms%2Cmv%2Cmvi%2Cpl%2Cinitcwndbps&lsig=AHylml4wRAIgGj1mtwcFk3pD6WxZ4gCk4h766olbfC6tT8Ov2nUqi-UCIFe7PR-1Rz1zBb4KtDDr5JnLW4ZxHoW1XX_9JK1TJB9Y&video_id=2_uDzzOb5po&title=Viva+La+Vida+-+Coldplay+%28Cover%29+by+Alice+Kristiansen
     https://r2---sn-a5ms7n7l.googlevideo.com/videoplayback?expire=1566922691&ei=YwNlXamFK47Xkgafya2ICA&ip=69.147.248.136&id=o-AC7LGC-qaZvzPyYeWN4pJATuE8Xlc-G4n0fakORWEK6J&itag=18&source=youtube&requiressl=yes&mm=31%2C29&mn=sn-a5ms7n7l%2Csn-a5mlrn7d&ms=au%2Crdu&mv=m&mvi=1&pl=23&initcwndbps=4001250&mime=video%2Fmp4&gir=yes&clen=243405510&ratebypass=yes&dur=4463.455&lmt=1540523786028655&mt=1566901074&fvip=2&c=WEB&txp=5531432&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Cmime%2Cgir%2Cclen%2Cratebypass%2Cdur%2Clmt&lsparams=mm%2Cmn%2Cms%2Cmv%2Cmvi%2Cpl%2Cinitcwndbps&lsig=AHylml4wRQIgU5qMGGyj8a2T6RSPrULLFK8dyczD0npjw2HKt4yeP6kCIQCv7-2Na_Hcyi7ebwVkMQGRXXi7GI-K6QdsHUM2kw0lyg%3D%3D&sig=ALgxI2wwRgIhAM4yemOaIeqMoOlgxfSrz70QZuH1PBfhJXA2cw2q4lHJAiEAzWs1WNkVcf08jCGWzvmzAqB4CVxYkATQZlHU_xqkVqo%3D&video_id=N2mVfpDHr9k&title=%27Peaceful+Solitude%27+Mix
     */
}
