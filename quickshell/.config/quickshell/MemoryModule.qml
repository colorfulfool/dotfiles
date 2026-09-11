import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Row {
    id: memRoot

    Layout.minimumWidth: 50
    Layout.leftMargin: 3
    Layout.rightMargin: 3
    spacing: 5

    property string memValue: "--.-GB"

    Text {
        leftPadding: 12
        topPadding: 6
        bottomPadding: 6
        text: ""
        font.family: BarTheme.fontFamily
        font.pixelSize: BarTheme.fontPx
        color: BarTheme.fg
        opacity: BarTheme.dim
    }

    Text {
        rightPadding: 12
        topPadding: 6
        bottomPadding: 6
        text: memRoot.memValue
        font.family: BarTheme.fontFamily
        font.pixelSize: BarTheme.fontPx
        color: BarTheme.fg
        opacity: BarTheme.dim
        horizontalAlignment: Text.AlignLeft
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
