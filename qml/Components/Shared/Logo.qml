import QtQuick 2.13
import QtGraphicalEffects 1.13

Item {
    id: rootLogo
    implicitWidth: maskText.implicitWidth
    implicitHeight: maskText.implicitHeight

    property string accent: color_accent
    property string color: color_primary

    Rectangle {
        id: bg
        anchors.fill: maskText; visible: false; gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: accent }
            GradientStop { position: 1.0; color: rootLogo.color }
        }
    }

    Text {
        id: maskText; bottomPadding: 8
        text: "Video Player Concept"; color: color_primary; visible: false
        font { family: "Nickainley"; pixelSize: 29; weight: Font.Light } anchors {
            centerIn: parent; verticalCenterOffset: 4
        }
    }

    OpacityMask {
        anchors.fill: maskText
        source: bg; maskSource: maskText
    }
}
