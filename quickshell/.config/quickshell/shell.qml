import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            anchors {
                top: true
            }
            margins {
                top: 8
            }
            color: "transparent"
            implicitWidth: barRow.implicitWidth + 12 + 16 + 28
            implicitHeight: pill.implicitHeight + 28
            Behavior on implicitWidth {
                NumberAnimation {
                    duration: BarTheme.pillAnimDuration
                    easing.type: Easing.OutCubic
                }
            }
            BackgroundEffect.blurRegion: Region {
                item: pill
                shape: RegionShape.Rect
                radius: 16
            }

            Rectangle {
                id: pillBlur
                anchors.centerIn: parent
                implicitWidth: barRow.implicitWidth + 12 + 16
                implicitHeight: barRow.implicitHeight
                Behavior on implicitWidth {
                    NumberAnimation {
                        duration: BarTheme.pillAnimDuration
                        easing.type: Easing.OutCubic
                    }
                }
                radius: 16
                color: "#28000000"
                layer.enabled: true
                layer.effect: MultiEffect {
                    blurEnabled: true
                    blur: 0.7
                    blurMax: 12
                }
            }

            Rectangle {
                id: pill
                anchors.centerIn: parent
                implicitWidth: barRow.implicitWidth + 12 + 16
                implicitHeight: barRow.implicitHeight
                color: BarTheme.pill
                radius: 16
                clip: true
                Behavior on implicitWidth {
                    NumberAnimation {
                        duration: BarTheme.pillAnimDuration
                        easing.type: Easing.OutCubic
                    }
                }

                RowLayout {
                    id: barRow
                    anchors.centerIn: parent
                    spacing: 6

                    WorkspaceModule {
                        screen: modelData
                    }
                    TrayModule {
                    }
                    CpuModule {
                    }
                    MemoryModule {
                    }
                    NetworkModule {
                    }
                    BluetoothModule {
                    }
                    AudioModule {
                    }
                    BatteryModule {
                    }
                }
            }
        }
    }
}
