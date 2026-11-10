import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root

    readonly property real temperature: WeatherState.temperature
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

    // Material Design weather glyphs (Nerd Font md-weather_*): uniform 24px grid,
    // so every condition renders at the same visual size.
    function conditionIcon(code, day) {
        switch (code) {
        case 0:
            return String.fromCodePoint(day ? 0xF0599 : 0xF0594); // sunny / night
        case 1:
        case 2:
            return String.fromCodePoint(day ? 0xF0595 : 0xF0F31); // partly cloudy
        case 3:
            return String.fromCodePoint(0xF0590); // cloudy
        case 45:
        case 48:
            return String.fromCodePoint(0xF0591); // fog
        case 51:
        case 53:
        case 55:
        case 61:
        case 63:
        case 80:
        case 81:
            return String.fromCodePoint(0xF0597); // rainy
        case 65:
        case 82:
            return String.fromCodePoint(0xF0596); // pouring
        case 56:
        case 57:
        case 66:
        case 67:
            return String.fromCodePoint(0xF067F); // freezing rain / sleet
        case 71:
        case 73:
        case 77:
        case 85:
            return String.fromCodePoint(0xF0598); // snowy
        case 75:
        case 86:
            return String.fromCodePoint(0xF0F36); // heavy snow
        case 95:
        case 96:
        case 99:
            return String.fromCodePoint(0xF067E); // thunderstorm
        default:
            return String.fromCodePoint(0xF0590); // cloudy
        }
    }

    RowLayout {
        Layout.alignment: Qt.AlignVCenter
        spacing: 2

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
