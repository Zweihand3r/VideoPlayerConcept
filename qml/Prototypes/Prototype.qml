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
        WebPlayer { id: webPlayer }
        ThumbnailGeneration { id: thumbnailGen }
    }

    TabBar {
        id: navbar; width: applicationWidth; anchors {
            bottom: parent.bottom
        }

        Repeater {
            model: ["Video Player", "Web Player", "Thumbnail Generation"]
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

    function mstoTimeStr(s) {
        // Pad to 2 or 3 digits, default is 2
        function pad(n, z) {
            z = z || 2;
            return ('00' + n).slice(-z);
        }

        var ms = s % 1000;
        s = (s - ms) / 1000;
        var secs = s % 60;
        s = (s - secs) / 60;
        var mins = s % 60;
        var hrs = (s - mins) / 60;

        return pad(hrs) + ':' + pad(mins) + ':' + pad(secs)
    }
}
