import QtQuick 2.13
import QtQuick.Controls 2.5

MouseArea {
    id: rootSb
    implicitWidth: 480
    implicitHeight: 20
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    Slider {
        id: seekSlider; padding: 0
        from: 0; to: vic.duration; value: vic.position

        onMoved: vic.seek(value)

        background: Item {
            x: seekSlider.leftPadding; y: seekSlider.topPadding
            implicitWidth: rootSb.width; implicitHeight: rootSb.height
            width: seekSlider.availableWidth; height: implicitHeight

            Item {
                width: parent.width; height: containsMouse ? 8 : 4; anchors {
                    verticalCenter: parent.verticalCenter
                }

                Behavior on height { NumberAnimation { duration: 120 }}
                Rectangle { anchors.fill: parent; radius: height / 2; color: cons.color.lightGray_1; opacity: 0.44 }

                Rectangle {
                    id: progress; width: seekSlider.visualPosition * parent.width
                    color: settings.accentColor; radius: height / 2; anchors {
                        top: parent.top; bottom: parent.bottom
                    }
                }

                /*Rectangle {
                    x: mouseX
                    width: 1; height: parent.height; color: cons.color.lightGray_1
                }*/

                Item {
                    width: 18; height: 18; anchors {
                        right: progress.right; rightMargin: -9; verticalCenter: parent.verticalCenter
                    }

                    Rectangle {
                        width: containsMouse ? parent.width : 0
                        height: containsMouse ? parent.height : 0
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
            implicitWidth: 18; implicitHeight: 18

            /*Rectangle {
                width: containsMouse ? parent.width : 0
                height: containsMouse ? parent.height : 0
                radius: width / 2; color: color_accent; anchors {
                    centerIn: parent
                }

                Behavior on width { NumberAnimation { duration: 120 }}
                Behavior on height { NumberAnimation { duration: 120 }}
            }*/
        }
    }
}
