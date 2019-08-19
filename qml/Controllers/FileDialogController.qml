import QtQuick 2.13
import QtQuick.Dialogs 1.2

import '../Components/Basic'

Item {
    id: rootFic; anchors {
        fill: parent
    }

    FileDialog {
        id: fileDialog
        folder: shortcuts.home

        onAccepted: {
            /* Ok */

            if (selectFolder) nav.currentItem.finaliseFolderSelection(fileUrl)
            else nav.currentItem.finaliseFileSelection(fileUrls)
        }
    }

    function setNameFilters(nameFilters) {
        fileDialog.nameFilters = nameFilters
    }

    function selectFolder() {
        fileDialog.title = "Select Folder"
        fileDialog.selectFolder = true
        fileDialog.selectMultiple = false

        fileDialog.open()
    }

    function selectFiles(data) {
        /*data = {
            "nameFilters": ["Video files (*.mp4 *.avi)", "All files (*)"]
        }*/

        if (data !== undefined) {
            if (data.nameFilters !== undefined) setNameFilters(data.nameFilters)
        }

        fileDialog.title = "Select File(s)"
        fileDialog.selectFolder = false
        fileDialog.selectMultiple = true

        fileDialog.open()
    }

    function selectVidFiles() {
        selectFiles({ "nameFilters": ["MP4 (*.mp4)", "AVI (*.avi)"] })
    }
}
