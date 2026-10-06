import Quickshell
import Quickshell.Io
import QtQuick
import ".."

// KDE job progress indicator (Dolphin copy/move jobs, etc).
// Polls Hyprland clients for a window titled like
//   "Moving (43% of 6.1 GiB) — Dolphin"
// Icon appears only while a job is running; clicking focuses it.
Item {
    id: root
    implicitWidth: 16
    implicitHeight: 16
    visible: active

    property bool active: jobAddress !== ""
    property string jobAddress: ""

    function focusJob() {
        if (jobAddress !== "")
            Quickshell.execDetached(["hyprctl", "dispatch", "focuswindow", "address:" + jobAddress]);
    }

    BarText {
        anchors.fill: parent
        font.family: "JetBrainsMono Nerd Font"
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        text: "\uf0c5"
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.PointingHandCursor
        onClicked: root.focusJob()
    }

    Process {
        id: probe
        command: ["bash", "-c", "hyprctl clients -j | jq -r '.[] | select(.title | test(\"\\\\(\\\\d+% of \")) | .address' | head -n1"]
        stdout: StdioCollector {
            onStreamFinished: {
                var addr = text.trim();
                root.jobAddress = addr.length > 0 ? addr : "";
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: if (!probe.running) probe.running = true
    }

    Component.onCompleted: if (!probe.running) probe.running = true
}
