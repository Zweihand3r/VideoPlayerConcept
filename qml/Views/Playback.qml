import QtQuick 2.13

import '../Components/Basic'
import '../Components/Playback'

PlaybackView {
    id: rootPb
    objectName: "Playback"

    property string currentVidName: "Video"

    property int currentVidId: -1
    property int currentViewId: -1

    property var currentVid: ({})

    Rectangle {
        id: vidContainer; color: "black"; anchors {
            fill: parent; /*leftMargin: 20; topMargin: 20; rightMargin: 440; bottomMargin: 180*/
        }

        Item {
            id: vidParent; anchors {
                fill: parent
            }
        }

        MouseArea {
            anchors.fill: parent; hoverEnabled: true

            onExited: hideControlPanel()
            onClicked: vic.togglePlayPause()
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
                id: controlPanel; opacity: 0; anchors {
                    fill: parent
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


                BackButton {
                    id: backButton; anchors {
                        leftMargin: 20; topMargin: 12
                        left: parent.left; top: parent.top
                    }
                }

                Item {
                    id: bottomPanel; height: 64; anchors {
                        left: parent.left; right: parent.right; bottom: parent.bottom
                    }

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

    function loadVideo(vid_id) {
        prepPlayback()

        currentVidId = vid_id
        currentVid = libc.videos[vid_id]
        currentVidName = currentVid.name

        likeButton.visible = true
        likeButton.count = currentVid.likes

        const watchedDuration = loadView(vid_id)
        sharedVidLoader(currentVid.path, watchedDuration)
    }

    function loadExtVideo(url, name) {
        prepPlayback()

        currentVidId = -1
        currentVid = {}
        currentVidName = name

        likeButton.visible = false
        sharedVidLoader(url, 0)
    }

    function continueVideo() {
        durationText.text = Qt.binding(function() {
            return mac.msToTimeStr(vic.position) + " / " + mac.msToTimeStr(vic.duration)
        })

        vic.reparent(vidParent, false)
        nav.setCurrentId(cons.nav.playback)
    }


    /* -------------------- OVERRIDES -------------------- */

    function navigatedAway() {
        if (settings.enableMiniPlayer) {
            miniPlayback.continueCurrentVideo()
        } else {
            vic.pauseIfPlaying()
        }

        updateView()
    }

    function played() { animatePlaybackControls('qrc:/assets/icons/x48/play.png') }
    function paused() { animatePlaybackControls('qrc:/assets/icons/x48/pause.png') }
    function replayed() { animatePlaybackControls('qrc:/assets/icons/x48/replay_5.png') }
    function forwarded() { animatePlaybackControls('qrc:/assets/icons/x48/forward_5.png') }


    /* -------------------- FUNCTIONS -------------------- */

    function prepPlayback() {
        navbar.currentItem.videoUnloaded(currentVidId)

        if (miniPlayback.active && settings.enableMiniPlayer) {
            updateView()
            navbar.currentItem.videoUpdated(currentVidId, currentViewId)
        }
    }

    function sharedVidLoader(path, watchedDuration) {
        if (miniPlayback.active && settings.enableMiniPlayer) {
            miniPlayback.loadVideo(path, watchedDuration)
        } else {
            vic.reparent(vidParent, false)
            vic.load(path, watchedDuration)

            durationText.text = Qt.binding(function() {
                return mac.msToTimeStr(vic.position) + " / " + mac.msToTimeStr(vic.duration)
            })

            nav.setCurrentId(cons.nav.playback)
            mac.executeAfter(440, vic.play)
        }

        navbar.currentItem.videoLoaded(currentVidId)
    }

    function loadView(vid_id) {
        var watchedDuration = vic.position
        const view = usc.getUserView(vid_id)

        if (currentViewId !== view.id) {
            currentViewId = view.id
            likeButton.checked = view.liked

            if ((currentVid.duration - view.duration) < 1000) {
                watchedDuration = 0
            } else { watchedDuration = view.duration }

            libc.updateGlobalViews(vid_id)
        }

        return watchedDuration
    }

    function updateView() {
        if (currentVidId > -1) {
            usc.updateUserView(currentViewId, vic.position, likeButton.checked ? 1 : 0)
        }
    }


    /* ---------------- PLAYBACK CONTROLS ---------------- */

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
        if (mouseY < bottomPanel.y - 10) {
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
