import QtQuick 2.13
import QtMultimedia 5.13

/* Also gets video duration. Need to rename this */

Item {
    id: rootTGen; anchors {
        fill: parent
    }

    property int currentGenId: 0

    readonly property int prepInterval: 10
    readonly property int processInterval: 50
    readonly property int completionInterval: 50

    function generate(id, source) { prepGeneration(id, source) }

    signal started()
    signal completed()
    signal errorEncountered(string errorStr)

    signal durationSet(string id, int duration)

    Item {
        id: genFrame
        width: 392; height: 200; anchors {
            centerIn: parent
        }

        Video {
            id: vidLoader; anchors {
                fill: parent
            }

            muted: true; fillMode: VideoOutput.PreserveAspectCrop

            Keys.onSpacePressed: togglePlayback()
            Keys.onLeftPressed: vidLoader.seek(vidLoader.position - 5000)
            Keys.onRightPressed: vidLoader.seek(vidLoader.position + 5000)

            onBufferProgressChanged: {
                if (bufferProgress === 1) processPrepTimer.start()
            }

            onErrorChanged: {
                var errorStr = ""

                switch (error) {
                case MediaPlayer.NoError: errorStr = "No Error"; break
                case MediaPlayer.ResourceError: errorStr = "Error allocating resourses"; break
                case MediaPlayer.FormatError: errorStr = "Invalid file format"; break
                case MediaPlayer.NetworkError: errorStr = "Network error"; break
                case MediaPlayer.AccessDenied: errorStr = "Insufficient permissions"; break
                case MediaPlayer.ServiceMissing: errorStr = "Video cannot be instantiated"; break
                }

                if (error > 0) {
                    rootTGen.errorEncountered(errorStr)
                }
            }
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
    }

    function startGeneration() {
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
