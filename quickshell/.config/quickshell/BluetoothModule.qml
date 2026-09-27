import Quickshell
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Layouts

BarText {
    Layout.preferredWidth: 16
    Layout.fillHeight: true
    verticalAlignment: Text.AlignVCenter
    opacity: BarTheme.dim
    horizontalAlignment: Text.AlignHCenter

    property int connectedCount: {
        if (!Bluetooth.devices)
            return 0;
        const vals = Bluetooth.devices.values;
        let n = 0;
        for (let i = 0; i < vals.length; ++i)
            if (vals[i] && vals[i].connected)
                ++n;
        return n;
    }

    text: {
        const adapter = Bluetooth.defaultAdapter;
        if (!adapter || !adapter.enabled)
            return "";
        if (connectedCount > 0)
            return "";
        return "";
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Quickshell.execDetached(["toggle-better-control", "-b"])
    }
}
