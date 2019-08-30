import QtQuick 2.13
import QtQuick.Controls 2.5

import '../Basic'

MouseArea {
    id: rootVb
    implicitWidth: imageContainer.width + sliderContainer.width
    implicitHeight: 44
    hoverEnabled: true

    property real muted_volume: 1

    property bool muted: false

    MouseArea {
        id: imageContainer
        width: 44; height: parent.height
        onClicked: toggleMute()

        Image {
            width: 36; height: 36; anchors {
                centerIn: parent
                horizontalCenterOffset: {
                    if (muted) return 3
                    else {
                        if (vic.volume === 0) return -3
                        else if (vic.volume < 0.5) return 0
                        else return 3
                    }
                }
            }

            tint: cons.color.lightGray_1; source: {
                if (muted) return 'qrc:/assets/icons/x48/volume_mute.png'
                else {
                    if (vic.volume === 0) return 'qrc:/assets/icons/x48/volume_0.png'
                    else if (vic.volume < 0.5) return 'qrc:/assets/icons/x48/volume_1.png'
                    else return 'qrc:/assets/icons/x48/volume_2.png'
                }
            }
        }
    }

    Item {
        id: sliderContainer
        width: containsMouse ? 128 : 0
        height: parent.height; clip: true; anchors {
            left: imageContainer.right
        }

        Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutQuad }}

        Slider {
            id: volumeSlider; value: vic.volume; anchors {
                verticalCenter: parent.verticalCenter
            }

            onMoved: setVolume(value)

            background: Rectangle {
                x: volumeSlider.leftPadding
                y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                width: volumeSlider.availableWidth; height: implicitHeight; radius: width / 2
                implicitWidth: 128; implicitHeight: 6; color: cons.color.darkGray_2

                Rectangle {
                    width: volumeSlider.visualPosition * parent.width
                    height: parent.height; color: cons.color.lightGray_1; radius: parent.radius
                }
            }

            handle: Rectangle {
                x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
                y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                implicitWidth: 18; implicitHeight: 18; radius: width / 2; color: cons.color.lightGray_1
            }
        }
    }

    function setVolume(volume) {
        if (muted) muted = false
        vic.volume = volume
        settings.volume = volume
    }

    function toggleMute() {
        if (!muted) {
            muted_volume = volumeSlider.value

            vic.volume = 0
            muted = true
        } else {
            vic.volume = muted_volume
            muted = false
        }
    }
}

