import Quickshell
import Quickshell.Networking
import QtQuick
import QtQuick.Layouts

BarText {
    id: netRoot

    Layout.preferredWidth: 16
    Layout.fillHeight: true
    Layout.rightMargin: 4
    verticalAlignment: Text.AlignVCenter
    opacity: BarTheme.dim
    horizontalAlignment: Text.AlignHCenter

    property bool hasWifi: false
    property bool hasWired: false
    property bool wifiOff: false

    text: {
        const devs = Networking.devices ? Networking.devices.values : [];
        let wifi = false, wired = false;
        for (let i = 0; i < devs.length; ++i) {
            const d = devs[i];
            if (!d || !d.connected)
                continue;
            if (d.type === DeviceType.Wifi)
                wifi = true;
            else if (d.type === DeviceType.Wired)
                wired = true;
            else
                wifi = true;
        }
        netRoot.hasWifi = wifi;
        netRoot.hasWired = wired;
        netRoot.wifiOff = !Networking.wifiEnabled;
        if (wifi)
            return "";
        // nf-md-ethernet: U+F796 (nf-fa-ethernet) is missing from JetBrainsMono Nerd Font.
        if (wired)
            return "󰈀";
        if (!Networking.wifiEnabled)
            return " •‿•";
        return "⚠";
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Quickshell.execDetached(["toggle-better-control", "-w"])
    }
}
