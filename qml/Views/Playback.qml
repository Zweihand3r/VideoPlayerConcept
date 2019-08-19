import QtQuick 2.13
import QtMultimedia 5.13

import '../Components/Basic'
import '../Components/Playback'

View {
    id: rootPb

    property int currentVidId: -1

    Rectangle {
        id: vidContainer; color: "black"; anchors {
            fill: parent; /*leftMargin: 20; topMargin: 20; rightMargin: 440; bottomMargin: 180*/
        }

        Video {
            id: video; anchors.fill: parent; focus: true

            Keys.onSpacePressed: togglePlayPause()
            Keys.onLeftPressed: video.seek(video.position - 5000)
            Keys.onRightPressed: video.seek(video.position + 5000)
        }

        MouseArea {
            anchors.fill: parent; hoverEnabled: true

            onExited: hideControlPanel()
            onClicked: togglePlayPause()
            onMouseXChanged: showControlPanel(mouseY)
            onMouseYChanged: showControlPanel(mouseY)

            Item {
                id: playPauseIndicator
                width: 54; height: 54; opacity: 0; anchors { centerIn: parent }
                Rectangle { anchors.fill: parent; color: cons.color.darkGray_1; opacity: 0.75; radius: width / 2 }
                Image { id: playPauseIndicatorIcon; tint: cons.color.lightGray_1; anchors { fill: parent; margins: 16 } }

                ParallelAnimation {
                    id: playPauseIndicatorAnim
                    ScaleAnimator { target: playPauseIndicator; from: 1; to: 1.25; duration: 360; easing.type: Easing.InQuad }
                    OpacityAnimator { target: playPauseIndicator; from: 1; to: 0; duration: 360; easing.type: Easing.InQuad }
                }
            }

            Item {
                id: controlPanel; height: 64; opacity: 0; anchors {
                    left: parent.left; right: parent.right; bottom: parent.bottom
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width; height: 96; gradient: Gradient {
                        GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.75) }
                        GradientStop { position: 0.1; color: Qt.rgba(0, 0, 0, 0.025) }
                        GradientStop { position: 0.2; color: Qt.rgba(0, 0, 0, 0.05) }
                        GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0) }
                    }
                }

                Behavior on opacity { OpacityAnimator { duration: 180 }}

                Seekbar {
                    id: seekbar; anchors {
                        leftMargin: 20; rightMargin: 20; topMargin: -10
                        left: parent.left; right: parent.right; top: parent.top
                    }
                }


                /* --------------- LEFT CONTROLS ------------- */

                PlayButton {
                    id: playButton; anchors {
                        left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 20
                    }
                }

                VolumeButton {
                    id: volumeButton; anchors {
                        left: playButton.right; verticalCenter: parent.verticalCenter
                    }
                }

                Text {
                    id: durationText; font.pixelSize: 17; color: cons.color.lightGray_1; anchors {
                        left: volumeButton.right; verticalCenter: parent.verticalCenter; leftMargin: 14
                    }
                }


                /* -------------- RIGHT CONTROLS ------------- */

                FullscreenButton {
                    id: fullscreenButton; anchors {
                        right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: 20
                    }
                }
            }
        }
    }

    Timer {
        id: hideCtrlPanelTimer
        interval: 3000; onTriggered: {
            hideControlPanel()
        }
    }

    function navigatedAway() {
        if (video.playbackState === MediaPlayer.PlayingState) {
            video.pause()
        }
    }

    function loadVideo(vid_id) {
        const path = libc.videos[vid_id].path
        video.source = path

        durationText.text = Qt.binding(function() {
            return mac.msToTimeStr(video.position) + " / " + mac.msToTimeStr(video.duration)
        })

        currentVidId = vid_id
        nav.setCurrentIndex(99)

        libc.updateViews(vid_id)
        mac.executeAfter(440, video.play)
    }

    function togglePlayPause() {
        if (video.playbackState === MediaPlayer.PlayingState) {
            video.pause()
            playPauseIndicatorIcon.source = 'qrc:/assets/icons/x32/pause.png'
        } else {
            video.play()
            playPauseIndicatorIcon.source = 'qrc:/assets/icons/x32/play.png'
        }

        playPauseIndicatorAnim.start()
    }

    function toggleFullscreen() {
        if (!fullscreenActive) {
            mainWindow.showFullScreen()
            fullscreenActive = true
        } else {
            mainWindow.showNormal()
            fullscreenActive = false
        }
    }

    function showControlPanel(mouseY) {
        if (mouseY < controlPanel.y - 10) {
            if (hideCtrlPanelTimer.running) {
                hideCtrlPanelTimer.restart()
            } else {
                hideCtrlPanelTimer.start()
            }

        } else {
            if (hideCtrlPanelTimer.running) {
                hideCtrlPanelTimer.stop()
            }
        }

        controlPanel.opacity = 1
    }

    function hideControlPanel() {
        controlPanel.opacity = 0
    }
}
