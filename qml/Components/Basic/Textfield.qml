import QtQuick 2.13
import QtQuick.Controls 2.5

TextField {
    id: rootTf

    color: color_secondary
    placeholderTextColor: settings.darkTheme ? color_content_bg : color_divider

    background: Rectangle {
        color: color_background; border {
            width: 2; color: color_divider
        }
    }
}
