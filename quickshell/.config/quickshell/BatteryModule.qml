import Quickshell
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts

BarText {
    id: battRoot

    // No battery hardware (e.g. desktops/VMs): hide instead of a stuck "--%".
    visible: battRoot.ready
    opacity: BarTheme.dim

    property var dev: UPower.displayDevice
    property bool ready: dev && dev.ready && dev.isLaptopBattery !== false
    property real pct: {
        if (!ready)
            return 0;
        if (dev.energyCapacity > 0)
            return dev.energy / dev.energyCapacity * 100;
        return dev.percentage <= 1 ? dev.percentage * 100 : dev.percentage;
    }
    property int state: ready ? dev.state : UPowerDeviceState.Unknown
    property bool charging: state === UPowerDeviceState.Charging || state === UPowerDeviceState.PendingCharge
    property bool full: state === UPowerDeviceState.FullyCharged
    property bool low: pct <= 20

    text: {
        if (!ready)
            return "--% ";
        const p = Math.round(pct) + "% ";
        const idx = Math.min(9, Math.max(0, Math.floor(pct / 10)));
        if (charging)
            return p + ["󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"][idx];
        if (full)
            return p + "";
        if (!UPower.onBattery)
            return p + "";
        return p + ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"][idx];
    }

    color: {
        if (!ready)
            return BarTheme.fg;
        if (low && !charging)
            return BarTheme.low;
        if (charging)
            return BarTheme.charged;
        return BarTheme.fg;
    }

    SequentialAnimation on color {
        running: battRoot.ready && battRoot.low && !battRoot.charging
        loops: Animation.Infinite
        ColorAnimation {
            to: BarTheme.blinkTo
            duration: 500
        }
        ColorAnimation {
            to: BarTheme.low
            duration: 500
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Quickshell.execDetached(["toggle-better-control", "-B"])
    }
}
