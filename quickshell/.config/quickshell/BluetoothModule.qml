import Quickshell
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Layouts

Text {
    Layout.leftMargin: 3
    Layout.rightMargin: 3
    leftPadding: 9
    rightPadding: 9
    topPadding: 6
    bottomPadding: 6
    font.family: BarTheme.fontFamily
    font.pixelSize: BarTheme.fontPx
    color: BarTheme.fg
    opacity: BarTheme.dim
    horizontalAlignment: Text.AlignHCenter

    property int connectedCount: Bluetooth.devices ? Bluetooth.devices.values.length : 0

    text: {
        const adapter = Bluetooth.defaultAdapter;
        if (!adapter || !adapter.enabled)
            return "󰂲";
        return "";
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Quickshell.execDetached(["toggle-better-control", "-b"])
    }
}
