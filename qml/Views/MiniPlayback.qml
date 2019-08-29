import QtQuick 2.13
import QtMultimedia 5.13
import QtGraphicalEffects 1.13

import '../Components/QML'
import '../Components/Basic'
import '../Components/Controls'
import '../Components/Playback'

View {
    id: rootMPb
    resizable: false
    width: 380; height: 264
    objectName: "MiniPlayback"; anchors {
        bottom: parent.bottom; right: parent.right; rightMargin: 32
    }

    property bool active: visible
    property bool expanded: true

    Item {
        id: vidContainer
        y: expanded ? 0 : height
        width: parent.width; height: 224

        Behavior on y { NumberAnimation { duration: 120; easing.type: Easing.OutQuad }}

        Rectangle {
            id: bg; color: color_content_bg; anchors {
                fill: parent; bottomMargin: -40
            }
        }

        DropShadow {
            id: bg_shadow; anchors.fill: bg; source: bg; radius: 3
            color: settings.darkTheme ? cons.color.darkGray_1 : cons.color.lightGray_3
        }

        Video {
            id: video
            anchors { fill: parent }
            fillMode: VideoOutput.PreserveAspectCrop
        }

        MouseArea {
            anchors.fill: video; hoverEnabled: true

            Item {
                anchors.fill: parent; opacity: parent.containsMouse ? 1 : 0
                Rectangle { anchors.fill: parent; color: "black"; opacity: 0.65 }
                Behavior on opacity { OpacityAnimator { duration: 120; easing.type: Easing.InQuad }}

                PlayButton {
                    width: 54; height: 54; anchors {
                        centerIn: parent
                    }
                }

                ImageButton {
                    id: closeButton; width: 32; height: 32
                    source: 'qrc:/assets/icons/x24/close.png'; anchors {
                        top: parent.top; right: parent.right; margins: 2
                    }

                    onClicked: dismiss()
                }

                ImageButton {
                    width: 32; height: 32; rotation: -90; imageHorizontalOffset: 6
                    source: 'qrc:/assets/icons/x24/arrow_back.png'; anchors {
                        top: parent.top; right: closeButton.left; topMargin: 2; rightMargin: 0
                    }

                    onClicked: expanded = false
                }
            }
        }

        MiniSeekbar {
            anchors {
                left: video.left; right: video.right; bottom: video.bottom
            }
        }
    }

    Item {
        id: footerLt
        width: parent.width; height: 40; anchors {
            bottom: parent.bottom
        }

        Rectangle { anchors.fill: parent; color: bg.color; visible: !expanded }

        Item {
            width: 32; height: 32; anchors {
                left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 2
            }

            PlayButton {
                anchors.fill: parent
                scale: expanded ? 0 : 1; opacity: expanded ? 0 : 1

                Behavior on scale { ScaleAnimator { duration: 120 }}
                Behavior on opacity { OpacityAnimator { duration: 75 }}
            }
        }

        Text {
            id: vidNameText; color: color_primary; font {
                pixelSize: 14; family: "Open Sans"
            }

            anchors {
                leftMargin: expanded ? 12 : 34
                left: parent.left; verticalCenter: parent.verticalCenter
            }

            Behavior on anchors.leftMargin { NumberAnimation { duration: 120 }}
        }

        Item {
            anchors.fill: parent; opacity: expanded ? 0 : 1
            Behavior on opacity { OpacityAnimator { duration: 120 }}

            ImageButton {
                id: closeButtonFooter; width: 32; height: 32
                source: 'qrc:/assets/icons/x24/close.png'; anchors {
                    right: parent.right; verticalCenter: parent.verticalCenter; margins: 2
                }

                onClicked: dismiss()
            }

            ImageButton {
                width: 32; height: 32; rotation: 90; imageHorizontalOffset: 5
                source: 'qrc:/assets/icons/x24/arrow_back.png'; anchors {
                    right: closeButtonFooter.left; verticalCenter: parent.verticalCenter
                }

                onClicked: expanded = true
            }
        }
    }

    function dismiss() {
        if (video.playbackState === MediaPlayer.PlayingState) {
            video.pause()
        }

        rootMPb.visible = false
    }

    function loadCurrentVideo() {
        const currentVid = playback.currentVid

        video.source = currentVid.path
        video.play()

        vidNameText.text = currentVid.name

        present()
    }
}
