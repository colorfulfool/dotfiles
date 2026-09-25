import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts

BarText {
    id: audioRoot

    Layout.preferredWidth: 16
    Layout.fillHeight: true
    verticalAlignment: Text.AlignVCenter
    opacity: BarTheme.dim
    horizontalAlignment: Text.AlignHCenter

    property var sink: Pipewire.defaultAudioSink

    PwObjectTracker {
        objects: Pipewire.defaultAudioSink ? [Pipewire.defaultAudioSink] : []
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
        }
    }
}
