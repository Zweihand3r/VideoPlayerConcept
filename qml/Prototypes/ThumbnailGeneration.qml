import QtQuick 2.13
import QtMultimedia 5.13
import QtQuick.Layouts 1.13
import QtQuick.Controls 2.5

Item {
    id: rootTGen

    property var paths: []
    property var modelPaths: []

    property int tg_Index: 0

    Item {
        id: vidFrame
        width: 136; height: 76; anchors.right: parent.right
        Video { id: vidLoader; anchors.fill: parent; muted: true }

        Image {
            id: stimage
            visible: false; anchors.centerIn: parent
            source: 'qrc:/assets/icons/x48/video_call.png'
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (vidLoader.playbackState === MediaPlayer.PlayingState) {
                    vidLoader.pause()
                } else {
                    vidLoader.play()
                }
            }
        }
    }

//    Rectangle { id: cover; anchors.fill: parent }

    ColumnLayout {
        id: buttonLt; anchors {
            left: parent.left; top: parent.top; margins: 20
        }

        Repeater {
            model: ["Add files", "Test Screengrab"]

            Button {
                text: modelData
                Layout.preferredWidth: 220

                onClicked: {
                    switch (modelData) {
                    case "Add files": openFileSelection(rootTGen); break
                    case "Test Screengrab": screenshotTest(); break
                    }
                }
            }
        }
    }

    ColumnLayout {
        id: thumbnailLt; anchors {
            left: buttonLt.right; top: parent.top; margins: 20
        }

        Repeater {
            id: thumbRep
            model: ListModel {
                id: thumbModel
                /*ListElement { _path: "" }*/
            }

            Rectangle {
                Layout.preferredWidth: 136; Layout.preferredHeight: 76
                color: "grey"; Image {
                    source: _path; anchors.centerIn: parent
                }
            }
        }
    }

    Image {
        id: testImage; anchors {
            bottom: parent.bottom
        }
    }

    Timer {
        id: screenshotTestTimer
        interval: 100; onTriggered: {
            stimage.visible = false
        }
    }

    Timer {
        id: thumbnailGenTimer
        interval: 250; onTriggered: {
            thumbGenerationLoop()
        }
    }

    Timer {
        id: thumbnailProcessTimer
        interval: 250; onTriggered: {
            thumbnailProcessLoop()
        }
    }

    function finaliseFileSelection() {
        paths = []

        fileDialog.fileUrls.forEach(function(path) {
            paths.push(path)
        })

        startThumbGeneration()
    }

    function startThumbGeneration() {
        tg_Index = 0
        thumbnailGenTimer.start()
    }

    function thumbGenerationLoop() {
        if (tg_Index < paths.length) {
            const path = paths[tg_Index++]

            vidLoader.source = path

            vidLoader.play()
            vidLoader.seek(4000)
            vidLoader.pause()

            thumbnailProcessTimer.start()
        } else {
            /* Completion */

            modelPaths.forEach(function(path) {
                thumbModel.append({ "_path": "file:/" + fm.currentPath + "/" + path })
            })
        }
    }

    function thumbnailProcessLoop() {
        vidFrame.grabToImage(function(result) {
            const path = "thumb_" + tg_Index + ".png"
            result.saveToFile(path)
            modelPaths.push(path)

            console.log("ThumbnailGeneration.qml: saved to " + path)
        })

        thumbnailGenTimer.start()
    }

    function screenshotTest() {
        stimage.visible = true
        vidFrame.grabToImage(function(result) {
            testImage.source = result.url
        })
        screenshotTestTimer.start()
    }
}
