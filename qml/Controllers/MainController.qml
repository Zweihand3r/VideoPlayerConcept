import QtQuick 2.13

Item {
    id: rootMac; anchors {
        fill: parent
    }

    objectName: "MaC"

    FontLoader { source: 'qrc:/assets/fonts/Nickainley-Normal.ttf' }
    FontLoader { source: 'qrc:/assets/fonts/OpenSans-Regular.ttf' }
    FontLoader { source: 'qrc:/assets/fonts/OpenSans-Light.ttf' }
    FontLoader { source: 'qrc:/assets/fonts/Mohave-Light.otf' }


    Component.onCompleted: {
        fm.createDirectory(libc.thumbDirPath)

        dbc.init()
        libc.init()
        usc.init()
    }


    function applyTheme(darkTheme) {
        if (darkTheme) {
            color_primary = cons.color.lightGray_1
            color_secondary = cons.color.lightGray_3
            color_accent = cons.color.lightGray_1
            color_background = cons.color.darkGray_1

            color_content_bg = cons.color.darkGray_2
            color_highlight = cons.color.darkGray_3
            color_divider = cons.color.darkGray_1
        } else {
            color_primary = cons.color.darkGray_2
            color_secondary = cons.color.darkGray_3
            color_accent = settings.accentColor
            color_background = cons.color.lightGray_1

            color_content_bg = cons.color.lightGray_1
            color_highlight = cons.color.lightGray_2
            color_divider = cons.color.lightGray_2_5
        }

        for (var id in nav.map) {
            nav.map[id].updateTheme(darkTheme)
        }
    }


    /* --------------------- HELPERS --------------------- */

    function executeAfter(delay, action) {
        const timer = Qt.createQmlObject('import QtQuick 2.13; Timer { running: true; interval: ' + delay + '; }', rootMac)
        timer.triggered.connect(function() { action(); timer.destroy() })
    }

    function setDrawablesVisibility(visible) {
        if (visible === undefined) visible = !drawables.visible
        drawables.visible = visible
    }

    function getDateElapsedSince(date) {
        const diff = Math.floor((Date.now() - (new Date(date)).getTime()) / 1000)

        if (diff < 60) {
            return Math.floor(diff) + " seconds ago"
        } else if (diff >= 60 && diff < 3600) {
            return Math.floor(diff / 60) + " minutes ago"
        } else if (diff >= 3600 && diff < 86400) {
            return Math.floor(diff / 3600) + " hours ago"
        } else if (diff >= 86400 && diff < 2592000) {
            return Math.floor(diff / 86400) + " days ago"
        } else if (diff >= 2592000 && diff < 31536000) {
            return Math.floor(diff / 2592000) + " months ago"
        } else {
            return Math.floor(diff / 31536000) + " years ago"
        }
    }

    function formatNumber(number) {
        if (number >= 1000 && number < 1000000) {
            return Math.floor(number / 1000) + "K"
        } else if (number >= 1000000) {
            return Math.floor(number / 1000000) + "M"
        } else {
            return number
        }
    }

    function msToTimeStr(ms) {
        const timesec = Math.floor(ms / 1000)
        const mins = Math.floor(timesec % 3600 / 60)
        const secs = Math.floor(timesec % 60)

        const secStr = (secs < 10 ? "0" : "") + secs

        if (ms < 3600000) {
            var minStr = mins.toString()
            return (minStr + ":" + secStr)
        } else {
            minStr = (mins < 10 ? "0" : "") + mins
            const hrs = Math.floor(timesec / 3600)
            return (hrs + ":" + minStr + ":" + secStr)
        }
    }

    function checkIfEmpty(map) {
        for (var key in map) return false
        return true
    }
}
