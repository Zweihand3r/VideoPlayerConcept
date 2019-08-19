import QtQuick 2.11

QtObject {

    /*
     * Example scripts. Only works with the provided QML exapmles
     * Remove the exapmples and write your custom scripts here
     */
    readonly property var scripts: {
        "DROP_LibPaths": "/b DBController; /f drop(LibPaths);",
        "DROP_Videos": "/b DBController; /f drop(Videos);",
        "DROP_ALL": "/b DBController; /f drop(LibPaths); /f drop(Videos);",

        "WIPE_Library": "/b LibC; /f wipeLibrary();",

        "LOG_LibPaths": "/b DBController; /f log(LibPaths);",
        "LOG_Videos": "/b DBController; /f log(Videos);",

        "TOGGLE_drawables": "/b MaC; /f setDrawablesVisibility()"
    }

    /* Example custom cammands here. Remove to add your own */
    readonly property var commands: []


    /* This function recieves when custom commands are triggered */
    function customCommandsTriggerReciever(command, args, options) {

    }

}
