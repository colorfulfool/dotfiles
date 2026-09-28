pragma Singleton
import QtQuick
import Quickshell.Io

Item {
    property string theme: "auto" // "dark" | "light" | "auto" (auto follows ~/.cache/quickshell-mode)

    FileView {
        id: modeFile
        path: "/home/colorfulfool/.cache/quickshell-mode"
        watchChanges: true
        blockLoading: true
        onFileChanged: reload()
    }
    readonly property bool isLight: theme === "light" ? true : theme === "dark" ? false : modeFile.text().trim() === "light"

    readonly property color pill: isLight ? Qt.rgba(1, 1, 1, 0.6) : Qt.rgba(24 / 255, 24 / 255, 24 / 255, 0.6)
    readonly property color fg: isLight ? "#000000" : "#ffffff"
    readonly property color menu: isLight ? "#ffffff" : Qt.rgba(24 / 255, 24 / 255, 24 / 255, 0.9)
    readonly property color hover: isLight ? "#e4e4e4" : "#3a3a3a"
    readonly property color separator: isLight ? "#d5d5d5" : "#3a3a3a"
    readonly property color subdued: isLight ? "#8a8f98" : "#585b70"
    readonly property real dim: 0.6
    readonly property color charged: isLight ? "#1a7f37" : "#a6e3a1"
    readonly property color low: isLight ? "#c81e1e" : "#ff0048"
    readonly property color blinkTo: isLight ? "#7f1d1d" : "#f38ba8"
    readonly property int pillAnimDuration: 100
    readonly property int animEasing: Easing.Linear
    readonly property int pillResizeDuration: 150
    readonly property int pillResizeEasing: Easing.OutQuad
    readonly property int barHeight: 40
}
