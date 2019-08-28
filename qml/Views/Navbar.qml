import QtQuick 2.13

import '../Components/Basic'
import '../Components/Shared'

View {
    id: rootNb
    visible: true
    resizable: false; anchors {
        fill: parent
    }

    property bool expanded: false

    property int currentIndex: 0

    property color color_nonHighlight: cons.color.lightGray_3

    Rectangle {
        anchors.fill: parent; color: cons.color.darkGray_1

        opacity: expanded ? 0.64 : 0
        Behavior on opacity { OpacityAnimator { duration: 180 }}

        MouseArea {
            anchors.fill: parent
            visible: expanded; hoverEnabled: true; onClicked: {
                dismiss()
            }
        }
    }

    Item {
        id: content
        x: expanded ? 0 : -width
        width: 294; height: parent.height

        Rectangle { anchors.fill: parent; color: color_content_bg }
        Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutQuad }}

        Item {
            id: header; height: 64; anchors {
                left: parent.left; right: parent.right
            }

            MenuButton {
                id: menuButton; tapColor: color_primary; tint: color_primary; anchors {
                    left: parent.left; leftMargin: 4; verticalCenter: parent.verticalCenter
                }

                onClicked: dismiss()
            }

            Logo {
                id: logo; color: color_primary; accent: color_accent; anchors {
                    left: menuButton.right; leftMargin: 4; verticalCenter: parent.verticalCenter
                }
            }
        }

        Rectangle {
            id: div_1; height: 1; color: color_highlight; anchors {
                left: parent.left; top: header.bottom; right: parent.right
            }
        }

        ListView {
            id: contentLV; spacing: 4; interactive: false; anchors {
                topMargin: 12; left: parent.left; top: div_1.bottom; right: parent.right; bottom: parent.bottom
            }

            model: navModel; delegate: MouseArea {
                id: navDelegate
                width: contentLV.width; height: 44; hoverEnabled: true

                property bool hasHighlight: index === currentIndex

                onHasHighlightChanged: {
                    if (!hasHighlight) cellLoseHighlightAnim.start()
                }

                onExited: {
                    if (index !== currentIndex) cellLoseHighlightAnim.start()
                }

                onEntered: {
                    if (index !== currentIndex) {
                        if (cellLoseHighlightAnim.running) cellLoseHighlightAnim.stop()
                        highlight.opacity = 1
                    }
                }

                onClicked: {
                    currentIndex = index
                    nav.setCurrentId(_navId)
                    dismiss()
                }

                Component.onCompleted: {
                    if (index === currentIndex) {
                        highlight.opacity = 1
                    }
                }

                Rectangle {
                    id: highlight; anchors.fill: parent; opacity: 0; color: color_highlight

                    OpacityAnimator {
                        id: cellLoseHighlightAnim; target: highlight
                        from: 1; to: 0; duration: 180; easing.type: Easing.InCurve
                    }
                }

                Item {
                    id: navIcon; width: 32; height: 32; anchors {
                        left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 10
                    }

                    Image {
                        width: _dimension; height: _dimension; source: _source; anchors {
                            verticalCenter: parent.verticalCenter; horizontalCenter: parent.horizontalCenter
                        }

                        tint: navDelegate.hasHighlight ? color_accent : color_nonHighlight
                    }
                }

                Text {
                    id: navText; anchors {
                        leftMargin: 16; rightMargin: 44; left: navIcon.right; right: parent.right; verticalCenter: parent.verticalCenter
                    }

                    text: _text; horizontalAlignment: Text.AlignHCenter; color: color_primary; font {
                        pixelSize: 21; family: "Open Sans"; weight: navDelegate.hasHighlight ? Font.Normal : Font.Light
                    }
                }
            }
        }
    }

    ListModel {
        id: navModel

        ListElement { _text: "Home"; _source: 'qrc:/assets/icons/x48/home.png'; _navId: "home"; _dimension: 32 }
        ListElement { _text: "History"; _source: 'qrc:/assets/icons/x48/history.png'; _navId: "history"; _dimension: 32 }
        ListElement { _text: "Favorites"; _source: 'qrc:/assets/icons/x48/favorite_border.png'; _navId: "favorites"; _dimension: 32 }
        ListElement { _text: "Library"; _source: 'qrc:/assets/icons/x48/folder.png'; _navId: "library"; _dimension: 26 }
        ListElement { _text: "Settings"; _source: 'qrc:/assets/icons/x48/settings.png'; _navId: "settings"; _dimension: 30 }
    }

    function present() { expanded = true }
    function dismiss() { expanded = false }

    function updateTheme(darkTheme) {
        if (darkTheme) {
            color_nonHighlight = cons.color.lightGray_3
        } else {
            color_nonHighlight = cons.color.darkGray_4
        }
    }
}
