import QtQuick 2.11
import QtQuick.Layouts 1.11
import Qt.labs.settings 1.0

Item {
    id: rootConsole
    width: parent.width
    height: parent.height
    objectName: "Console"

    /* Available commands for scripts: [/b, /f, /g, /s, /echo]. Custom commands also supported */
    property var scripts: customisable.scripts

    /* All custom commands must be registered here for them to trigger */
    property var customCommands: customisable.commands

    /* Set to true to enable touch UI support */
    property bool touchUI: false

    /* Set to true to show only the input box. (Output window can still be expanded) */
    property bool minimalistic: false

    /* Set to false if content has darker colors */
    property bool darkTheme: true

    /* Connect to inputPanel (Virtual Keyboard) property "y". For use with "touchUI" */
    property int inputPanelY: height

    /* This signal is triggered when entering custom commands */
    signal customCommandTriggered(string command, string args, var options)


    /* --------------------------------------------------------------- */

    property var rootObject: parent

    property var objectMap: ({})

    property var propertyList: []
    property var functionList: []

    property var currentObject: rootConsole

    property string currentLongPress: ""

    property string accentColor: "#F6F7F7"
    property string highlightColor: "#D6D7D7"
    property string backgroundColor: "#000000"

    function log(text, color) { textual.appendOutput(text, color) }

    function bind(object) { return op.bind(object) }
    function exec(script) { return op.exec(script) }
    function func(inputString) { return op.func(inputString) }
    function get(inputString) { return op.get(inputString) }
    function set(inputString) { return op.set(inputString) }
    function echo(str, options) { return op.echo(str, options) }

    function parseValue(value) { return op.parseValue(value) }
    function parseOptions(inputString) { return op.parseOptions(inputString) }

    function setRootAccess(rootAccess) { op.rootAccess = rootAccess }

    function addLiveBinding(object, prop, name, color) {
        liveBindingHandler(object, prop, name, color)
    }

    Textual {
        id: textual
        z: 10
    }

    Operations {
        id: op

        onObjectMapUpdated: textual.updateObjectList()
    }

    Customisable {
        id: customisable
    }

    Item {
        id: touchInputPanel
        y: inputPanelY - 32; width: parent.width; height: 32
        visible: Qt.inputMethod.visible && textual.inputHasFocus

        Rectangle { anchors.fill: parent; color: backgroundColor; opacity: 0.8 }

        RowLayout {
            anchors.fill: parent

            Repeater {
                model: ["/", "Tab", "-", "\u2190", "\u2191", "\u2193", "\u2192"]

                MouseArea {
                    Layout.preferredWidth: 32; Layout.preferredHeight: 32; Layout.fillWidth: true
                    Rectangle { anchors.fill: parent; color: backgroundColor; opacity: 0.5; visible: parent.pressed }

                    Text {
                        anchors.centerIn: parent
                        text: modelData; font.pixelSize: 17; color: accentColor
                    }

                    onPressed: function() {
                        switch (modelData) {
                        case "/":
                        case "-": textual.appendTextToInput(modelData); break
                        case "Tab": textual.tabKeyHandler(); break
                        case "\u2190": textual.leftKeyHandler(); break
                        case "\u2191": textual.upKeyHandler(); break
                        case "\u2193": textual.downKeyHandler(); break
                        case "\u2192": textual.rightKeyHandler(); break
                        }
                    }

                    onPressAndHold: function() {
                        switch (modelData) {
                        case "/": currentLongPress = "/"; break
                        case "-": currentLongPress = "-"; break
                        case "Tab": currentLongPress = "Tab"; break
                        case "\u2190": currentLongPress = "left"; break
                        case "\u2191": currentLongPress = "up"; break
                        case "\u2193": currentLongPress = "down"; break
                        case "\u2192": currentLongPress = "right"; break
                        }

                        longPressTimer.start()
                    }

                    onReleased: function() {
                        currentLongPress = ""
                        longPressTimer.stop()
                    }
                }
            }
        }
    }

    Timer {
        id: longPressTimer
        interval: 80; repeat: true
        onTriggered: longPressHandler()
    }

    Component.onCompleted: function() {
        initialize()

        updateThemeColors()

        textual.updateCommandsList()
        textual.updateScriptsList()
        textual.prepTouchUI()
        textual.setMinimalistic()

        if (!touchUI) touchInputPanel.destroy()
    }

    function initialize() {
        op.updateObjectMap()
        op.bind(currentObject.objectName)
    }

    function triggerCustomCommands(command, args, options) {
        customisable.customCommandsTriggerReciever(command, args, options)
        rootConsole.customCommandTriggered(command, args, options)
    }

    function longPressHandler() {
        switch (currentLongPress) {
        case "/":
        case "-": textual.appendTextToInput(currentLongPress); break
        case "left": textual.leftKeyHandler(); break
        case "up": textual.upKeyHandler(); break
        case "down": textual.downKeyHandler(); break
        case "right": textual.rightKeyHandler(); break
        }
    }

    function liveBindingHandler(object, prop, name, color) {
        if (arguments.length < 2) {
            log("live_binding: Insufficient arguments")
            return
        } else {
            if (color === undefined) color = textual.defaultLiveBindingColor
            else if (color === "") color = textual.defaultLiveBindingColor

            if (name === undefined) name = prop
            if (object[prop] === undefined) {
                log("live_binding: property \"" + prop + "\" does not exist in object \"" + object.objectName + "\"")
                return
            }
        }

        try { textual.addLiveBinding(object, prop, name, color) }
        catch (error) { log("live_binding: " + error) }
    }

    function updateThemeColors() {
        if (darkTheme) {
            accentColor = "#F6F7F7"
            highlightColor = "#D6D7D7"
            backgroundColor = "#000000"
        } else {
            accentColor = "#141313"
            highlightColor = "#242323"
            backgroundColor = "#FFFFFF"
        }

        textual.updateOutputListTheme()
    }

    Settings {
        id: settings

        property alias console_darkTheme: rootConsole.darkTheme
        property alias console_expandOnTab: textual.expandOnTab
        property alias console_logUserCommands: textual.logUserCommands
        property alias console_persistantContext: textual.persistantContext
        property alias console_defaultLiveBindingColor: textual.defaultLiveBindingColor
        property alias console_liveBindingFontSize: textual.liveBindingFontSize
        property alias console_liveBindingRightAligned: textual.liveBindingRightAligned
    }
}
