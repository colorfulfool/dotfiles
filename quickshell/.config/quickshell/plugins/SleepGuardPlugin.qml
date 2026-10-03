import Quickshell
import Quickshell.Io
import QtQuick
import ".."

// Sleep guard plugin: same three modes as omacom/omarchy#11525:
//   faded cup          - sleep as usual (allow idle + lid suspend)
//   cup with badge     - don't sleep on lid close / screen fade as long as
//                        agents are working
//   lit cup            - don't sleep at all (block idle + lid + sleep)
//
// Pure UI over lid-guard: the mode lives in
// ~/.local/state/lid-guard/mode (missing reads as `agents`, the historic
// always-guard-agents behavior), clicks run `lid-guard mode <next>`, and
// the lid-guard daemon owns the only inhibitors. Click cycles
// allow -> awake -> agents.
Item {
    id: sleepCell
    implicitWidth: 16
    implicitHeight: 16

    readonly property string home: Quickshell.env("HOME")
    readonly property string stateDir: home + "/.local/state/lid-guard"
    // "allow" | "awake" | "agents". Defaults to agents to match the daemon.
    property string sleepMode: "agents"

    readonly property bool lit: sleepMode !== "allow"
    readonly property bool showBadge: sleepMode === "agents"
    // Badge geometry, shared by the knockout below and the badge item.
    // Small, tucked into the bottom-right corner clear of the handle.
    readonly property real badgeSizeFrac: 0.38
    readonly property real badgeCX: 0.92
    readonly property real badgeCY: 0.75

    function nextMode(mode) {
        if (mode === "allow")
            return "awake";
        if (mode === "awake")
            return "agents";
        return "allow";
    }

    function refreshMode() {
        if (!modeProbe.running)
            modeProbe.running = true;
    }

    function applyMode(mode) {
        if (mode !== "allow" && mode !== "awake" && mode !== "agents")
            return;
        sleepMode = mode;
    }

    function cycleMode() {
        var next = nextMode(sleepMode);
        // Optimistic: the dir watcher confirms once lid-guard persists it.
        applyMode(next);
        Quickshell.execDetached(["lid-guard", "mode", next]);
    }

    // Coffee cup (same glyph as the top-bar Stay Awake indicator in
    // omacom/omarchy#11525) with the badge seat knocked out to transparent
    // negative space; the frozen arc spinner floats in it.
    Canvas {
        id: cupLayer
        x: 0
        y: 0
        width: parent.width + 4
        height: parent.height
        opacity: sleepCell.lit ? 1.0 : 0.35
        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            var s = Math.round(parent.height);
            ctx.font = "600 " + s + "px 'JetBrainsMono Nerd Font'";
            ctx.textAlign = "center";
            ctx.textBaseline = "middle";
            ctx.fillStyle = BarTheme.fg;
            ctx.fillText("󰅶", parent.width / 2.3, parent.height / 1.4);
            if (sleepCell.showBadge) {
                var bw = parent.width * sleepCell.badgeSizeFrac;
                ctx.save();
                ctx.globalCompositeOperation = "destination-out";
                ctx.beginPath();
                ctx.arc(parent.width * sleepCell.badgeCX, parent.height * sleepCell.badgeCY, bw / 2 + 1.0, 0, Math.PI * 2);
                ctx.fill();
                ctx.restore();
            }
        }
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
    }

    Item {
        id: badge
        visible: sleepCell.showBadge
        width: Math.round(parent.width * parent.badgeSizeFrac)
        height: Math.round(parent.height * parent.badgeSizeFrac)
        x: parent.width * parent.badgeCX - width / 2
        y: parent.height * parent.badgeCY - height / 2

        Canvas {
            id: spinner
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                var d = Math.min(width, height);
                ctx.lineWidth = Math.max(1.2, d * 0.22);
                ctx.lineCap = "round";
                ctx.strokeStyle = BarTheme.fg;
                ctx.beginPath();
                ctx.arc(width / 2, height / 2, d / 2 - ctx.lineWidth / 2, -Math.PI / 2, Math.PI * 0.75);
                ctx.stroke();
            }
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
        }

        Connections {
            target: BarTheme
            function onFgChanged() {
                spinner.requestPaint();
            }
        }
    }

    Connections {
        target: sleepCell
        function onSleepModeChanged() {
            cupLayer.requestPaint();
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.PointingHandCursor
        onClicked: sleepCell.cycleMode()
    }

    // Reads lid-guard's mode file. Missing/invalid reads as agents,
    // mirroring the daemon default.
    Process {
        id: modeProbe
        command: ["bash", "-c", "f=\"$HOME/.local/state/lid-guard/mode\"; if [[ ! -f $f ]]; then echo agents; else cat \"$f\"; fi"]
        stdout: StdioCollector {
            onStreamFinished: {
                var mode = text.trim();
                if (mode === "allow" || mode === "awake" || mode === "agents")
                    sleepCell.applyMode(mode);
            }
        }
    }

    FileView {
        id: modeFileWatcher
        path: sleepCell.stateDir + "/mode"
        watchChanges: true
        printErrors: false
        onFileChanged: sleepCell.refreshMode()
    }

    // Fallback: FileView doesn't notice the file being created if it
    // didn't exist at startup, so poll cheaply as well.
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: sleepCell.refreshMode()
    }

    Component.onCompleted: refreshMode()
}
