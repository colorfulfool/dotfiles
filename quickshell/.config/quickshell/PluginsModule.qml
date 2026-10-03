import Quickshell
import Quickshell.Io
import QtQuick

// Standalone plugin strip, styled like TrayModule (spacing 4, dimmed).
//
// First plugin: sleep guard with the same three modes as
// omacom/omarchy#11525:
//   faded disc         - sleep as usual (allow idle + lid suspend)
//   disc with ring     - don't sleep on lid close / screen fade as long as
//                        agents are working
//   lit disc           - don't sleep at all (block idle + lid + sleep)
//
// Pure UI over lid-guard: the mode lives in
// ~/.local/state/lid-guard/mode (missing reads as `agents`, the historic
// always-guard-agents behavior), clicks run `lid-guard mode <next>`, and
// the lid-guard daemon owns the only inhibitors. Click cycles
// allow -> awake -> agents.
Row {
    id: pluginsRow
    spacing: 4
    opacity: 0.7

    property string home: Quickshell.env("HOME")
    property string stateDir: home + "/.local/state/lid-guard"

    // "allow" | "awake" | "agents". Defaults to agents to match the daemon.
    property string sleepMode: "agents"
    property bool agentsWorking: false

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
        pluginsRow.sleepMode = mode;
        if (mode === "agents") {
            agentsPoll.restart();
            if (!agentsProbe.running)
                agentsProbe.running = true;
        } else {
            agentsPoll.stop();
            pluginsRow.agentsWorking = false;
        }
    }

    function cycleMode() {
        var next = nextMode(pluginsRow.sleepMode);
        // Optimistic: the dir watcher confirms once lid-guard persists it.
        pluginsRow.applyMode(next);
        Quickshell.execDetached(["lid-guard", "mode", next]);
    }

    Item {
        id: sleepCell
        implicitWidth: 16
        implicitHeight: 16

        readonly property bool lit: pluginsRow.sleepMode !== "allow"
        readonly property bool showBadge: pluginsRow.sleepMode === "agents"
        // Badge geometry, shared by the knockout below and the badge item.
        // Small, tucked into the bottom-right corner clear of the handle.
        readonly property real badgeSizeFrac: 0.38
        readonly property real badgeCX: 0.762
        readonly property real badgeCY: 0.738

        // Solid disc with the badge seat knocked out to transparent
        // negative space; the opaque static ring floats in it.
        // Pure vector shapes, no font glyph.
        Canvas {
            id: cupLayer
            anchors.fill: parent
            opacity: sleepCell.lit ? 1.0 : BarTheme.dim
            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                ctx.fillStyle = BarTheme.fg;
                var cr = Math.min(width, height) * 0.375;
                ctx.beginPath();
                ctx.arc(width * 0.47, height * 0.47, cr, 0, Math.PI * 2);
                ctx.fill();
                if (sleepCell.showBadge) {
                    var bw = width * sleepCell.badgeSizeFrac;
                    ctx.save();
                    ctx.globalCompositeOperation = "destination-out";
                    ctx.beginPath();
                    ctx.arc(width * sleepCell.badgeCX, height * sleepCell.badgeCY, bw / 2 + 1.5, 0, Math.PI * 2);
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
                    ctx.arc(width / 2, height / 2, d / 2 - ctx.lineWidth / 2, 0, Math.PI * 2);
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
            target: pluginsRow
            function onSleepModeChanged() {
                cupLayer.requestPaint();
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            cursorShape: Qt.PointingHandCursor
            onClicked: pluginsRow.cycleMode()
        }
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
                    pluginsRow.applyMode(mode);
            }
        }
    }

    FileView {
        id: stateDirWatcher
        path: pluginsRow.stateDir
        watchChanges: true
        printErrors: false
        onFileChanged: pluginsRow.refreshMode()
    }

    // herdr is the working signal for the badge only (the daemon owns
    // the actual hold): missing or failing probe reads as not working.
    Timer {
        id: agentsPoll
        interval: 10000
        repeat: true
        running: pluginsRow.sleepMode === "agents"
        onTriggered: {
            if (!agentsProbe.running)
                agentsProbe.running = true;
        }
    }

    Process {
        id: agentsProbe
        command: ["bash", "-c", "timeout 10 herdr agent list 2>/dev/null | python3 -c 'import json,sys\ntry:\n data=json.load(sys.stdin)\nexcept Exception:\n sys.exit(1)\nagents=data.get(\"result\",{}).get(\"agents\",data.get(\"agents\",[]))\nws=[a for a in agents if a.get(\"agent\") in (\"claude\",\"opencode\") and a.get(\"agent_status\")==\"working\"]\nsys.exit(0 if ws else 1)'"]
        onExited: function(exitCode, exitStatus) {
            pluginsRow.agentsWorking = exitCode === 0;
        }
    }

    Component.onCompleted: refreshMode()
}
