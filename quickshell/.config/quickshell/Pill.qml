import QtQuick
import QtQuick.Effects
import QtQuick.Layouts

Item {
    id: root

    property real spacing: 20
    property real padding: 24
    default property alias content: barRow.children
    readonly property alias pillItem: pillRect

    // Animated show/hide (fade + zoom from the center). Bind to whatever
    // condition controls the pill, e.g. `active: jobsRow.active`.
    // Always-on pills leave the default `true`.
    property bool active: true
    visible: opacity > 0.01
    opacity: active ? 1 : 0
    scale: active ? 1 : 0
    transformOrigin: Item.Center

    Behavior on opacity {
        NumberAnimation {
            duration: BarTheme.pillAnimDuration
            easing.type: BarTheme.animEasing
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: BarTheme.pillShowDuration
            easing.type: BarTheme.pillResizeEasing
        }
    }

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
        radius: 32
    }

    Rectangle {
        id: pillRect
        anchors.fill: parent
        implicitWidth: barRow.implicitWidth + root.padding * 2
        implicitHeight: BarTheme.barHeight
        color: BarTheme.pill
        radius: 32
        clip: true

        RowLayout {
            id: barRow
            anchors.centerIn: parent
            spacing: root.spacing
        }
    }
}
