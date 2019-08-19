import QtQuick 2.13

Item {
    id: rootImage
    implicitWidth: image.implicitWidth
    implicitHeight: image.implicitHeight

    property color tint

    property alias source: image.source
    property alias fillMode: image.fillMode

    Image { id: image; anchors.fill: parent }

    Component.onCompleted: {
        if (tint !== undefined) {
            image.visible = false

            Qt.createQmlObject('
                import QtQuick 2.13;
                import QtGraphicalEffects 1.0;
                ColorOverlay {
                    anchors.fill: image;
                    source: image; color: tint;
                }
                ', rootImage, "tinted")
        }
    }
}
