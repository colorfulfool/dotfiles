import Quickshell.Io
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: cpuRoot

    // No cpufreq on some machines (e.g. VMs): hide instead of a stuck "--.-GHz".
    visible: cpuRoot.available
    Layout.minimumWidth: 40
    spacing: 5

    property string cpuValue: "--.-GHz"
    property bool available: false

    BarText {
        text: "󰍛"
        opacity: BarTheme.dim
        Layout.alignment: Qt.AlignBaseline
    }

    BarText {
        text: cpuRoot.cpuValue
        opacity: BarTheme.dim
        horizontalAlignment: Text.AlignLeft
        Layout.alignment: Qt.AlignBaseline
    }

    Process {
        id: cpuProc
        running: true
        command: ["sh", "-c", "awk '{print $1}' /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq 2>/dev/null | sort -n | tail -1"]
        stdout: StdioCollector {
            onStreamFinished: {
                const khz = parseInt(text.trim(), 10);
                if (!isNaN(khz) && khz > 0) {
                    cpuRoot.cpuValue = (khz / 1000000).toFixed(1) + "GHz";
                    cpuRoot.available = true;
                } else {
                    cpuRoot.available = false;
                }
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: cpuProc.running = true
    }
}
