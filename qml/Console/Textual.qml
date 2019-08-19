import QtQuick 2.11
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.4

Item {
    id: rootTextual
    width: parent.width
    height: parent.height
    objectName: "textual"

    property bool contextMode: false
    property bool autocompMode: autocompletePopup.visible
    property bool inputHasFocus: { return inputTF.focus }

    property bool logUserCommands: false
    property bool expandOnTab: true
    property bool persistantContext: true
    property bool liveBindingRightAligned: false

    property int autocompSelectionIndex: 0
    property var autocompSelectionRange: [0, 5]

    property int historyIndex: 0

    property int currentHeightPercent: 25
    property int liveBindingFontSize: 13

    property string currentContext: ""
    property string defaultLiveBindingColor: "#FF0000"

    property var currentInputLine: { "context": "", "line": "" }

    property var commandList: []
    property var objectList: []
    property var autocompList: []
    property var historyList: []
    property var scriptsList: []
    property var liveUpdateBindings: []

    readonly property var contextRegex: new RegExp("\/([befgps]) ")
    readonly property var contextList: ["/b", "/e", "/f", "/g", "/p", "/s", "/echo", "/clear", "/list", "/history", "/expand", "/scroll", "/help"]

    readonly property var preferecesList: ["Dark_Theme", "Expand_On_Tab", "Log_User_Commands", "Persistant_Context", "Live_Font_Size", "Live_Align_Right", "Override_Live_Color", "Default_Live_Color", "Update_Object_List"]


    /* Value Change Handlers */
    onLiveBindingRightAlignedChanged: updateLiveBindingAlignment()


    Item {
        id: outputContainer
        width: parent.width
        anchors { top: parent.top; bottom: inputContainer.top }

        Rectangle { anchors.fill: parent; color: backgroundColor; opacity: 0.6 }

        ListView {
            id: outputLV
            anchors.fill: parent; clip: true
            verticalLayoutDirection: ListView.BottomToTop
            model: outputModel; delegate: Text {
                text: _text; color: _color; leftPadding: 2
                width: outputLV.width; wrapMode: Text.Wrap
            }
        }
    }

    Item {
        id: inputContainer
        y: inputLt.height
        width: parent.width
        height: inputLt.height

        Rectangle { anchors.fill: parent; color: backgroundColor; opacity: 0.6 }

        RowLayout {
            id: inputLt
            width: parent.width; spacing: 0
            anchors { bottom: parent.bottom }

            Text {
                Layout.maximumWidth: paintedWidth; leftPadding: 2
                text: currentObject.objectName; color: accentColor
            }

            Text {
                id: contextText
                text: "> "; color: accentColor
                Layout.maximumWidth: paintedWidth
            }

            Item {
                Layout.preferredHeight: 16
                Layout.preferredWidth: 16; Layout.fillWidth: true

                TextField {
                    id: inputTF
                    color: accentColor; background: Item {}
                    height: 16; verticalAlignment: Text.AlignBottom
                    padding: 0; leftPadding: 0; rightPadding: height + 4
                    anchors { left: parent.left; right: parent.right; bottom: parent.bottom }

                    onTextChanged: textChangeHandler(text)

                    Keys.onPressed: {
                        switch (event.key) {
                        case Qt.Key_Backspace: backspaceKeyHandler(text); break
                        }
                    }

                    Keys.onReturnPressed: returnKeyHandler(text)
                    Keys.onTabPressed: tabKeyHandler()

                    Keys.onLeftPressed: leftKeyHandler()
                    Keys.onUpPressed: upKeyHandler()
                    Keys.onDownPressed: downKeyHandler()
                    Keys.onRightPressed: rightKeyHandler()
                }
            }
        }

        Popup {
            id: autocompletePopup
            width: parent.width
            height: Math.min(autocompLV.contentHeight, 96) + 4
            visible: autocompList.length > 0
            closePolicy: Popup.NoAutoClose
            topPadding: 0; bottomPadding: 4; rightPadding: 2
            onHeightChanged: function() {
                if (visible) {
                    if (inputContainer.y + inputLt.height + height > rootTextual.height) {
                        y = -height
                    } else y = inputLt.height
                }
            }

            background: Rectangle { color: backgroundColor; opacity: 0.6 }

            contentItem: ListView {
                id: autocompLV
                clip: true; interactive: false; ScrollBar.vertical: ScrollBar {
                    onActiveChanged: active = true
                    active: autocompLV.contentHeight > autocompLV.height
                }

                model: autocompList
                delegate: Item {
                    height: 16; width: autocompLV.width - 12
                    Rectangle { anchors.fill: parent; color: backgroundColor; opacity: 0.5; visible: index === autocompSelectionIndex }

                    Text {
                        text: modelData; leftPadding: 4; rightPadding: 4;
                        color: index === autocompSelectionIndex ? accentColor : highlightColor
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: !touchUI
                        onEntered: autocompSelectionIndex = index
                        onClicked: selectCurrentSuggestion()
                    }
                }
            }
        }

        MouseArea {
            anchors.right: parent.right
            height: inputLt.height; width: height

            Item {
                anchors { fill: parent; leftMargin: 2; topMargin: 6; rightMargin: 4; bottomMargin: 6 }
                Rectangle { width: parent.width; height: 1; color: accentColor }
                Rectangle { width: parent.width; height: 1; color: accentColor; anchors.bottom: parent.bottom }
            }

            MouseArea {
                id: expandDraggie; width: 16; height: 16
                anchors { right: parent.right; bottom: parent.bottom }

                drag {
                    target: inputContainer
                    axis: Drag.YAxis
                    minimumY: inputLt.height
                    maximumY: rootTextual.height - inputLt.height
                }
            }
        }
    }

    Flickable {
        id: liveBindingFlick
        contentHeight: liveBindingLt.height; contentWidth: width; interactive: false; clip: true; anchors {
            left: parent.left; top: inputContainer.bottom; right: parent.right; bottom: parent.bottom
            leftMargin: contentHeight > height ? 12 : 2; rightMargin: 2
        }

        boundsBehavior: Flickable.StopAtBounds; ScrollBar.vertical: ScrollBar {
            id: liveBindingScrollbar
            contentItem: Rectangle { color: backgroundColor; opacity: 0.6; implicitWidth: 6; radius: 3 }
            onActiveChanged: active = true; parent: liveBindingFlick.parent; active: true; anchors {
                top: liveBindingFlick.top; right: liveBindingFlick.left; bottom: liveBindingFlick.bottom; rightMargin: 2
            }
        }

        ColumnLayout { id: liveBindingLt; width: liveBindingFlick.width; spacing: 0 }
    }

    MouseArea {
        id: popupDestroyer
        width: parent.width
        visible: autocompletePopup.visible
        onClicked: autocompletePopup.close()
    }

    ListModel {
        id: outputModel

        Component.onCompleted: {
            append({ "_text": "- Enter /help to show commands list", "_color": accentColor })
        }
    }

    function appendOutput(output, color) {
        if (color === undefined) color = accentColor
        outputModel.insert(0, { "_text": output, "_color": color })
    }

    function appendTextToInput(text) { inputTF.text += text }

    function updateCommandsList() {
        commandList = contextList.slice()
        if (customCommands.length > 0) {
            customCommands.forEach(function(cmd) { commandList.push(cmd) })
        }
    }

    function updateObjectList() { objectList = objectKeysToArray(objectMap) }
    function updateScriptsList() { scriptsList = objectKeysToArray(scripts) }

    function addLiveBinding(object, prop, name, color) {
        if (name === "") name = prop
        var liveText = Qt.createQmlObject(
                    'import QtQuick 2.11; Text { font.pixelSize: ' + liveBindingFontSize + '; color: "' + color + '" }', liveBindingLt, "live_binding")
        liveText.text = Qt.binding(function() { return "<b>" + name + "</b>: " + object[prop] })
        if (liveBindingRightAligned) liveText.Layout.alignment = Qt.AlignRight
        liveUpdateBindings.push(liveText)
    }

    function prepTouchUI() {
        autocompletePopup.closePolicy = touchUI ? Popup.NoAutoClose : Popup.CloseOnPressOutside
        if (touchUI) {
            expandDraggie.width = 32
            expandDraggie.height = 32
            inputTF.height = 32
            popupDestroyer.height = inputPanelY
            liveBindingScrollbar.contentItem.implicitWidth = 12
            liveBindingScrollbar.contentItem.radius = 4
        } else popupDestroyer.destroy()
    }

    function setMinimalistic() {
        if (minimalistic) {
            inputContainer.y = 0
            expandDraggie.drag.minimumY = 0
        }
    }


    /* ----------------------- */

    function textChangeHandler(text) {
        if (contextMode) {
            propObjAutocomplete(text)
        }
        else {
            contextAutocomplete(text)
            contextTrigger(text)
        }
    }

    function executeNonContextCommands(text) {
        if (text.startsWith("/")) {
            var command = ""
            var args
            var options = op.parseOptions(text)

            var spaceIndex = text.indexOf(" ")
            if (spaceIndex > -1) {
                command = text.substring(spaceIndex, -1)

                var optionIndex = text.indexOf(" -")
                if (optionIndex > -1) args = parseValue(text.substring(spaceIndex + 1, optionIndex))
                else args = parseValue(text.substring(spaceIndex + 1))
            }
            else command = text

            if (customCommands.indexOf(command) > -1) {
                triggerCustomCommands(command, args, options)
                return
            }

            switch (command) {
            case "/echo": echo(args, options); break
            case "/clear": clear(args); break
            case "/expand": expandOutputWindow(args, args); break
            case "/scroll": toggleUI_Interaction(args); break
            case "/help": displayHelp(args); break
            case "/list": listObjects(); break
            case "/history": showHistory(); break
            case "/root":
                if (args.toString() === "101") {
                    setRootAccess(true)
                    appendOutput("root access granted")
                } break

            default: appendOutput(command + ": command not found"); break
            }
        }
        else appendOutput("type \"/\" to get a list of commands")
    }

    function contextTrigger(text) {
        if (text.length === 3) {
            currentContext = ""

            if (contextRegex.test(text)) {
                switch (text.charAt(1)) {
                case "s": currentContext = "set"; break
                case "g": currentContext = "get"; break
                case "f": currentContext = "func"; break
                case "b": currentContext = "bind"; break
                case "e": currentContext = "exec"; break

                case "p":
                    currentContext = "prefs"
                    displayPreferenceOptions()
                    break
                }
            }

            if (currentContext.length > 0) {
                contextMode = true

                contextText.text = "> " + currentContext + ": "
                inputTF.text = ""
            }
        }
    }

    function removeContext(text) {
        if (text.length === 0) {
            turnOffContextMode()

            inputTF.text = "/ "
        }
    }

    function contextAutocomplete(text) {
        displayAutocomplete(text, commandList, false)
    }

    function propObjAutocomplete(text) {
        var searchList = []

        switch (currentContext) {
        case "set":
        case "get": searchList = propertyList; break
        case "exec": searchList = scriptsList; break
        case "func": searchList = functionList; break
        case "bind": searchList = objectList; break
        case "prefs": searchList = preferecesList; break
        }

        displayAutocomplete(text, searchList)
    }

    function displayAutocomplete(text, searchList, sortResults) {
        if (sortResults === undefined) sortResults = true

        var tempList = []
        var textIndex = -1

        if (text.length > 0) {
            searchList.forEach(function(prop) {
                textIndex = prop.toLowerCase().indexOf(text.toLowerCase())
                if (textIndex > -1) {
                    prop = prop.substring(0, textIndex) + "<b>" +
                            prop.substring(textIndex, textIndex + text.length) +
                            "</b>" + prop.substring(textIndex + text.length)
                    tempList.push(prop)
                }
            })
        }

        if (sortResults) autocompList = tempList.sort()
        else autocompList = tempList

        autocompSelectionIndex = 0
        autocompSelectionRange = [0, 5]
    }

    function selectCurrentSuggestion() {
        if (autocompList.length > 0) {
            var autocomp = autocompList[autocompSelectionIndex].replace("<b>", "").replace("</b>", "")

            if (contextMode) {
                switch (currentContext) {
                case "func":
                    inputTF.text = autocomp + "()"
                    inputTF.cursorPosition = inputTF.text.length - 1
                    break

                default: inputTF.text = autocomp + " "; break
                }
            }
            else { inputTF.text = autocomp + " " }

            autocompList = []
        }
    }

    function appendUserInput() {
        var userInput = "> " + (contextMode ? (currentContext + ": ") : "") + inputTF.text
        if (logUserCommands) appendOutput(userInput)

        historyList.push({ "context": currentContext, "line": inputTF.text })
        historyIndex = historyList.length
    }

    function setHistoryToInput(history) {
        if (history.context !== "") {
            contextMode = true
            currentContext = history.context
            contextText.text = "> " + currentContext + ": "
        } else turnOffContextMode()

        inputTF.text = history.line

        /* So that autocomplete is not triggered */
        autocompList = []
    }

    function setLineToInput(line) {
        turnOffContextMode()

        if (line.startsWith("/") === 0 && contextRegex.test(line)) {
            var spaceIndex = line.indexOf(" ")
            var context = line.substring(spaceIndex + 1, -1)
            var operation = line.substring(spaceIndex + 1)

            inputTF.text = context
            inputTF.text = operation
        }
        else inputTF.text = line
    }

    function turnOffContextMode() {
        contextMode = false
        currentContext = ""

        contextText.text = "> "
    }

    function clear(args) {
        if (args === undefined) outputModel.clear()
        else {
            switch (args) {
            case "live": clearLiveUpdates(); break
            }
        }
    }

    function showHistory() {
        var line = ""
        historyList.forEach(function(history, index) {
            switch (history.context) {
            case "bind": line = "/b "; break
            case "exec": line = "/e "; break
            case "func": line = "/f "; break
            case "get": line = "/g "; break
            case "prefs": line = "/p "; break
            case "set": line = "/s "; break
            default: line = ""; break
            }

            line += history.line
            appendOutput((index + 1) + "  " + line)
        })
    }

    function displayHelp(key) {
        if (key === undefined) {
            contextList.forEach(function(context) {
                if (helpMap[context.trim()] !== undefined)
                    appendOutput(helpMap[context.trim()].desc_short)
            })
            appendOutput("- Type /help <keyword> to get detailed info. Ex: /help /b")
            appendOutput("- Use the = icon on the right to drag the output window up or down")
        }
        else {
            for (var _key in helpMap) {
                var keywords = helpMap[_key].keywords
                for (var index = 0; index < keywords.length; index++) {
                    if (key.toLowerCase() === keywords[index]) {
                        appendOutput(helpMap[_key].desc_short)
                        helpMap[_key].desc_long.forEach(function(desc) {
                            appendOutput(desc)
                        })

                        return
                    }
                }
            }

            appendOutput(key + " not found!")
        }
    }

    function objectKeysToArray(object) {
        var array = []
        for (var key in object)
            array.push(key)
        return array
    }

    /* Preferences */

    function prefereceHandler(input) {
        var pref = ""
        var value
        var spaceIndex = input.indexOf(" ")

        if (spaceIndex > -1) {
            pref = input.substring(spaceIndex, -1)
            value = parseValue(input.substring(spaceIndex + 1))
        } else pref = input

        switch (pref) {
        case "Dark_Theme": setDarkTheme(value); break
        case "Expand_On_Tab": setToggleValue("expandOnTab", value, pref); break
        case "Persistant_Context": setToggleValue("persistantContext", value, pref); break
        case "Log_User_Commands": setToggleValue("logUserCommands", value, pref); break
        case "Live_Align_Right": setToggleValue("liveBindingRightAligned", value, pref); break
        case "Update_Object_List": op.updateObjectMap(); break
        case "Override_Live_Color": ovverrideLiveBindingsColor(value); break
        case "Default_Live_Color": setDefaultLiveBindingColor(value); break
        case "Live_Font_Size": setLiveBindingFontSize(value); break

            /* Former preferences */
        case "Expand_Output": expandOutputWindow(value, value); break
        case "Clear_Live_Updates": clearLiveUpdates(); break
        case "Output_Scrolling": toggleUI_Interaction(value); break
        case "root": if (value.toString() === "101") op.rootAccess = true; break
        default: appendOutput("pref: \"" + pref + "\" not found. Check list for valid preferences")
        }
    }

    function setDarkTheme(_darkTheme) {
        if (_darkTheme === undefined) _darkTheme = !darkTheme

        try {
            darkTheme = _darkTheme
            updateThemeColors()
        } catch (error) { appendOutput("pref: " + error) }
    }

    function expandOutputWindow(heightPercent, setHeightPercentage) {
        if (heightPercent === undefined) heightPercent = currentHeightPercent
        if (setHeightPercentage !== undefined) currentHeightPercent = heightPercent

        var height = 0
        if (minimalistic) height = heightPercent * (rootTextual.height - inputContainer.height) / 100
        else height = inputContainer.height + (heightPercent * (rootTextual.height - inputContainer.height * 2) / 100)

        inputContainer.y = height
    }

    function clearLiveUpdates() {
        for (var index = liveUpdateBindings.length - 1; index >= 0; index--)
            liveUpdateBindings[index].destroy()
        liveUpdateBindings = []
    }

    function toggleUI_Interaction(toggle) {
        if (toggle === undefined) toggle = !outputLV.interactive

        outputLV.interactive = toggle
        appendOutput("pref: " + (toggle ? "Enabled" : "Disabled") + " output scrolling to " + (toggle ? "disable" : "enable") + " UI Interaction" )
    }

    function setToggleValue(prop, value, toggleName) {
        if (value === undefined) rootTextual[prop] = !rootTextual[prop]
        else {
            try { rootTextual[prop] = value }
            catch(error) {
                appendOutput("pref: " + error)
                return false
            }
        }

        appendOutput("pref: " + toggleName + " set to " + rootTextual[prop])
        return true
    }

    function setLiveBindingFontSize(pixelSize) {
        if (pixelSize === undefined) {
            appendOutput("pref: Please specify a size (8 - 32)")
            return
        }

        if (pixelSize < 8 || pixelSize > 32) {
            pixelSize = Math.max(8, Math.min(pixelSize, 32))
            appendOutput("pref: Size clamped to " + pixelSize)
        }

        try {
            liveUpdateBindings.forEach(function(liveBinding) {
                liveBinding.font.pixelSize = pixelSize
            })

            appendOutput("pref: All live binding sizes changed to " + pixelSize)
        } catch (error) {
            appendOutput("prep: " + error)
            return
        }

        try { liveBindingFontSize = pixelSize }
        catch (setError) {}
    }

    function ovverrideLiveBindingsColor(color) {
        if (color === undefined) {
            appendOutput("pref: Please specify a color")
            return
        }

        try {
            liveUpdateBindings.forEach(function(liveBinding) {
                liveBinding.color = color
            })

            appendOutput("pref: All live binding colors overriden to " + color)
        } catch (error) { appendOutput("pref: " + error) }
    }

    function setDefaultLiveBindingColor(color) {
        if (color === undefined) {
            appendOutput("pref: Please specify a color")
            return
        }

        try {
            defaultLiveBindingColor = color
            appendOutput("pref: Default live binding color changed to " + color)
        } catch (error) { appendOutput("pref: " + error) }
    }

    function listObjects() {
        var sortedList = objectList.slice()
        sortedList.sort()

        sortedList.forEach(function(object, index) {
            appendOutput(object)
        })
    }

    function displayPreferenceOptions() {
        appendOutput("- <b>Preferences</b> -")
        appendOutput("- Dark_Theme <bool> \t\tSet to true if content has dark colors")
        appendOutput("- Expand_On_Tab <bool> \t\tSet to true to expand and collapse output window on Tab press")
        appendOutput("- Log_User_Commands <bool> \tSet to true to show user commands in the output window")
        appendOutput("- Persistant_Context <bool> \tSet to false to clear context on press of Return")
        appendOutput("- Live_Font_Size <int> \t\tSets the font size of the live bindings. Size range 8 - 32")
        appendOutput("- Live_Align_Right <bool> \tAlign the live bindings to the right")
        appendOutput("- Override_Live_Color <string> \tOverrides the color of all live bindings")
        appendOutput("- Default_Live_Color <string> \tSets the default color of the live bindings")
        appendOutput("- Update_Object_List \t\tUpdates the objects list to include dynamically created objects")
    }

    function updateLiveBindingAlignment() {
        const touchMargin = touchUI ? 18 : 12
        var alignment = Qt.AlignLeft

        if (liveBindingRightAligned) {
            alignment = Qt.AlignRight

            liveBindingFlick.anchors.leftMargin = 2
            liveBindingFlick.anchors.rightMargin = Qt.binding(function() {
                return liveBindingFlick.contentHeight > liveBindingFlick.height ? touchMargin : 2
            })

            liveBindingScrollbar.anchors.right = undefined
            liveBindingScrollbar.anchors.left = liveBindingFlick.right
            liveBindingScrollbar.anchors.leftMargin = 2
        } else {
            liveBindingFlick.anchors.rightMargin = 2
            liveBindingFlick.anchors.leftMargin = Qt.binding(function() {
                return liveBindingFlick.contentHeight > liveBindingFlick.height ? touchMargin : 2
            })

            liveBindingScrollbar.anchors.left = undefined
            liveBindingScrollbar.anchors.right = liveBindingFlick.left
            liveBindingScrollbar.anchors.rightMargin = 2
        }

        liveUpdateBindings.forEach(function(liveBinding) {
            liveBinding.Layout.alignment = alignment
        })
    }

    function updateOutputListTheme() {
        for (var index = 0; index < outputModel.count; index++) {
            outputModel.setProperty(index, "_color", accentColor)
        }
    }


    /* Key Handlers */

    function returnKeyHandler(text) {
        if (autocompMode) { selectCurrentSuggestion() }
        else {
            if (inputTF.text.length > 0) {
                appendUserInput()

                if (contextMode) {
                    switch (currentContext) {
                    case "bind": bind(text.trim()); break
                    case "exec": exec(text.trim()); break
                    case "func": func(text.trim()); break
                    case "get": get(text.trim()); break
                    case "set": set(text.trim()); break
                    case "prefs": prefereceHandler(text.trim()); break
                    }
                }
                else executeNonContextCommands(text.trim())

                inputTF.text = ""

                if (!persistantContext) {
                    if (currentContext !== "prefs") turnOffContextMode()
                }
            }
        }
    }

    function tabKeyHandler() {
        if (expandOnTab) {
            if (inputContainer.y > inputContainer.height)
                expandOutputWindow(0)
            else expandOutputWindow(currentHeightPercent)
        }
        else inputTF.text += "\t"
    }

    function backspaceKeyHandler(text) {
        if (contextMode) {
            removeContext(text)
        }
    }

    function leftKeyHandler() {
        inputTF.cursorPosition -= 1
    }

    function upKeyHandler() {
        if (autocompMode) {
            /* Autocomplete Scrolling */

            if (autocompSelectionIndex > 0)
                autocompSelectionIndex -= 1
            else autocompSelectionIndex = autocompList.length - 1
            keyScrolling(false)
        }
        else {
            /* History Scrolling */

            if (historyList.length > 0) {
                if (historyIndex === historyList.length)
                    currentInputLine = { "context": currentContext, "line": inputTF.text }

                if (historyIndex > 0) historyIndex -= 1
                setHistoryToInput(historyList[historyIndex])
            }
        }
    }

    function downKeyHandler() {
        if (autocompMode) {
            /* Autocomplete Scrolling */

            if (autocompSelectionIndex < autocompList.length - 1)
                autocompSelectionIndex += 1
            else autocompSelectionIndex = 0
            keyScrolling(true)
        }
        else {
            /* History Scrolling */

            if (historyList.length > 0) {
                if (historyIndex < historyList.length - 1) {
                    historyIndex += 1
                    setHistoryToInput(historyList[historyIndex])
                } else {
                    historyIndex = historyList.length
                    setHistoryToInput(currentInputLine)
                }
            }
        }
    }

    function rightKeyHandler() {
        inputTF.cursorPosition += 1
    }

    function keyScrolling(downPressed) {
        if (autocompList.length > 5) {
            if (downPressed) {
                if (autocompSelectionIndex > autocompSelectionRange[1]) {
                    autocompSelectionRange[0] += 1
                    autocompSelectionRange[1] += 1
                    autocompLV.contentY = 16 * (autocompSelectionIndex - 5)
                } else if (autocompSelectionIndex === 0) {
                    autocompSelectionRange = [0, 5]
                    autocompLV.contentY = 0
                }
            } else {
                if (autocompSelectionIndex < autocompSelectionRange[0]) {
                    autocompSelectionRange[0] -= 1
                    autocompSelectionRange[1] -= 1
                    autocompLV.contentY = 16 * autocompSelectionIndex
                } else if (autocompSelectionIndex === autocompList.length - 1) {
                    autocompSelectionRange = [autocompList.length - 6, autocompList.length - 1]
                    autocompLV.contentY = 16 * (autocompSelectionIndex - 5)
                }
            }
        }
    }


    /* ---------- Help Texts ----------- */

    readonly property var helpMap: {
        "/b": {
            "keywords": ["/b", "bind", "binding", "bind object"],
            "desc_short": "- /b \tBinds object for editing",
            "desc_long": [
                "- USAGE: /b <object_name>",
                "- Property \"objectName\" needs to be set for objects you want to edit in qml",
                "- Objects with no objectName are ignored and connot be bound",
                "- Objects should have unique objectName otherwise objects may not be found"
            ]
        },

        "/e": {
            "keywords": ["/e", "exec", "execute", "script", "scripts"],
            "desc_short": "- /e \tExecutes scripts specified in scripts variable",
            "desc_long": [
                "- USAGE: /e <script_name>",
                "- Scripts must be provided in the script property of Console",
                "- Available commands for script - /b, /f, /g, /s, /echo"
            ]
        },

        "/f": {
            "keywords": ["/f", "func", "functions", "call functions"],
            "desc_short": "- /f \tCalls function of bound object",
            "desc_long": [
                "- USAGE: /f <function_name>(<arg_1>, <arg_2>, ...)",
                "- Arguments should be provided in the same way as JavaScript function arguments"
            ]
        },

        "/g": {
            "keywords": ["/g", "get", "get value", "bind value", "live update", "live updates"],
            "desc_short": "- /g \tDisplays property value of bound object",
            "desc_long": [
                "- USAGE: /g <property_name> [-c <color>] -j -t -u [-b <bind_name>(optional)]",
                "- Option -b is used to bind the live value to a label. <bind_name> can be provided to change the label text. If bind name is not provided property name is used instead",
                "- Option -c is used to change color of live binding text. -b required for this to work",
                "- Option -j is used to display in JSON format. Usefull for JavaScript or JSON type objects",
                "- Option -t is used to display the type of property",
                "- \"-all\" can be used in place of <property_name> to display values of all the properties in the object",
                "- Option -u can be used with \"-all\" to filter user properties"
            ]
        },

        "/p": {
            "keywords": ["/p", "pref", "preferences"],
            "desc_short": "- /p \tPreference options for the console",
            "desc_long": [
                "- USAGE: /p <preferece_name> <vlaue>",
                "- A list of available preference options is displayed when typing /p"
            ]
        },

        "/s": {
            "keywords": ["/s", "set", "set value"],
            "desc_short": "- /s \tSets property value of bound object",
            "desc_long": [
                "- USAGE: /s <property_name> <value>"
            ]
        },

        "/echo": {
            "keywords": ["/echo", "print", "log"],
            "desc_short": "- /echo \tPrints text in output window",
            "desc_long": [
                "- USAGE: /echo <text> [-c <color>]",
                "- Option -c sets the color of the line"
            ]
        },

        "/clear": {
            "keywords": ["/clear", "clear", "clear live binding", "clear live bindings", "clear all"],
            "desc_short": "- /clear \tClears the output window",
            "desc_long": [
                "- USAGE: /clear <option>(optional)",
                "- Using without options clears the output window",
                "- Available options: live",
                "- option live clears all the live bindings"
            ]
        },

        "/list": {
            "keywords": ["/list", "list", "ls"],
            "desc_short": "- /list \tLists all available objects",
            "desc_long": [
                "- USAGE: /list"
            ]
        },

        "/history": {
            "keywords": ["/history"],
            "desc_short": "- /history \tLists all of the previous user commands",
            "desc_long": [
                "- USAGE: /history"
            ]
        },

        "/expand": {
            "keywords": ["/expand", "expand"],
            "desc_short": "- /expand \tExpands output window",
            "desc_long": [
                "- USAGE: /expand <int>(optional)",
                "- Adding optional <int> (0 - 100) will expand the window by that percentage"
            ]
        },

        "/scroll": {
            "keywords": ["/scroll", "disable scrolling", "enable scrolling"],
            "desc_short": "- /scroll \tEnables/Disables scrolling in output window",
            "desc_long": [
                "- USAGE: /scroll <bool>(optional)",
                "- This is mainly used to enable UI Interaction behinf the output window"
            ]
        }
    }
}
