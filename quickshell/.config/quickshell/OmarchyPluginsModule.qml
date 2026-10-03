import Quickshell
import QtQuick

// Omarchy plugin launcher, driven solely by showIds.
//
// Shows one icon per listed plugin id and toggles it with a click, using
// the same IPC the built-in Omarchy bar uses:
//
//   omarchy-shell shell toggle <plugin-id>
//
//   uncomment `omarchy-launch-shell` in hyprland.lua, then run:
//   omarchy toggle bar off
//
// Customize with:
//   PluginModule {
//       showIds: ["omarchy.menu", "omarchy.audio", "my.cool-plugin"]
//       iconOverrides: { "my.cool-plugin": "" }
//   }
Row {
    id: pluginRow
    spacing: 4
    opacity: 0.7
    visible: showIds.length > 0

    // The full model: plugin ids to show, in order.
    property var showIds: []
    // Per-id glyph overrides, merged over the built-in defaults below.
    property var iconOverrides: ({})
    // Override when Omarchy lives somewhere unusual. Defaults to the
    // session env, then the packaged install path.
    property string omarchyPath: Quickshell.env("OMARCHY_PATH") || "/usr/share/omarchy"

    // Static glyphs approximating each built-in panel's bar button. Live
    // buttons render state-dependent glyphs (volume level, signal strength)
    // inside omarchy-shell; an external bar can only show a fixed icon.
    readonly property var defaultIcons: ({
        "omarchy.menu": "",
        "omarchy.audio": "",
        "omarchy.network": "",
        "omarchy.bluetooth": "",
        "omarchy.power": "",
        "omarchy.battery": "",
        "omarchy.monitor": "󰍹",
        "omarchy.clock": "",
        "omarchy.weather": "",
        "omarchy.agents": "",
        "omarchy.tailscale": "",
        "omarchy.clipboard": "",
        "omarchy.emojis": "",
        "omarchy.reminders": "󰂚",
        "omarchy.dropbox": "",
        "omarchy.media": "",
        "omarchy.microphone": "",
        "omarchy.system-update": ""
    })
    readonly property string fallbackIcon: ""

    function iconFor(id) {
        if (iconOverrides && iconOverrides[id] !== undefined)
            return iconOverrides[id];
        if (defaultIcons[id] !== undefined)
            return defaultIcons[id];
        return fallbackIcon;
    }

    function togglePlugin(id) {
        // bash wrapper pins OMARCHY_PATH so this works even when the
        // bar was launched without the full session env.
        Quickshell.execDetached(["bash", "-c", "export OMARCHY_PATH=\"$1\" PATH=\"/usr/bin:$PATH\"; exec omarchy-shell shell toggle \"$2\" \"{}\"", "plugin-module", pluginRow.omarchyPath, String(id)]);
    }

    Repeater {
        model: pluginRow.showIds

        Item {
            id: pluginCell
            required property var modelData
            implicitWidth: 16
            implicitHeight: 16

            BarText {
                anchors.centerIn: parent
                width: 16
                height: 16
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: pluginRow.iconFor(String(pluginCell.modelData))
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                cursorShape: Qt.PointingHandCursor
                onClicked: pluginRow.togglePlugin(String(pluginCell.modelData))
            }
        }
    }
}
