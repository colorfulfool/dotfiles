import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root

    readonly property real temperature: WeatherState.apparentTemperature
    readonly property real aqi: WeatherState.aqi
    readonly property int code: WeatherState.weatherCode
    readonly property bool day: WeatherState.isDay
    readonly property bool ready: !isNaN(temperature)
    readonly property bool aqiReady: !isNaN(aqi)
    readonly property color dangerColor: {
        const value = Math.round(aqi);
        if (value <= 50)
            return BarTheme.isLight ? "#1a7f37" : "#4ade80";
        if (value <= 100)
            return BarTheme.isLight ? "#8a6d00" : "#facc15";
        if (value <= 150)
            return BarTheme.isLight ? "#b45309" : "#fb923c";
        if (value <= 200)
            return BarTheme.isLight ? "#c81e1e" : "#f87171";
        if (value <= 300)
            return BarTheme.isLight ? "#7e22ce" : "#c084fc";
        return BarTheme.isLight ? "#7f1d1d" : "#f38ba8";
    }
    spacing: 4

    function conditionIcon(code, day) {
        switch (code) {
        case 0:
            return day ? "\ue30d" : "\ue32b";
        case 1:
        case 2:
            return day ? "\ue302" : "\ue32e";
        case 3:
            return "\ue33d";
        case 45:
        case 48:
            return day ? "\ue313" : "\ue346";
        case 51:
        case 53:
        case 55:
        case 61:
        case 63:
        case 65:
        case 80:
        case 81:
        case 82:
            return day ? "\ue308" : "\ue333";
        case 56:
        case 57:
        case 66:
        case 67:
            return "\ue3ad";
        case 71:
        case 73:
        case 75:
        case 77:
            return day ? "\ue30a" : "\ue327";
        case 85:
        case 86:
            return "\ue31a";
        case 95:
        case 96:
        case 99:
            return "\ue31d";
        default:
            return "\ue33d";
        }
    }

    RowLayout {
        Layout.alignment: Qt.AlignVCenter
        spacing: 0

        Item {
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: 16
            implicitHeight: 16
            visible: root.code >= 0

            BarText {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 1
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 16
                text: root.conditionIcon(root.code, root.day)
                opacity: BarTheme.dim
            }
        }

        BarText {
            Layout.alignment: Qt.AlignVCenter
            text: root.ready ? Math.round(root.temperature) + "°" : "--°"
            opacity: BarTheme.dim
        }
    }

    BarText {
        Layout.alignment: Qt.AlignVCenter
        text: root.aqiReady ? Math.round(root.aqi) : "--"
        color: root.aqiReady ? root.dangerColor : BarTheme.fg
        opacity: root.aqiReady ? 1 : BarTheme.dim
    }
}
