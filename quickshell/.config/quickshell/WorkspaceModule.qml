import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

Rectangle {
    required property var screen

    implicitWidth: wsLabel.implicitWidth
    color: (activeWs && activeWs.urgent) ? "#ff0000" : "transparent"

    property var activeWs: {
        const m = Hyprland.monitorFor(screen);
        return (m && m.activeWorkspace) ? m.activeWorkspace : Hyprland.focusedWorkspace;
    }

    BarText {
        id: wsLabel
        anchors.centerIn: parent
        text: activeWs ? activeWs.id : ""
        color: (activeWs && activeWs.urgent) ? "#1e1e1e" : BarTheme.fg
        opacity: (activeWs && activeWs.urgent) ? 1 : BarTheme.dim
    }
}
