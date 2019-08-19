import QtQuick 2.13

import './Views'
import './Console'
import './Constants'
import './Prototypes'
import './Controllers'

Item {
    id: rootMC; anchors {
        fill: parent
    }

    property bool fullscreenActive: false

    property int applicationWidth: 1366
    property int applicationHeight: 768

    property color color_accent: cons.color.red_1
    property color color_primary: cons.color.lightGray_1
    property color color_highlight: cons.color.darkGray_2
    property color color_background: cons.color.darkGray_1
    property color color_content_bg: cons.color.darkGray_2
    property color color_divider: cons.color.darkGray_1


    /* ------------ CONTROLLERS ------------ */

    MainController { id: mac }
    FileDialogController { id: fic }
    DatabaseController { id: dbc }
    LibraryController { id: libc }


    /* ------------- DRAWABLES ------------- */

    Rectangle {
        id: drawables; color: color_background; anchors {
            fill: parent
        }

        Item {
            id: views; anchors {
                left: parent.left; top: nav.bottom; right: parent.right; bottom: parent.bottom
            }

            Playback { id: playback }
            Home { id: home }
            Library { id: library }
            Settings { id: settings }
        }

        Navigation { id: nav }
        Navbar { id: navbar }
    }


    /* ---------------- MISC --------------- */

    Constants { id: cons }


    /* --------------- DEBUG --------------- */

    Console { id: _console; visible: settings.enableConsole }


    /*Prototype { id: prototype }*/

    Component.onCompleted: {
        /* - MAIN INIT - */

        mac.applyTheme(settings.darkTheme)
    }
}
