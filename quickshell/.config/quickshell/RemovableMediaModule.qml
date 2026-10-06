import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import ".."

// Removable media strip: one eject icon per connected partition/disk.
// Left click: eject. Right click: menu with Open / Mount|Unmount / Eject.
Row {
    id: root
    spacing: 4
    opacity: 0.7

    property bool hasMedia: devices.length > 0
    property var devices: []

    // Dismiss the menu when focus moves to another window. The focus grab
    // does not revoke on outside clicks on this setup. Events arriving right
    // at open (from the opening click itself) must be ignored, hence the
    // arming delay.
    Timer {
        id: menuArmTimer
        interval: 600
        onTriggered: menu.dismissArmed = true
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if ((event.name === "activewindow" || event.name === "activewindowv2") && menu.dismissArmed)
                menu.anchorCell = null;
        }
    }

    function refresh() {
        if (!probe.running)
            probe.running = true;
    }

    function displayName(dev) {
        return dev.label !== "" ? dev.label : dev.dev;
    }

    // Fresh device object for a dev path (the menu holds a path string so
    // probe refreshes can't leave it pointing at a destroyed delegate).
    function findDevice(devPath) {
        for (var i = 0; i < root.devices.length; ++i)
            if (root.devices[i].dev === devPath)
                return root.devices[i];
        return null;
    }

    function openDevice(dev) {
        if (dev.mountpoint !== "")
            Quickshell.execDetached(["xdg-open", dev.mountpoint]);
        else
            Quickshell.execDetached(["bash", "-c", "out=$(udisksctl mount -b \"$1\" 2>&1) || { if command -v hyprctl >/dev/null 2>&1; then timeout 2 hyprctl notify 3 8000 0 \"Failed to mount $2: $out\" >/dev/null 2>&1; fi; exit 1; }; mp=$(echo \"$out\" | sed -E 's/.* at \"(.*)\"/\\1/'); [ -d \"$mp\" ] && xdg-open \"$mp\"", "open-media", dev.dev, displayName(dev)]);
    }

    function mountDevice(dev) {
        Quickshell.execDetached(["bash", "-c", "out=$(udisksctl mount -b \"$1\" 2>&1) || { if command -v hyprctl >/dev/null 2>&1; then timeout 2 hyprctl notify 3 8000 0 \"Failed to mount $2: $out\" >/dev/null 2>&1; fi; exit 1; }", "mount-media", dev.dev, displayName(dev)]);
    }

    function unmountDevice(dev) {
            Quickshell.execDetached(["bash", "-c", "holders_of() { [ -n \"$1\" ] || return 0; command -v fuser >/dev/null 2>&1 || return 0; who=\"\"; n=0; for p in $(fuser -m \"$1\" 2>&1 | sed 's/^[^:]*://' | grep -o '[0-9][0-9]*' | sort -u); do c=$(cat /proc/$p/comm 2>/dev/null) || continue; case \",$who,\" in *\",$c,\"*) continue;; esac; who=${who:+$who, }$c; n=$((n+1)); [ $n -ge 3 ] && break; done; printf '%s' \"$who\"; }; out=$(udisksctl unmount -b \"$1\" 2>&1) || { msg=\"Failed to unmount $2: $(printf '%s' \"$out\" | head -n 1 | cut -c1-200)\"; case \"$out\" in *[Bb]usy*) mp=$(lsblk -no MOUNTPOINT \"$1\" 2>/dev/null | head -n 1); who=$(holders_of \"$mp\"); if [ -n \"$who\" ]; then msg=\"Failed to unmount $2: in use by $who. Close them and try again.\"; else msg=\"Failed to unmount $2: files are still open on it. Close any apps using it and try again.\"; fi;; esac; if command -v hyprctl >/dev/null 2>&1; then timeout 2 hyprctl notify 3 8000 0 \"$msg\" >/dev/null 2>&1; fi; exit 1; }", "unmount-media", dev.dev, displayName(dev)]);
    }

    function ejectDevice(dev) {
        Quickshell.execDetached(["bash", "-c", "dev=\"$1\"; name=\"$2\"; holders_of() { [ -n \"$1\" ] || return 0; command -v fuser >/dev/null 2>&1 || return 0; who=\"\"; n=0; for p in $(fuser -m \"$1\" 2>&1 | sed 's/^[^:]*://' | grep -o '[0-9][0-9]*' | sort -u); do c=$(cat /proc/$p/comm 2>/dev/null) || continue; case \",$who,\" in *\",$c,\"*) continue;; esac; who=${who:+$who, }$c; n=$((n+1)); [ $n -ge 3 ] && break; done; printf '%s' \"$who\"; }; fail() { msg=\"$1: $(printf '%s' \"$2\" | head -n 1 | cut -c1-200)\"; case \"$2\" in *[Bb]usy*) mp=$(lsblk -no MOUNTPOINT \"$dev\" 2>/dev/null | head -n 1); who=$(holders_of \"$mp\"); if [ -n \"$who\" ]; then msg=\"$1: in use by $who. Close them and try again.\"; else msg=\"$1: files are still open on it. Close any apps using it and try again.\"; fi;; esac; if command -v hyprctl >/dev/null 2>&1; then timeout 2 hyprctl notify 3 8000 0 \"$msg\" >/dev/null 2>&1; fi; exit 1; }; if [ -n \"$(lsblk -no MOUNTPOINT \"$dev\" 2>/dev/null | head -n 1)\" ]; then out=$(udisksctl unmount -b \"$dev\" 2>&1) || fail \"Failed to unmount $name\" \"$out\"; fi; parent=$(lsblk -no PKNAME \"$dev\" 2>/dev/null); if [ -n \"$parent\" ]; then target=\"/dev/$parent\"; else target=\"$dev\"; fi; out=$(udisksctl power-off -b \"$target\" 2>&1) || fail \"Failed to eject $name\" \"$out\"", "eject-media", dev.dev, displayName(dev)]);
    }

    Repeater {
        model: root.devices

        Item {
            id: cell
            required property var modelData
            width: 16
            height: 16

            BarText {
                anchors.fill: parent
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 16
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: "󰇪"
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                onClicked: mouse => {
                    if (mouse.button === Qt.LeftButton) {
                        root.ejectDevice(cell.modelData);
                    } else if (menu.anchorCell && menu.devPath === cell.modelData.dev) {
                        menu.anchorCell = null;
                    } else {
                        menu.dismissArmed = false;
                        menu.devPath = cell.modelData.dev;
                        menu.anchorCell = cell;
                        menuArmTimer.restart();
                    }
                }
            }
        }
    }

    PopupWindow {
        id: menu
        property string devPath: ""
        property var anchorCell: null
        property var device: root.findDevice(devPath)
        property bool dismissArmed: false

        visible: anchorCell !== null && device !== null
        onVisibleChanged: {
            if (!visible)
                dismissArmed = false;
        }
        anchor.item: anchorCell
        anchor.rect.x: anchorCell ? -(14 + anchorCell.width / 2) : 0
        // Popup bg top sits 4px below the pill's bottom edge (pill is
        // BarTheme.barHeight tall, icon centered within it).
        anchor.rect.y: anchorCell ? (BarTheme.barHeight - anchorCell.height) / 2 + anchorCell.height + 4 - 14 : 0
        color: "transparent"
        implicitWidth: menuLayout.implicitWidth + 48
        implicitHeight: menuLayout.implicitHeight + 44

        // Same dismissal pattern as TrayModule: the grab must wait for the
        // popup surface to map (backingWindowVisible), otherwise it races
        // the mapping, never engages, and outside clicks can't dismiss.
        HyprlandFocusGrab {
            active: menu.visible && menu.backingWindowVisible
            windows: [menu]
            onCleared: menu.anchorCell = null
        }
        RectangularShadow {
            anchors.fill: menuBg
            offset: Qt.vector2d(0, 2)
            color: Qt.rgba(0, 0, 0, 0.55)
            blur: 12
            spread: 0
            radius: 8
        }

        Rectangle {
            id: menuBg
            anchors.fill: parent
            anchors.margins: 14
            radius: 8
            color: BarTheme.menu
            clip: true

            ColumnLayout {
                id: menuLayout
                anchors.fill: parent
                anchors.margins: 8
                spacing: 0

                Repeater {
                    model: {
                        var d = menu.device;
                        var name = d ? root.displayName(d) : "";
                        var mounted = d && d.mountpoint !== "";
                        return [
                            { label: "Open " + name, action: "open" },
                            mounted ? { label: "Unmount " + name, action: "unmount" } : { label: "Mount " + name, action: "mount" },
                            { label: "Eject " + name, action: "eject" }
                        ];
                    }

                    Item {
                        id: entry
                        required property var modelData
                        Layout.fillWidth: true
                        Layout.preferredHeight: 28
                        implicitWidth: entryLabel.implicitWidth + 52

                        Rectangle {
                            anchors.fill: parent
                            radius: 4
                            color: entryMa.containsMouse ? BarTheme.hover : "transparent"
                        }

                        BarText {
                            id: entryLabel
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            verticalAlignment: Text.AlignVCenter
                            text: entry.modelData.label
                            color: BarTheme.fg
                        }

                        MouseArea {
                            id: entryMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                var dev = menu.device;
                                var act = entry.modelData.action;
                                menu.anchorCell = null;
                                if (!dev)
                                    return;
                                if (act === "open")
                                    root.openDevice(dev);
                                else if (act === "mount")
                                    root.mountDevice(dev);
                                else if (act === "unmount")
                                    root.unmountDevice(dev);
                                else if (act === "eject")
                                    root.ejectDevice(dev);
                            }
                        }
                    }
                }
            }
        }
    }

    Process {
        id: probe
        command: ["bash", "-c", "lsblk -J -o NAME,RM,TYPE,MOUNTPOINT,LABEL,SIZE | jq -c '[.blockdevices[] | select(.rm==true) | . as $d | if ($d.children|length) > 0 then ($d.children[] | select(.type==\"part\")) else $d end | {dev: (\"/dev/\" + .name), label: (.label // \"\"), mountpoint: (.mountpoint // \"\"), size: .size}]'"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var fresh = JSON.parse(text);
                    // Only reassign on real change: a new array identity would
                    // otherwise rebuild all delegates every poll, killing the
                    // open menu's anchor and breaking toggle-to-dismiss.
                    if (JSON.stringify(fresh) !== JSON.stringify(root.devices))
                        root.devices = fresh;
                } catch (e) {
                    if (root.devices.length !== 0)
                        root.devices = [];
                }
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    Component.onCompleted: root.refresh()
}
