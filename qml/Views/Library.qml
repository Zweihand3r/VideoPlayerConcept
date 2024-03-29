import QtQuick 2.13
import QtGraphicalEffects 1.13

import '../Components/Basic'
import '../Components/Library'
import '../Components/Controls'

View {
    id: rootLib

    Item {
        id: pathContent; width: parent.width / 2; anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top; bottom: parent.bottom; margins: 20
        }

        Rectangle { id: bg; anchors.fill: parent; color: color_content_bg; radius: 4 }
        DropShadow { id: bg_shadow; anchors.fill: bg; color: cons.color.lightGray_3; source: bg; radius: 6 }

        Item {
            id: header; width: parent.width; height: 54

            Text {
                text: "Video Directories / Videos"; color: color_primary
                font { family: "Nickainley"; pixelSize: 29; weight: Font.Light } anchors {
                    centerIn: parent; verticalCenterOffset: -4
                }
            }

            Rectangle {
                width: header.width; height: 2; color:color_divider; anchors {
                    horizontalCenter: parent.horizontalCenter; bottom: parent.bottom
                }
            }
        }

        Item {
            id: pathsContent; clip: true; anchors {
                top: header.bottom; right: parent.right; bottom: parent.bottom; left: parent.left
            }

            ListView {
                id: pathsLv; anchors {
                    fill: parent; topMargin: 6
                }

                delegate: PathsDelegate {}
                model: ListModel { id: pathsModel }
            }
        }

        Item {
            id: pathFooterPanel; height: 44; anchors {
                left: parent.left; bottom: parent.bottom; right: parent.right; margins: 8
            }

            ImageButton {
                id: addVidButton; imageWidth: 32; imageHeight: 32
                source: 'qrc:/assets/icons/x48/video_call.png'; tint: color_primary; anchors {
                    right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: 8
                }

                onClicked: fic.selectVidFiles()
            }

            ImageButton {
                id: addFolderButton; imageWidth: 27; imageHeight: 27
                source: 'qrc:/assets/icons/x48/create_new_folder.png'; tint: color_primary; anchors {
                    right: addVidButton.left; verticalCenter: parent.verticalCenter
                }

                onClicked: fic.selectFolder()
            }
        }
    }

    function addPath(path, dirFlag) {
        pathsModel.append({ "_path": path, "_dirFlag": dirFlag })
    }

    function clearLibPaths() {
        pathsModel.clear()
    }


    /* --------------------------------------------- */

    function updateTheme(darkTheme) {
        if (darkTheme) {
            bg_shadow.visible = false
        } else {
            bg_shadow.visible = true
        }
    }

    function finaliseFileSelection(paths) {
        libc.addNewVidPaths(paths)
    }

    function finaliseFolderSelection(path) {
        libc.addNewDirPath(path)
    }
}
