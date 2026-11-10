import Quickshell
import Quickshell.Io
import QtQuick
import ".."

// Tailscale 3x3 mark, lit when the backend is Running, faded
// otherwise. Click toggles up/down.
Item {
    id: tailscaleCell
    implicitWidth: 16
    implicitHeight: 16
    visible: installed

    property bool installed: false
    property bool connected: false
    property bool workNetwork: false
    property bool retried: false
    // Work tailnet color. No badge/chip: the mark itself changes color so
    // the asvla.com state is unmistakable next to the personal state.
    readonly property color workTint: BarTheme.isLight ? "#343958" : "#8FB3FF"
    readonly property color dotColor: workNetwork ? workTint : BarTheme.fg
    readonly property string user: Quickshell.env("USER") || Quickshell.env("LOGNAME") || ""
    readonly property bool busy: toggleProc.running || operatorProc.running

    function refresh() {
        if (installed && !tailscaleProbe.running)
            tailscaleProbe.running = true;
    }

    function runToggle() {
        toggleProc.command = tailscaleCell.connected ? ["tailscale", "down"] : ["tailscale", "up"];
        toggleProc.running = true;
    }

    function toggle() {
        if (!installed || busy)
            return;
        tailscaleCell.retried = false;
        runToggle();
    }

    Item {
        anchors.centerIn: parent
        width: 14
        height: 14
        opacity: 1.0

        Repeater {
            model: [0.24, 0.24, 0.24, 1, 1, 1, 0.24, 1, 0.24]
            Rectangle {
                required property real modelData
                required property int index
                width: 4
                height: 4
                radius: 2
                x: (index % 3) * 5
                y: Math.floor(index / 3) * 5
                color: tailscaleCell.dotColor
                opacity: tailscaleCell.connected ? modelData : 0.24
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.PointingHandCursor
        onClicked: tailscaleCell.toggle()
    }

    // status --json reports BackendState Running/Stopped/NeedsLogin/...;
    // anything but Running reads as disconnected. CurrentTailnet.Name
    // identifies which tailnet the profile is logged into.
    Process {
        id: tailscaleProbe
        command: ["tailscale", "status", "--json"]
        stdout: StdioCollector {
            onStreamFinished: {
                var connected = false;
                var work = false;
                try {
                    var status = JSON.parse(text);
                    connected = status.BackendState === "Running";
                    var tailnet = status.CurrentTailnet || {};
                    work = connected && String(tailnet.Name || "").toLowerCase() === "asvla.com";
                } catch (e) {
                    connected = false;
                }
                tailscaleCell.connected = connected;
                tailscaleCell.workNetwork = work;
            }
        }
    }

    Timer {
        id: tailscalePoll
        interval: 15000
        repeat: true
        running: tailscaleCell.installed
        onTriggered: tailscaleCell.refresh()
    }

    Timer {
        id: tailscaleRefreshSoon
        interval: 2500
        repeat: false
        onTriggered: tailscaleCell.refresh()
    }

    Process {
        id: toggleProc
        stdout: StdioCollector {
            id: toggleStdout
        }
        stderr: StdioCollector {
            id: toggleStderr
        }
        onExited: function(exitCode, exitStatus) {
            var err = String(toggleStderr.text || "");
            if (exitCode !== 0 && err.indexOf("Access denied") !== -1 && !tailscaleCell.retried && tailscaleCell.user !== "") {
                tailscaleCell.retried = true;
                operatorProc.running = true;
            } else {
                tailscaleRefreshSoon.restart();
            }
        }
    }

    // One-time authorization so up/down work without sudo afterwards,
    // same as omarchy's own tailscale panel. Pops a polkit dialog.
    Process {
        id: operatorProc
        command: ["pkexec", "tailscale", "set", "--operator=" + tailscaleCell.user]
        onExited: function(exitCode, exitStatus) {
            if (exitCode === 0)
                tailscaleCell.runToggle();
            else
                tailscaleRefreshSoon.restart();
        }
    }

    Process {
        id: whichProc
        command: ["bash", "-c", "command -v tailscale >/dev/null"]
        onExited: function(exitCode, exitStatus) {
            tailscaleCell.installed = exitCode === 0;
            if (exitCode === 0)
                tailscaleCell.refresh();
        }
    }

    Component.onCompleted: whichProc.running = true
}
