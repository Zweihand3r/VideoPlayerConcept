import QtQuick 2.13
import QtQuick.Layouts 1.13
import Qt.labs.settings 1.1
import QtGraphicalEffects 1.13

import '../Components/Basic'
import '../Components/Controls'

View {
    id: rootSet


    Item {
        id: content; width: 360; anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top; bottom: parent.bottom; margins: 20
        }

        Rectangle { id: bg; anchors.fill: parent; color: color_content_bg; radius: 4 }
        DropShadow { id: bg_shadow; anchors.fill: bg; color: cons.color.lightGray_3; source: bg; radius: 6 }

        Item {
            id: header; width: parent.width; height: 54

            Text {
                text: "Settings"; color: color_primary
                font { family: "Nickainley"; pixelSize: 29; weight: Font.Light } anchors {
                    centerIn: parent; verticalCenterOffset: -4
                }
            }

            Rectangle {
                id: headerDiv
                width: header.width; height: 2; color:color_divider; anchors {
                    horizontalCenter: parent.horizontalCenter; bottom: parent.bottom
                }
            }

            ColumnLayout {
                id: contentLt; anchors {
                    leftMargin: 20; topMargin: 16; rightMargin: 20
                    left: parent.left; top: headerDiv.bottom; right: parent.right
                }

                /* ----------------- SWITCH CONTENT ----------------- */

                Switch {
                    Layout.fillWidth: true
                    text: "Dark Theme"; checked: darkTheme; onClicked: {
                        darkTheme = checked
                    }
                }

                Switch {
                    Layout.fillWidth: true
                    text: "Enable Console"; checked: enableConsole; onClicked: {
                        enableConsole = checked
                    }
                }
            }
        }
    }


    function updateTheme(darkTheme) {
        if (darkTheme) {
            bg_shadow.visible = false
        } else {
            bg_shadow.visible = true
        }
    }


    /* ------------------- USER SETTINGS ------------------- */

    property bool darkTheme: true
    property bool enableConsole: true

    property color accentColor: cons.color.red_1


    /* ------------- SETTINGS CHANGE HANDLERS -------------- */

    onDarkThemeChanged: mac.applyTheme(darkTheme)


    /* -------------------_-_-_-_-_-_-_-_------------------- */


    Settings {
        id: user_settings

        property alias darkTheme: rootSet.darkTheme
        property alias enableConsole: rootSet.enableConsole
    }
}
