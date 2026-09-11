pragma Singleton
import QtQuick

QtObject {
    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int fontPx: 13
    readonly property color pill: Qt.rgba(24 / 255, 24 / 255, 24 / 255, 0.7)
    readonly property color fg: "#ffffff"
    readonly property real dim: 0.6
    readonly property color charged: "#a6e3a1"
    readonly property color low: "#ff0048"
    readonly property color blinkTo: "#f38ba8"
}
