import QtQuick 2.13
import Qt.labs.settings 1.1

Item {
    id: rootUsc; anchors {
        fill: parent
    }

    objectName: "UsC"

    property int currentUserId: 1

    Settings {
        property alias currentUserId: rootUsc.currentUserId
    }

    function init() {
        fetchUser(currentUserId)
    }

    function getUserView(vid_id) {
        var view = dbc.getView(currentUserId, vid_id)
        if (mac.checkIfEmpty(view)) {
            const id = dbc.createView(currentUserId, vid_id)
            view = { "id": id, "uid": currentUserId, "vid": vid_id, "duration": 0, "liked": 0, "lastWatched": new Date() }
        }
        return view
    }

    function updateUserView(id, duration, liked) {
        dbc.updateView(id, duration, liked)
    }

    function fetchUser(id) {
        const user = dbc.getUser(id)

        console.log("UserController.qml: Initialised User: " + JSON.stringify(user))
    }


    /* --------------------- DEBUG -------------------- */

    function wipeUsers() {
        dbc.drop("Users")
        dbc.drop("Views")
        currentUserId = 1
    }
}
