import QtQuick 2.13
import QtMultimedia 5.13

/* Also gets video duration. Need to rename this */

Item {
    id: rootTGen; anchors {
        fill: parent
    }

    property int currentGenId: 0

    readonly property int prepInterval: 125
    readonly property int processInterval: 250
    readonly property int completionInterval: 125

    function generate(id, source) { prepGeneration(id, source) }

    signal started()
    signal completed()

    signal durationSet(string id, int duration)

    Item {
        id: genFrame
        width: 392; height: 200; anchors {
            centerIn: parent
        }

        Video {
            id: vidLoader; muted: true; anchors {
                fill: parent
            }

            Keys.onSpacePressed: togglePlayback()
            Keys.onLeftPressed: vidLoader.seek(vidLoader.position - 5000)
            Keys.onRightPressed: vidLoader.seek(vidLoader.position + 5000)
        }

        MouseArea {
            anchors.fill: parent; onClicked: {
                vidLoader.forceActiveFocus()
                togglePlayback()
            }
        }
    }

    Timer {
        id: processPrepTimer
        interval: prepInterval; onTriggered: {
            startGeneration()
        }
    }

    Timer {
        id: thumbnailProcessTimer
        interval: processInterval; onTriggered: {
            processTrigger()
        }
    }

    Timer {
        id: processCompletionTimer
        interval: completionInterval; onTriggered: {
            completionTrigger()
        }
    }

    function prepGeneration(id, source) {
        rootTGen.started()

        currentGenId = id
        vidLoader.source = source

        processPrepTimer.start()
    }

    function startGeneration(id, source) {
        const duration = vidLoader.duration
        rootTGen.durationSet(currentGenId, duration)

        vidLoader.play()
        vidLoader.seek(Math.floor(duration / 5))
        vidLoader.pause()

        thumbnailProcessTimer.start()
    }

    function processTrigger() {
        genFrame.grabToImage(function(result) {
            const path = getItemThumbPath(currentGenId).substring(1)
            result.saveToFile(path)
        })

        processCompletionTimer.start()
    }

    function completionTrigger() {
        vidLoader.source = ""
        rootTGen.completed()
    }

    function togglePlayback() {
        if (vidLoader.playbackState === MediaPlayer.PlayingState) vidLoader.pause()
        else vidLoader.play()
    }
}
