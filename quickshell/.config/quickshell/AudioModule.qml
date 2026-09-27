import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts

Item {
    id: audioRoot

    readonly property int iconWidth: 16
    readonly property int barWidth: 80
    readonly property int barHeight: 10
    readonly property int barSpacing: 8
    readonly property color fillColor: BarTheme.isLight ? "#1818B2" : "#3DAEE9"
    readonly property color trackColor: Qt.rgba(0, 0, 0, 0.35)
    readonly property int hideDelayMs: 1200

    Layout.preferredWidth: showingBar ? iconWidth + barSpacing + barWidth : iconWidth
    Layout.fillHeight: true

    Behavior on Layout.preferredWidth {
        NumberAnimation {
            duration: BarTheme.pillResizeDuration
            easing.type: BarTheme.pillResizeEasing
        }
    }

    property var sink: Pipewire.defaultAudioSink
    property real volume: (sink && sink.audio) ? sink.audio.volume : 0
    property bool muted: (sink && sink.audio) ? sink.audio.muted : true
    property bool showingBar: false
    property bool _ready: false
    property bool leaving: false
    property bool expanded: false
    readonly property bool barActive: showingBar && !leaving && expanded

    readonly property real fillFraction: muted ? 0 : Math.min(1, Math.max(0, volume))

    function poke() {
        if (!_ready)
            return;
        leaving = false;
        leaveTimer.stop();
        if (!showingBar) {
            showingBar = true;
            expanded = false;
            expandTimer.restart();
        }
        hideTimer.restart();
    }

    onVolumeChanged: poke()
    onMutedChanged: poke()

    Component.onCompleted: _ready = true

    PwObjectTracker {
        objects: Pipewire.defaultAudioSink ? [Pipewire.defaultAudioSink] : []
    }

    // Hardware volume keys at the clamp (100% + up, 0% + down) produce no
    // PipeWire value change, so onVolumeChanged never fires. The Hyprland
    // bindings touch this file on every keypress so the OSD still appears.
    FileView {
        path: "/home/colorfulfool/.cache/quickshell-audio-poke"
        watchChanges: true
        blockLoading: true
        onFileChanged: audioRoot.poke()
    }

    Timer {
        id: hideTimer
        interval: audioRoot.hideDelayMs
        repeat: false
        onTriggered: {
            audioRoot.leaving = true;
            leaveTimer.restart();
        }
    }

    Timer {
        id: leaveTimer
        interval: 160
        repeat: false
        onTriggered: {
            audioRoot.showingBar = false;
            audioRoot.leaving = false;
            audioRoot.expanded = false;
        }
    }

    Timer {
        id: expandTimer
        interval: BarTheme.pillResizeDuration
        repeat: false
        onTriggered: audioRoot.expanded = true
    }

    BarText {
        id: iconText
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: audioRoot.iconWidth
        height: audioRoot.height
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        opacity: audioRoot.barActive ? 1 : BarTheme.dim
        color: audioRoot.barActive ? audioRoot.fillColor : BarTheme.fg

        Behavior on opacity {
            NumberAnimation {
                duration: 150
                easing.type: BarTheme.animEasing
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: 150
                easing.type: BarTheme.animEasing
            }
        }

        text: {
            if (!sink || !sink.audio)
                return "󰝟";
            if (sink.audio.muted)
                return "󰝟";
            const desc = ((sink.description || "") + " " + (sink.name || "")).toLowerCase();
            if (desc.indexOf("bluez") !== -1 || desc.indexOf("bluetooth") !== -1)
                return "󰂰";
            if (desc.indexOf("headphone") !== -1 || desc.indexOf("headset") !== -1)
                return "";
            const v = sink.audio.volume;
            if (v <= 0.01)
                return "󰖀";
            if (v < 0.5)
                return "󰕾";
            return "";
        }
    }

    Rectangle {
        id: track
        anchors.left: iconText.right
        anchors.leftMargin: audioRoot.barSpacing
        anchors.verticalCenter: parent.verticalCenter
        width: Math.max(0, audioRoot.width - audioRoot.iconWidth - audioRoot.barSpacing)
        height: audioRoot.barHeight
        radius: height / 2
        color: audioRoot.trackColor
        clip: true
        opacity: audioRoot.barActive ? 1 : 0
        visible: opacity > 0.01

        Behavior on opacity {
            NumberAnimation {
                duration: BarTheme.pillAnimDuration
                easing.type: BarTheme.animEasing
            }
        }

        Rectangle {
            id: fill
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height
            width: audioRoot.barWidth * audioRoot.fillFraction
            radius: parent.radius
            color: audioRoot.fillColor
            opacity: audioRoot.barActive ? 1 : 0

            Behavior on width {
                NumberAnimation {
                    duration: 60
                    easing.type: BarTheme.animEasing
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Quickshell.execDetached(["toggle-better-control", "-v"])
        onWheel: wheel => {
            if (!audioRoot.sink || !audioRoot.sink.audio)
                return;
            const cur = audioRoot.sink.audio.volume;
            const next = Math.min(1, Math.max(0, cur + (wheel.angleDelta.y > 0 ? 0.05 : -0.05)));
            audioRoot.sink.audio.volume = next;
            audioRoot.poke();
        }
    }
}
