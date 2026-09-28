import QtQuick
import QtQuick.Effects
import QtQuick.Layouts

Item {
    id: root

    property real spacing: 20
    default property alias content: barRow.children
    readonly property alias pillItem: pillRect

    implicitWidth: pillRect.implicitWidth
    implicitHeight: pillRect.implicitHeight
    width: implicitWidth
    height: implicitHeight

    RectangularShadow {
        anchors.fill: pillRect
        offset: Qt.vector2d(0, 2)
        color: Qt.rgba(0, 0, 0, 0.55)
        blur: 12
        spread: 0
        radius: 8
    }

    Rectangle {
        id: pillRect
        anchors.fill: parent
        implicitWidth: barRow.implicitWidth + 48
        implicitHeight: 40
        color: BarTheme.pill
        topLeftRadius: 0
        topRightRadius: 0
        bottomLeftRadius: 8
        bottomRightRadius: 8
        clip: true

        RowLayout {
            id: barRow
            anchors.centerIn: parent
            spacing: root.spacing
        }
    }
}
