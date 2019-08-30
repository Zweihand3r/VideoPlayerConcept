import QtQuick 2.13
import QtMultimedia 5.13

import '../Components/Playback'

Video {
    id: rootVic
    objectName: "Vic"; anchors {
        fill: parent
    }

    property PlaybackView currentPlaybackView: playback

    Keys.onSpacePressed: togglePlayPause()
    Keys.onLeftPressed: replay()
    Keys.onRightPressed: forward()

    function load(path, watchedDuration) {
        volume = settings.volume
        source = path
        seek(watchedDuration)
    }

    function reparent(parent, isMiniplayer) {
        rootVic.parent = parent

        if (isMiniplayer) {
            currentPlaybackView = miniPlayback
            fillMode = VideoOutput.PreserveAspectCrop
        } else {
            currentPlaybackView = playback
            fillMode = VideoOutput.PreserveAspectFit
        }

        forceActiveFocus()
    }

    function togglePlayPause() {
        if (playbackState === MediaPlayer.PlayingState) {
            pause()
            currentPlaybackView.paused()
        } else {
            play()
            currentPlaybackView.played()
        }
    }

    function replay() {
        seek(position - 5000)
        currentPlaybackView.replayed()
    }

    function forward() {
        seek(position + 5000)
        currentPlaybackView.forwarded()
    }

    function pauseIfPlaying() {
        if (playbackState === MediaPlayer.PlayingState) {
            pause()
        }
    }
}
