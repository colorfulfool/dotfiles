import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

Rectangle {
    required property var screen

    Layout.leftMargin: 3
    Layout.topMargin: 6
    Layout.bottomMargin: 6
    Layout.rightMargin: 3
    implicitWidth: wsLabel.implicitWidth + 12
    implicitHeight: wsLabel.implicitHeight + 12
    radius: 4
    color: (activeWs && activeWs.urgent) ? "#ff0000" : "transparent"

    property var activeWs: {
        const m = Hyprland.monitorFor(screen);
        return (m && m.activeWorkspace) ? m.activeWorkspace : Hyprland.focusedWorkspace;
    }

    Text {
        id: wsLabel
        anchors.centerIn: parent
        text: activeWs ? activeWs.id : ""
        font.family: BarTheme.fontFamily
        font.pixelSize: BarTheme.fontPx
        color: (activeWs && activeWs.urgent) ? "#1e1e1e" : BarTheme.fg
        opacity: (activeWs && activeWs.urgent) ? 1 : BarTheme.dim
    }
}
