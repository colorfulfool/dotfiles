import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Row {
    id: cpuRoot

    Layout.minimumWidth: 50
    Layout.leftMargin: 3
    Layout.rightMargin: 3
    spacing: 5

    property string cpuValue: "--.-GHz"

    Text {
        leftPadding: 12
        topPadding: 6
        bottomPadding: 6
        text: "󰍛"
        font.family: BarTheme.fontFamily
        font.pixelSize: BarTheme.fontPx
        color: BarTheme.fg
        opacity: BarTheme.dim
    }

    Text {
        rightPadding: 12
        topPadding: 6
        bottomPadding: 6
        text: cpuRoot.cpuValue
        font.family: BarTheme.fontFamily
        font.pixelSize: BarTheme.fontPx
        color: BarTheme.fg
        opacity: BarTheme.dim
        horizontalAlignment: Text.AlignLeft
    }

    Process {
        id: cpuProc
        running: true
        command: ["sh", "-c", "awk '{print $1}' /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq 2>/dev/null | sort -n | tail -1"]
        stdout: StdioCollector {
            onStreamFinished: {
                const khz = parseInt(text.trim(), 10);
                if (!isNaN(khz) && khz > 0)
                    cpuRoot.cpuValue = (khz / 1000000).toFixed(1) + "GHz";
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
