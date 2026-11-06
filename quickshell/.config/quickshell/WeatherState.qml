pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// Shared weather readout for the bar widgets: apparent temperature and US AQI
// for the configured omarchy weather location (or IP auto-detect when unset).
Item {
    id: root

    property real temperature: NaN
    property real apparentTemperature: NaN
    property real aqi: NaN
    property int weatherCode: -1
    property bool isDay: true
    property bool refreshQueued: false

    function refresh() {
        if (weatherProc.running) {
            root.refreshQueued = true;
            return;
        }
        weatherProc.running = true;
    }

    Process {
        id: weatherProc
        command: ["bash", Quickshell.shellPath("weather-data.sh")]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                var raw = String(text || "").trim();
                if (raw) {
                    try {
                        var data = JSON.parse(raw);
                        var temp = parseFloat(data.temperature);
                        var apparent = parseFloat(data.apparent);
                        var aqi = parseFloat(data.aqi);
                        var weather = parseInt(data.weather, 10);
                        if (!isNaN(temp))
                            root.temperature = temp;
                        if (!isNaN(apparent))
                            root.apparentTemperature = apparent;
                        if (!isNaN(aqi))
                            root.aqi = aqi;
                        if (!isNaN(weather))
                            root.weatherCode = weather;
                        if (data.day !== null && data.day !== undefined)
                            root.isDay = Number(data.day) !== 0;
                    } catch (e) {
                    }
                }
                if (root.refreshQueued) {
                    root.refreshQueued = false;
                    Qt.callLater(root.refresh);
                }
            }
        }
    }

    Timer {
        interval: 10 * 60 * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
