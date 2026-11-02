import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell

Item {
    id: root

    property string appName: ""
    property string appIcon: ""
    property string image: ""
    property string summary: ""
    property string body: ""
    property int urgency: 1

    signal dismissRequested()

    property bool hovered: false

    readonly property string iconSource: {
        const value = String(image.length > 0 ? image : appIcon)
        if (value.length === 0) return ""
        if (value.indexOf("file://") === 0 || value.indexOf("image://") === 0) return value
        if (value.charAt(0) === "/") return "file://" + value
        return Quickshell.iconPath(value, true)
    }
    readonly property bool hasIcon: iconSource.length > 0 && iconImage.status === Image.Ready

    implicitWidth: 376
    implicitHeight: card.height

    RectangularShadow {
        anchors.fill: card
        offset: Qt.vector2d(0, 4)
        color: BarTheme.notificationShadow
        blur: 28
        spread: 2
        radius: BarTheme.notificationRadius
    }

    Rectangle {
        id: card
        width: parent.width
        height: layout.implicitHeight + 24
        radius: BarTheme.notificationRadius
        color: BarTheme.notification

        RowLayout {
            id: layout
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12

            Image {
                id: iconImage
                source: root.iconSource
                visible: root.hasIcon
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48
                sourceSize.width: 48
                sourceSize.height: 48
                fillMode: Image.PreserveAspectFit
                asynchronous: true
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    Layout.fillWidth: true
                    text: root.summary
                    color: BarTheme.fg
                    font.family: "Noto Sans"
                    font.pointSize: 10
                    font.bold: true
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    text: root.body
                    visible: text.length > 0
                    color: BarTheme.fg
                    opacity: 0.8
                    font.family: "Noto Sans"
                    font.pointSize: 10
                    wrapMode: Text.Wrap
                    maximumLineCount: 5
                    elide: Text.ElideRight
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onContainsMouseChanged: root.hovered = containsMouse
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: root.dismissRequested()
        }
    }
}
