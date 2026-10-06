import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import ".."

// KDE job progress indicator (Dolphin copy/move jobs, etc).
// Polls Hyprland clients for a window titled like
//   "Moving (43% of 6.1 GiB) — Dolphin"
// Icon appears only while a job is running. The Dolphin job dialog is
// hidden to a special workspace on detection; clicking the icon toggles
// a dropdown (positioned below the icon like tray menus) with job
// details and show/hide actions for the dialog itself.
Item {
    id: root
    implicitWidth: 16
    implicitHeight: 16
    visible: active

    property bool active: jobAddress !== ""
    property string jobAddress: ""
    property string jobTitle: ""
    // Dropdown visibility. Hidden by default; the icon toggles it.
    property bool jobOpen: false
    // True once the Dolphin dialog has been stashed in the special
    // workspace (i.e. the external job window is hidden by default).
    property bool inSpecial: false

    // Same blue as the volume progressbar (AudioModule fillColor).
    readonly property color jobBlue: BarTheme.isLight ? "#1818B2" : "#3DAEE9"

    function toggleJobs() {
        if (!active)
            return;
        jobOpen = !jobOpen;
    }

    function closeJobs() {
        jobOpen = false;
    }

    function hideExternal(addr) {
        var a = addr || jobAddress;
        if (a === "")
            return;
        Quickshell.execDetached(["bash", "-c", "hyprctl dispatch movetoworkspacesilent \"special:kdejobs,address:" + a + "\" >/dev/null 2>&1"]);
        inSpecial = true;
    }

    // Restore the Dolphin dialog and try to place it below the bar icon
    // (tray-menu style: 4px below the pill). Best effort: if the pixel
    // move fails the dialog still shows and focuses.
    function showExternalBelowIcon() {
        if (jobAddress === "")
            return;
        var p = iconCell.mapToGlobal(0, 0);
        var cx = Math.round(p.x + iconCell.width / 2);
        var y = Math.round(p.y + iconCell.height + (42 - iconCell.height) / 2 + 4);
        var script = "addr=\"" + jobAddress + "\"; cx=" + cx + "; y=" + y + "; " + "if hyprctl clients -j | jq -e --arg a \"$addr\" '.[] | select(.address == $a) | select(.workspace.name == \"special:kdejobs\")' >/dev/null 2>&1; then " + "hyprctl dispatch togglespecialworkspace kdejobs >/dev/null 2>&1; " + "fi; " + "hyprctl dispatch setfloating \"address:$addr\" >/dev/null 2>&1; " + "w=$(hyprctl clients -j | jq -r --arg a \"$addr\" '.[] | select(.address == $a) | .size[0]'); " + "case \"$w\" in ''|null) w=400;; esac; " + "x=$((cx - w / 2)); " + "hyprctl dispatch movewindowpixel exact \"$x $y,address:$addr\" >/dev/null 2>&1; " + "hyprctl dispatch focuswindow \"address:$addr\" >/dev/null 2>&1";
        Quickshell.execDetached(["bash", "-c", script]);
        inSpecial = false;
    }

    function focusJob() {
        showExternalBelowIcon();
    }

    Item {
        id: iconCell
        anchors.fill: parent
        implicitWidth: 16
        implicitHeight: 16

        BarText {
            id: iconText
            anchors.fill: parent
            font.family: "JetBrainsMono Nerd Font"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text: "\uf0c5"
            color: root.jobBlue

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                running: root.active
                NumberAnimation {
                    to: 0.35
                    duration: 900
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    to: 1.0
                    duration: 900
                    easing.type: Easing.InOutQuad
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            cursorShape: Qt.PointingHandCursor
            onClicked: root.toggleJobs()
        }
    }

    HyprlandFocusGrab {
        active: root.jobOpen && jobWin.backingWindowVisible
        windows: [jobWin]
        onCleared: root.closeJobs()
    }

    PopupWindow {
        id: jobWin
        visible: root.jobOpen && root.active
        anchor.item: iconCell
        anchor.rect.x: 0 - (jobBg.anchors.margins + iconCell.width / 2)
        // Pill is 42 high (shell.qml) with the 16px icon centered.
        // Popup top is placed so the visible jobBg sits 4px below
        // the pill bottom (the 14px transparent margin is shadow
        // bleed, not gap). Same math as TrayModule menus.
        anchor.rect.y: iconCell.height + (42 - iconCell.height) / 2 - jobBg.anchors.margins - 1
        color: "transparent"
        implicitWidth: jobLayout.implicitWidth + 48
        implicitHeight: jobLayout.implicitHeight + 44

        RectangularShadow {
            anchors.fill: jobBg
            offset: Qt.vector2d(0, 2)
            color: Qt.rgba(0, 0, 0, 0.55)
            blur: 12
            spread: 0
            radius: 8
        }

        Rectangle {
            id: jobBg
            anchors.fill: parent
            anchors.margins: 14
            bottomLeftRadius: 8
            bottomRightRadius: 8
            color: BarTheme.menu
            clip: true

            ColumnLayout {
                id: jobLayout
                anchors.fill: jobBg
                anchors.margins: 8
                spacing: 4

                BarText {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 260
                    text: root.jobTitle !== "" ? root.jobTitle : "File operation in progress"
                    color: BarTheme.fg
                    elide: Text.ElideRight
                    maximumLineCount: 2
                    wrapMode: Text.Wrap
                }

                BarText {
                    Layout.fillWidth: true
                    text: "KDE job running"
                    color: root.jobBlue
                    elide: Text.ElideRight
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 28
                        radius: 4
                        color: showMa.containsMouse ? BarTheme.hover : "transparent"

                        BarText {
                            anchors.centerIn: parent
                            text: "Show dialog"
                            color: BarTheme.fg
                        }

                        MouseArea {
                            id: showMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.showExternalBelowIcon()
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 28
                        radius: 4
                        color: hideMa.containsMouse ? BarTheme.hover : "transparent"

                        BarText {
                            anchors.centerIn: parent
                            text: "Hide dialog"
                            color: BarTheme.fg
                        }

                        MouseArea {
                            id: hideMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.hideExternal("")
                        }
                    }
                }
            }
        }
    }

    Process {
        id: probe
        command: ["bash", "-c", "hyprctl clients -j | jq -r '.[] | select(.title | test(\"\\\\(\\\\d+% of \")) | .address' | head -n1"]
        stdout: StdioCollector {
            onStreamFinished: {
                var addr = text.trim();
                var isNew = root.jobAddress === "" && addr.length > 0;
                root.jobAddress = addr.length > 0 ? addr : "";
                if (isNew) {
                    // New job: keep its dialog hidden by default and
                    // keep our dropdown closed until the icon is clicked.
                    root.jobOpen = false;
                    root.hideExternal(addr);
                }
                if (root.jobAddress !== "" && !titleProc.running)
                    titleProc.running = true;
            }
        }
    }

    // Title lookup by address. The command is built by concatenation so
    // the jq filter stays single-quoted with no nested double quotes.
    Process {
        id: titleProc
        command: ["bash", "-c", "hyprctl clients -j | jq -r --arg a " + root.jobAddress + " '.[] | select(.address == $a) | .title'"]
        stdout: StdioCollector {
            onStreamFinished: {
                var t = text.trim();
                if (t.length > 0)
                    root.jobTitle = t;
            }
        }
    }

    onJobAddressChanged: {
        if (jobAddress === "") {
            jobTitle = "";
            jobOpen = false;
            inSpecial = false;
        } else {
            jobTitle = "";
            if (!titleProc.running)
                titleProc.running = true;
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
