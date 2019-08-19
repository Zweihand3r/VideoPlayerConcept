import QtQuick 2.13
import QtMultimedia 5.13
import QtQuick.Layouts 1.13
import QtQuick.Controls 2.5

Rectangle {
    id: rootVp
    width: applicationWidth
    height: applicationHeight

    property int currentVidIndex: -1

    property bool isFullscreen: false

    ListView {
        id: vidsLV; spacing: 2; anchors {
            left: playbackContainer.right; top: parent.top; right: parent.right; bottom: parent.bottom; margins: 20
        }

        model: vidsModel
        delegate: MouseArea {
            width: vidsLV.width; height: 78; hoverEnabled: true

            Rectangle {
                color: containsMouse ? cons.color.darkGray_1 : "transparent"
                anchors.fill: parent; border { width: 2; color: cons.color.darkGray_1 }
            }

            Rectangle {
                width: 20; height: 20; anchors {
                    top: parent.top; right: parent.right
                }

                color: cons.color.darkGray_1; visible: index === currentVidIndex

                Image {
                    anchors { fill: parent; margins: 4 } source: {
                        switch (playback.playbackState) {
                        case MediaPlayer.PausedState:
                        case MediaPlayer.StoppedState: return 'qrc:/assets/icons/pause.png'
                        case MediaPlayer.PlayingState: return 'qrc:/assets/icons/play.png'
                        }
                    }
                }
            }

            ColumnLayout {
                spacing: -3; anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left; right: parent.right; margins: 8
                }

                Text {
                    Layout.preferredWidth: parent.width; font.pixelSize: 18; text: _name
                    color: containsMouse ? cons.color.lightGray_1 : cons.color.darkGray_1
                }

                Text {
                    font.pixelSize: 12; lineHeight: 0.9; text: _path
                    Layout.preferredWidth: parent.width; wrapMode: Text.Wrap;
                    color: containsMouse ? cons.color.lightGray_1 : cons.color.darkGray_1
                }
            }

            onClicked: selectVideo(index)
        }
    }

    MouseArea {
        width: 44; height: 44; hoverEnabled: true; anchors {
            right: parent.right; bottom: parent.bottom; margins: 24
        }

        Rectangle {
            color: parent.containsMouse ? cons.color.darkGray_1 : "transparent"
            anchors.fill: parent; radius: width / 2; border { width: 4; color: cons.color.darkGray_1 }
        }

        Text {
            font.pixelSize: 55; text: "+"
            color: parent.containsMouse ? cons.color.lightGray_1 : cons.color.darkGray_1; anchors {
                centerIn: parent; verticalCenterOffset: -5; horizontalCenterOffset: 1
            }
        }

        onClicked: openFileSelection(rootVp)
    }

    Rectangle {
        id: playbackContainer
        color: "black"; width: 1000; anchors {
            leftMargin: 20; topMargin: 20; bottomMargin: 20
            left: parent.left; top: parent.top; bottom: parent.bottom
        }

        Video {
            id: playback; anchors {
                fill: parent
            }

            focus: true
            Keys.onSpacePressed: playback.playbackState === MediaPlayer.PlayingState ? playback.pause() : playback.play()
            Keys.onLeftPressed: playback.seek(playback.position - 5000)
            Keys.onRightPressed: playback.seek(playback.position + 5000)
        }

        MouseArea {
            anchors.fill: parent; onClicked: {
                switch (playback.playbackState) {
                case MediaPlayer.PausedState:
                case MediaPlayer.StoppedState: playback.play(); break
                case MediaPlayer.PlayingState: playback.pause(); break
                }
            }
        }

        Item {
            id: playbackPanel; height: 32; anchors {
                left: parent.left; right: parent.right; bottom: parent.bottom
            }

            VSlider {
                id: seeker; from: 0; to: playback.duration; value: playback.position; anchors {
                    bottomMargin: -8; leftMargin: 8; rightMargin: 8
                    bottom: parent.top; left: parent.left; right: parent.right
                }

                onMoved: playback.seek(value)
            }

            RowLayout {
                spacing: 12; anchors {
                    left: parent.left; top: parent.top; bottom: parent.bottom; leftMargin: 12
                }

                MouseArea {
                    Layout.preferredWidth: parent.height; Layout.preferredHeight: width

                    Image {
                        anchors { fill: parent; margins: 6 } source: {
                            switch (playback.playbackState) {
                            case MediaPlayer.PausedState:
                            case MediaPlayer.StoppedState: return 'qrc:/assets/icons/play.png'
                            case MediaPlayer.PlayingState: return 'qrc:/assets/icons/pause.png'
                            }
                        }
                    }

                    onClicked: {
                        switch (playback.playbackState) {
                        case MediaPlayer.PausedState:
                        case MediaPlayer.StoppedState: playback.play(); break
                        case MediaPlayer.PlayingState: playback.pause(); break
                        }
                    }
                }

                ColumnLayout {
                    Layout.alignment: Qt.AlignVCenter; spacing: -3

                    Repeater {
                        model: ["V", "O", "L"]
                        Text { text: modelData; font { pixelSize: 8; bold: true } color: cons.color.lightGray_1 }
                    }
                }

                VSlider {
                    Layout.leftMargin: -12
                    Layout.preferredWidth: 98; Layout.alignment: Qt.AlignVCenter
                    value: playback.volume; onMoved: playback.volume = value
                }

                Text {
                    color: cons.color.lightGray_1; font.pixelSize: 16
                    text: mstoTimeStr(playback.position) + " / " + mstoTimeStr(playback.duration)
                }
            }

            RowLayout {
                spacing: 12; anchors {
                    right: parent.right; top: parent.top; bottom: parent.bottom; rightMargin: 20
                }

                MouseArea {
                    Layout.preferredWidth: 28; Layout.preferredHeight: 18

                    Rectangle {
                        anchors.fill: parent; color: "transparent"; border {
                            width: 3; color: cons.color.lightGray_1
                        }

                        Rectangle {
                            width: 6; height: parent.height; anchors {
                                centerIn: parent
                            } color: "black"
                        }

                        Rectangle {
                            width: parent.width; height: 4; anchors {
                                centerIn: parent
                            } color: "black"
                        }
                    }

                    onClicked: {
                        if (!isFullscreen) {
                            isFullscreen = true
                            mainWindow.showFullScreen()
                        } else {
                            isFullscreen = false
                            mainWindow.showNormal()
                        }
                    }
                }
            }
        }
    }

    ListModel {
        id: vidsModel
        ListElement { _name: "I-saw-with-my-own-eyes"; _extension: "mp4"; _path: "qrc:/assets/videos/I-saw-with-my-own-eyes.mp4" }
        ListElement { _name: "Just-a-100fps-eyecandy"; _extension: "mp4"; _path: "qrc:/assets/videos/Just-a-100fps-eyecandy.mp4" }
    }

    function selectVideo(index) {
        const vid = vidsModel.get(index)
        currentVidIndex = index

        playback.source = vid._path
        playback.play()
    }

    function mstoTimeStr(s) {
        // Pad to 2 or 3 digits, default is 2
        function pad(n, z) {
            z = z || 2;
            return ('00' + n).slice(-z);
        }

        var ms = s % 1000;
        s = (s - ms) / 1000;
        var secs = s % 60;
        s = (s - secs) / 60;
        var mins = s % 60;
        var hrs = (s - mins) / 60;

        return pad(hrs) + ':' + pad(mins) + ':' + pad(secs)
    }

    function finaliseFileSelection() {
        fileDialog.fileUrls.forEach(function(path) {
            for (var index = 0; index < vidsModel.count; index++) {
                if (path === vidsModel.get(index)._path) return
            }

            const fileInfo = fm.getFileInfo(path)
            vidsModel.append({ "_name": fileInfo.baseName, "_extension": fileInfo.suffix, "_path": path })
        })
    }
}
