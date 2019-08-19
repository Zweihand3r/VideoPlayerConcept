import QtQuick 2.13
import QtQuick.Window 2.13

import './qml'

Window {
    id: mainWindow
    visible: true
    width: mainContent.applicationWidth
    height: mainContent.applicationHeight
    title: qsTr("VideoPlayer")

    minimumWidth: mainContent.applicationWidth
    minimumHeight: mainContent.applicationHeight

    /*maximumWidth: mainContent.applicationWidth
    maximumHeight: mainContent.applicationHeight*/

    MainContent {
        id: mainContent
    }
}
