import QtQuick 2.11

QtObject {
    id: rootOperations
    objectName: "operations"

    property bool rootAccess: false

    readonly property var contextRegex: new RegExp("\/([befgs]|echo) ")
    readonly property var rootAccessObjects: ["Console", "textual", "operations"]
    readonly property var itemProperties: [
                "objectName", "parent", "data", "resources", "children", "x", "y", "z", "width", "height", "opacity", "enabled",
                "visible", "visibleChildren", "states", "transitions", "state", "childrenRect", "anchors", "left", "right", "horizontalCenter",
                "top", "bottom", "verticalCenter", "baseline", "baselineOffset", "clip", "focus", "activeFocus", "activeFocusOnTab", "rotation",
                "scale", "transformOrigin", "transformOriginPoint", "transform", "smooth", "antialiasing", "implicitWidth", "implicitHeight", "layer",
                "objectNameChanged", "childrenRectChanged", "baselineOffsetChanged", "stateChanged", "focusChanged", "activeFocusChanged",
                "activeFocusOnTabChanged", "parentChanged", "transformOriginChanged", "smoothChanged", "antialiasingChanged", "clipChanged",
                "windowChanged", "childrenChanged", "opacityChanged", "enabledChanged", "visibleChanged", "visibleChildrenChanged", "rotationChanged",
                "scaleChanged", "xChanged", "yChanged", "widthChanged", "heightChanged", "zChanged", "implicitWidthChanged", "implicitHeightChanged",
                "update", "grabToImage", "grabToImage", "contains", "mapFromItem", "mapToItem", "mapFromGlobal", "mapToGlobal",
                "forceActiveFocus", "nextItemInFocusChain", "childAt", "containmentMask"
            ]

    signal objectMapUpdated()

    signal objectBound()

    function bind(object) {
        if (objectMap[object] !== undefined) {
            currentObject = objectMap[object]

            var _propertyList = []
            var _functionList = []
            for (var prop in currentObject) {
                if (typeof(currentObject[prop]) === "function") _functionList.push(prop)
                else _propertyList.push(prop)
            }

            propertyList = _propertyList
            functionList = _functionList
            objectBound()
            return true
        }
        else {
            log("bind: object \"" + object + "\" not found")
            return false
        }
    }

    function func(inputString) {
        var openParanIndex = inputString.indexOf("(")
        if (openParanIndex > -1 && inputString.indexOf(")") === inputString.length - 1) {
            var func = inputString.substring(openParanIndex, -1)
            if (functionList.indexOf(func) > -1) {
                var argString = inputString.substring(openParanIndex + 1, inputString.length - 1)
                var argArray = argString.split(",")
                var args = []

                if (argArray.length > 0) {
                    argArray.forEach(function(arg) {
                        args.push(parseValue(arg.trim()))
                    })
                }

                if (!checkRootAccess()) {
                    log("func: permission denied!")
                    return
                }

                try {
                    var returned = currentObject[func].apply(this, args)
                    if (returned !== undefined) log("func: " + returned)
                    return true
                }
                catch (error) {
                    log("func: " + error)
                    return false
                }
            }
            else {
                log("func: function \"" + func + "\" not found")
                return false
            }
        }
        else {
            log("func: invalid input. usage-> func: function_name(argument_1, argument_2, ...)")
            return false
        }
    }

    function exec(inputString) {
        var script = inputString
        var options = parseOptions(script)
        var flags = { "force": false }

        var spaceIndex = inputString.indexOf(" ")
        if (spaceIndex > -1)
            script = inputString.substring(0, spaceIndex)

        for (var option in options) {
            switch (option) {
            case "f": flags.force = true; break
            default: log("exec: unknown option -" + option); return false
            }
        }

        if (scripts[script] !== undefined) {
            var lines = scripts[script].split(";")

            for (var index = 0; index < lines.length; index++) {
                var line = lines[index].trim()

                if (line.startsWith("/")) {
                    if (contextRegex.test(line)) {
                        spaceIndex = line.indexOf(" ")

                        var contextStr = line.substring(spaceIndex, -1)
                        var args = line.substring(spaceIndex + 1)
                        var status = true

                        switch (contextStr) {
                        case "/b": status = bind(args); break
                        case "/f": status = func(args); break
                        case "/g": status = get(args); break
                        case "/s": status = set(args); break
                        case "/echo": status = echo(args); break
                        }

                        if (!status) {
                            if (flags.force) log("exec: Could not execute line \"" + line + "\"")
                            else log("exec: Exiting script \"" + script + "\"")
                        }

                    } else {
                        spaceIndex = line.indexOf(" ")

                        if (spaceIndex > -1) {
                            contextStr = line.substring(spaceIndex, -1)
                            args = line.substring(spaceIndex + 1)
                        } else {
                            contextStr = line
                            args = ""
                        }

                        if (customCommands.indexOf(contextStr) > -1) {
                            triggerCustomCommands(contextStr, args)
                        } else {
                            log("exec: Invalid line \"" + line + "\". Exiting script \"" + script + "\"")
                            return false
                        }
                    }
                }
                else if (line.startsWith("#")) {/* Ignore Comments */}
                else if (line === "") {/* Ignoring empty lines */}
                else {
                    log("exec: Invalid line \"" + line + "\". Exiting script \"" + script + "\"")
                    return false
                }
            }

            return true
        }
        else {
            log("exec: script \"" + script + "\" not found")
            return false
        }
    }

    function get(inputString) {
        var prop = inputString
        var options = parseOptions(inputString)
        var flags = { "json": false, "type": false, "bind": false, "user": false }
        var args = { "title": "", "color": textual.defaultLiveBindingColor }

        var spaceIndex = inputString.indexOf(" ")
        if (spaceIndex > -1)
            prop = inputString.substring(0, spaceIndex)

        for (var option in options) {
            switch (option) {
            case "c": args.color = options[option]; break
            case "j": flags.json = true; break
            case "t": flags.type = true; break
            case "u": flags.user = true; break
            case "b":
                flags.bind = true
                args.title = options[option]
                break

            default: log("get: unknown option -" + option); return false
            }
        }

        if (prop === "-all") {
            propertyList.forEach(function(_prop) {
                if (flags.user) {
                    if (itemProperties.indexOf(_prop) < 0)
                        getValue(_prop, flags, args)
                } else getValue(_prop, flags, args)
            })

            return true
        }
        else {
            if (propertyList.indexOf(prop) > -1) return getValue(prop, flags, args)
            else {
                log("get: property \"" + prop + "\" not found")
                return false
            }
        }
    }

    function set(inputString) {
        var spaceIndex = inputString.indexOf(" ")
        if (spaceIndex > -1) {
            var prop = inputString.substring(spaceIndex, -1)
            if (propertyList.indexOf(prop) > -1) {
                if (!checkRootAccess()) {
                    log("set: permission denied!")
                    return
                }

                var value = parseValue(inputString.substring(spaceIndex + 1))
                return setValue(prop, value)
            }
            else {
                log("set: property \"" + prop + "\" not found")
                return false
            }
        }
        else {
            log("set: invalid input. usage-> set: property_name value")
            return false
        }
    }

    function echo(str, options) {
        var color = ""

        if (options === undefined) {
            var optionIndex = str.indexOf(" -")
            if (optionIndex > -1) {
                options = parseOptions(str)
                str = str.substring(0, optionIndex)
            } else options = {}
        }

        for (var option in options) {
            switch (option) {
            case "c":
                if (options[option].length > 0) color = options[option]
                else {
                    log("echo: -c expects a color")
                    return false
                } break

            default:
                log("echo: unknown option -" + option)
                return false
            }
        }

        if (color === "") log(str)
        else {
            try { log(str, color) }
            catch(error) { log("echo: " + error); return false }
        }

        return true
    }

    function parseValue(value) {
        var returnValue

        if (value.indexOf(".") > -1) {
            returnValue = parseFloat(value)
            if (returnValue.toString() !== "NaN") return returnValue
        }
        else {
            returnValue = parseInt(value)
            if (returnValue.toString() !== "NaN") return returnValue
        }

        if ((value.charAt(0) === "\"" && value.charAt(value.length - 1) === "\"") ||
                (value.charAt(0) === "\'" && value.charAt(value.length - 1) === "\'"))
            return value.substring(1, value.length - 1)
        else if (value === "true") return true
        else if (value === "false") return false
        else return value
    }

    function parseOptions(inputString) {
        var options = {}

        var optionIndex = inputString.indexOf(" -")
        if (optionIndex > -1) {
            var optionStr = inputString.substring(optionIndex + 2)
            var optionsArray = optionStr.split(" -")

            optionsArray.forEach(function(optionStrFrag) {
                var arg = ""

                var spaceIndex = optionStrFrag.indexOf(" ")
                if (spaceIndex > -1) {
                    arg = optionStrFrag.substring(spaceIndex + 1)
                    optionStrFrag = optionStrFrag.substring(spaceIndex, -1)
                }

                var optionArrayFrag = optionStrFrag.split("")
                for (var index = 0; index < optionArrayFrag.length; index++) {
                    var option = optionArrayFrag[index]
                    if (index === optionArrayFrag.length - 1)
                        options[option] = arg
                    else options[option] = ""
                }
            })
        }

        return options
    }

    function getValue(prop, flags, args) {
        try {
            if (flags.bind) {
                if (typeof(currentObject[prop]) === "object") {
                    log("get: live update binding only available for boolean, number and string types")
                    return false
                } else textual.addLiveBinding(currentObject, prop, parseValue(args.title), parseValue(args.color))
            } else if (flags.type) {
                log("typeof <b>" + prop + "</b>: " + typeof(currentObject[prop]))
                if (flags.json) log("<b>" + prop + "</b>: " + JSON.stringify(currentObject[prop]))
            } else {
                if (flags.json) log("<b>" + prop + "</b>: " + JSON.stringify(currentObject[prop]))
                else log("<b>" + prop + "</b>: " + currentObject[prop])
            }

            return true
        }
        catch(error) {
            log("get: " + error)
            return true
        }
    }

    function setValue(prop, value) {
        try {
            currentObject[prop] = value
            return true
        }
        catch (error) {
            log("set: " + error)
            return false
        }
    }

    function checkRootAccess(object) {
        if (rootAccess) return true
        else {
            if (rootAccessObjects.indexOf(currentObject.objectName) > -1) return false
            else return true
        }
    }

    function updateObjectMap() {
        var currArray = [rootObject]
        var nextArray = []
        var tempMap = {}

        while (currArray.length > 0) {
            for (var arrIndex = 0; arrIndex < currArray.length; arrIndex++) {
                var currNode = currArray[arrIndex]

                for (var childIndex = 0; childIndex < currNode.children.length; childIndex++) {
                    var childNode = currNode.children[childIndex]
                    nextArray.push(childNode)

                    if (childNode.objectName !== "") {
                        tempMap[childNode.objectName] = childNode
                    }
                }
            }

            currArray = nextArray.slice()
            nextArray = []
        }

        objectMap = tempMap
        objectMapUpdated()

        var count = 0
        for (var key in objectMap) count += 1
        console.log("Operations.qml: objectMap updated with " + count + " objects")
    }
}
