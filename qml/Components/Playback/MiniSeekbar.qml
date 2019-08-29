import QtQuick 2.13
import QtQuick.Controls 2.5

Item {
    id: rootMSb
    implicitWidth: 320
    implicitHeight: 4

    MouseArea {
        id: hovery
        hoverEnabled: true; cursorShape: Qt.PointingHandCursor; anchors {
            fill: parent; topMargin: -3; bottomMargin: -3
        }

        Slider {
            id: seekSlider; padding: 0
            from: 0; to: video.duration; value: video.position

            onMoved: video.seek(value)

            background: Item {
                x: seekSlider.leftPadding; y: seekSlider.topPadding
                implicitWidth: hovery.width; implicitHeight: hovery.height
                width: seekSlider.availableWidth; height: implicitHeight

                Item {
                    width: parent.width; height: hovery.containsMouse ? 4 : 3; anchors {
                        bottom: parent.bottom; bottomMargin: 3
                    }

                    Behavior on height { NumberAnimation { duration: 120 }}
                    Rectangle { anchors.fill: parent; color: cons.color.lightGray_1; opacity: 0.44 }

                    Rectangle {
                        id: progress; width: seekSlider.visualPosition * parent.width
                        color: settings.accentColor; anchors {
                            top: parent.top; bottom: parent.bottom
                        }
                    }

                    Item {
                        width: 10; height: 10; anchors {
                            right: progress.right; rightMargin: -5; verticalCenter: parent.verticalCenter
                        }

                        Rectangle {
                            width: hovery.containsMouse ? parent.width : 0
                            height: hovery.containsMouse ? parent.height : 0
                            radius: width / 2; color: settings.accentColor; anchors {
                                centerIn: parent
                            }

                            Behavior on width { NumberAnimation { duration: 120 }}
                            Behavior on height { NumberAnimation { duration: 120 }}
                        }
                    }
                }
            }

            handle: Item {
                x: seekSlider.leftPadding + seekSlider.visualPosition * (seekSlider.availableWidth - width)
                y: seekSlider.topPadding + seekSlider.availableHeight / 2 - height / 2
                implicitWidth: 10; implicitHeight: 10
            }
        }
    }
}
