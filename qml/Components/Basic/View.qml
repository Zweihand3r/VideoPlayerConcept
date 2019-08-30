import QtQuick 2.13

Item {
    id: rootView
    width: applicationWidth
    height: applicationHeight

    property bool resizable: true

    onVisibleChanged: {
        if (visible) {
            updateUI()

            if (resizable) {
                width = Qt.binding(function() { return parent.width })
                height = Qt.binding(function() { return parent.height })
            }

        } else {
            if (resizable) {
                width = parent.width
                height = parent.height
            }
        }
    }


    /* ------------------------------------- */

    /* Called when view becomes visible */
    function updateUI() {}

    /* Called when theme is changed */
    function updateTheme() {}

    /* Called when view is presented */
    function navigatedTo() {}

    /* Called when view is dismissed */
    function navigatedAway() {}

    /* Called when file(s)/folder is selected */
    function finaliseFileSelection(paths) {}
    function finaliseFolderSelection(path) {}

    /* Called when a video is loaded/unloaded */
    function videoLoaded(vid_id) {}
    function videoUnloaded(vid_id) {}

    /* Called when a video (views) is updated */
    function videoUpdated(vid_id, view_id) {}


    /* ---------------- NAV ---------------- */

    visible: false

    function present() { visible = true }
    function dismiss() { visible = false }


    /* ------------- FUNCTIONS ------------- */
}
