import QtQuick 2.13
import QtMultimedia 5.13
import QtQuick.Layouts 1.13
import QtQuick.Controls 2.5

Item {
    id: rootWp
    width: applicationWidth
    height: applicationHeight

    readonly property string default_URL: 'https://r3---sn-bu2a-5hql.googlevideo.com/videoplayback?expire=1566911014&ei=xdVkXcP2N5-QmLAP1sSD2Ao&ip=103.251.56.5&id=o-AEXxd49O8E3ZfzhFG3VNkDMX3Vw8W_jlXdo2vUFOohMY&itag=18&source=youtube&requiressl=yes&mm=31%2C29&mn=sn-bu2a-5hql%2Csn-cvh7knek&ms=au%2Crdu&mv=m&mvi=2&pl=24&gcr=in&initcwndbps=673750&mime=video%2Fmp4&gir=yes&clen=23001767&ratebypass=yes&dur=398.431&lmt=1544973796952846&mt=1566889303&fvip=3&c=WEB&txp=5531432&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Cgcr%2Cmime%2Cgir%2Cclen%2Cratebypass%2Cdur%2Clmt&lsparams=mm%2Cmn%2Cms%2Cmv%2Cmvi%2Cpl%2Cinitcwndbps&lsig=AHylml4wRQIhAK8P_xlWcT-hyWXciB7V0vINcvAFhJ-cU_fU5QLN4R6MAiA9Uh6I0MWpAvLvT4J2TU5tiBpCD7rBSMLZYLiDq4m4Ww%3D%3D&sig=ALgxI2wwRgIhAL6Okf4Z0YFbbseOCdhUbsrkyU-PgDrKyfNfWBgPdiF2AiEAx9IHsiDZGzNiU_H63ofLdMgQDdE9P238XEHyd5d1Phg%3D&video_id=Xb3fZmkzy84&title=The+Rolling+Stones+-+Wild+Horses+%28Live%29'
    readonly property string lengthy_URL: 'https://r4---sn-ntnuxhoxu-ucne.googlevideo.com/videoplayback?expire=1566911331&ei=A9dkXbmfMJSXhAf-6ZbYCw&ip=95.137.240.3&id=o-AA5460kqiawblEWb0jZ0gyUX7mdXHQIixG6jO5ifH1KK&itag=18&source=youtube&requiressl=yes&mm=31%2C29&mn=sn-ntnuxhoxu-ucne%2Csn-gvnuxaxjvh-n8vk&ms=au%2Crdu&mv=m&mvi=3&pl=24&initcwndbps=752500&mime=video%2Fmp4&gir=yes&clen=130107525&ratebypass=yes&dur=1500.078&lmt=1538102936429560&mt=1566889548&fvip=4&beids=9466588&c=WEB&txp=5531332&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Cmime%2Cgir%2Cclen%2Cratebypass%2Cdur%2Clmt&lsparams=mm%2Cmn%2Cms%2Cmv%2Cmvi%2Cpl%2Cinitcwndbps&lsig=AHylml4wRQIgV_j43lx7Gn529neS6gpNn1ZMXzjwOhF_o7z0WbvuG8sCIQC5gwZpgrFpY9aqBnZ7_S6PwyY4EwHM1eWxlH9LkaTkcQ%3D%3D&sig=ALgxI2wwRQIhAJwJe_7lg6ihIlDtNe8dStZP-JmDsAUu8bfQ1cmAZ_MyAiAZO8liBzHzZIKeeFYMherc9lkfl7AzmC2Ofon9B78aKQ%3D%3D&video_id=gOXTdFbjtSg&title=Pink+Floyd+-+Shine+On+You+Crazy+Diamond+I-IX'

    ColumnLayout {
        anchors {
            left: playbackContainer.right; top: parent.top; right: parent.right; margins: 20
        }

        Repeater {
            model: ["Load Default URL", "Load Lenghty URL"]

            Button {
                text: modelData
                Layout.fillWidth: true
                onClicked: {
                    switch (index) {
                    case 0: playback.source = default_URL; break
                    case 1: playback.source = lengthy_URL; break
                    }
                }
            }
        }
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

            onStatusChanged: {
                if (status === MediaPlayer.Loaded) {
                    console.log("WebPlayer.qml: " + JSON.stringify(metaData))
                }
            }
        }

        Rectangle {
            width: statusText.width; height: statusText.height; anchors {
                left: parent.left; top: parent.top; margins: 8
            }

            color: Qt.rgba(1, 1, 1, 0.75)

            Text {
                id: statusText
                text: {
                    switch (playback.status) {
                    case MediaPlayer.NoMedia: return "Status: NoMedia"
                    case MediaPlayer.Loading: return "Status: Loading"
                    case MediaPlayer.Loaded: return "Status: Loaded"
                    case MediaPlayer.Buffering: return "Status: Buffering"
                    case MediaPlayer.Stalled: return "Status: Stalled"
                    case MediaPlayer.Buffered: return "Status: Buffered"
                    case MediaPlayer.EndOfMedia: return "Status: EndOfMedia"
                    case MediaPlayer.InvalidMedia: return "Status: InvalidMedia"
                    case MediaPlayer.UnknownStatus: return "Status: UnknownStatus"
                    }
                }
            }
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
                            case MediaPlayer.StoppedState: return 'qrc:/assets/icons/x32/play.png'
                            case MediaPlayer.PlayingState: return 'qrc:/assets/icons/x32/pause.png'
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
                }
            }
        }
    }
}
