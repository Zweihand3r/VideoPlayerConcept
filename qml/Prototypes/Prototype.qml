import QtQuick 2.13
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.13
import QtQuick.Controls 2.5

Rectangle {
    id: rootProt
    width: applicationWidth
    height: applicationHeight

    property Item fileSelectionSender: Item {}

    StackLayout {
        currentIndex: navbar.currentIndex; anchors {
            fill: parent; bottomMargin: navbar.height
        }

        VideoPlayer { id: videoPlayer }
        ThumbnailGeneration { id: thumbnailGen }
    }

    TabBar {
        id: navbar; width: applicationWidth; anchors {
            bottom: parent.bottom
        }

        Repeater {
            model: ["Video Player", "Thumbnail Generation"]
            TabButton { text: modelData }
        }
    }

    FileDialog {
        id: fileDialog
        selectMultiple: true
        nameFilters: ["Video files (*.mp4)", "All files (*)"]
        onAccepted: fileSelectionSender.finaliseFileSelection()
    }

    function openFileSelection(sender) {
        fileSelectionSender = sender
        fileDialog.open()
    }
}
