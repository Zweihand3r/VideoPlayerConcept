import QtQuick 2.13
import QtMultimedia 5.13

import '../Components/Basic'
import '../Components/Playback'

View {
    id: rootPb
    objectName: "Playback"

    property bool externalVideo: false

    property int currentVidId: -1
    property int currentViewId: -1

    property var currentVid: ({})

    Rectangle {
        id: vidContainer; color: "black"; anchors {
            fill: parent; /*leftMargin: 20; topMargin: 20; rightMargin: 440; bottomMargin: 180*/
        }

        Video {
            id: video; anchors.fill: parent; focus: true

            Keys.onSpacePressed: togglePlayPause()
            Keys.onLeftPressed: replay()
            Keys.onRightPressed: forward()
        }

        MouseArea {
            anchors.fill: parent; hoverEnabled: true

            onExited: hideControlPanel()
            onClicked: togglePlayPause()
            onMouseXChanged: showControlPanel(mouseY)
            onMouseYChanged: showControlPanel(mouseY)

            Item {
                id: playbackControlIndicator
                width: 54; height: 54; opacity: 0; anchors { centerIn: parent }
                Rectangle { anchors.fill: parent; color: cons.color.darkGray_1; opacity: 0.75; radius: width / 2 }
                Image { id: playbackControlIcon; tint: cons.color.lightGray_1; anchors { fill: parent; margins: 8 } }

                ParallelAnimation {
                    id: playbackControlAnim
                    ScaleAnimator { target: playbackControlIndicator; from: 1; to: 1.25; duration: 360; easing.type: Easing.InQuad }
                    OpacityAnimator { target: playbackControlIndicator; from: 1; to: 0; duration: 360; easing.type: Easing.InQuad }
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

                LikeButton {
                    id: likeButton; anchors {
                        right: fullscreenButton.left; verticalCenter: parent.verticalCenter; rightMargin: 12
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

    Timer {
        /* View Update timer */
        running: rootPb.visible; interval: 60000; onTriggered: {
            updateView()
        }
    }

    /* -------------------- OVERRIDES -------------------- */

    function navigatedAway() {
        if (video.playbackState === MediaPlayer.PlayingState) {
            video.pause()
        }

        updateView()
    }

    /* -------------------- FUNCTIONS -------------------- */

    function loadVideo(vid_id) {
        currentVidId = vid_id
        currentVid = libc.videos[vid_id]

        likeButton.visible = true
        likeButton.count = currentVid.likes

        externalVideo = false

        sharedVidLoader(currentVid.path)
        loadView(vid_id)
    }

    function loadExtVideo(url) {
        likeButton.visible = false
        externalVideo = true

        sharedVidLoader(url)
    }

    function loadView(vid_id) {
        const view = usc.getUserView(vid_id)

        if (currentViewId !== view.id) {
            currentViewId = view.id

            if ((currentVid.duration - view.duration) < 1000) {
                video.seek(0)
            } else if (view.duration > 0) video.seek(view.duration)

            likeButton.checked = view.liked

            libc.updateGlobalViews(vid_id)
        }
    }

    function sharedVidLoader(path) {
        video.source = path
        video.volume = settings.volume

        durationText.text = Qt.binding(function() {
            return mac.msToTimeStr(video.position) + " / " + mac.msToTimeStr(video.duration)
        })

        nav.setCurrentId(cons.nav.playback)
        mac.executeAfter(440, video.play)
    }

    function updateView() {
        usc.updateUserView(currentViewId, video.position, likeButton.checked ? 1 : 0)
    }

    /* ---------------- PLAYBACK CONTROLS ---------------- */

    function togglePlayPause() {
        if (video.playbackState === MediaPlayer.PlayingState) {
            video.pause()
            animatePlaybackControls('qrc:/assets/icons/x48/pause.png')
        } else {
            video.play()
            animatePlaybackControls('qrc:/assets/icons/x48/play.png')
        }
    }

    function replay() {
        video.seek(video.position - 5000)
        animatePlaybackControls('qrc:/assets/icons/x48/replay_5.png')
    }

    function forward() {
        video.seek(video.position + 5000)
        animatePlaybackControls('qrc:/assets/icons/x48/forward_5.png')
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

    function animatePlaybackControls(source) {
        playbackControlIcon.source = source
        playbackControlAnim.start()
    }
}
