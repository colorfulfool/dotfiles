import Quickshell.Io
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: memRoot

    Layout.minimumWidth: 40
    spacing: 5

    property string memValue: "--.-GB"

    BarText {
        text: ""
        opacity: BarTheme.dim
        Layout.alignment: Qt.AlignBaseline
    }

    BarText {
        text: memRoot.memValue
        opacity: BarTheme.dim
        horizontalAlignment: Text.AlignLeft
        Layout.alignment: Qt.AlignBaseline
    }

    Process {
        id: memProc
        running: true
        command: ["sh", "-c", "awk '/MemTotal:/{t=$2}/MemAvailable:/{a=$2}END{printf \"%.1f\",(t-a)/1048576}' /proc/meminfo"]
        stdout: StdioCollector {
            onStreamFinished: {
                const gb = parseFloat(text.trim());
                if (!isNaN(gb))
                    memRoot.memValue = gb.toFixed(1) + "GB";
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: memProc.running = true
    }
}
