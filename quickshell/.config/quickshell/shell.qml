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
            implicitWidth: pill.implicitWidth + 28
            implicitHeight: pill.implicitHeight + 28
            BackgroundEffect.blurRegion: Region {
                item: pill
                shape: RegionShape.Rect
                radius: 16
            }

            Rectangle {
                anchors.centerIn: parent
                implicitWidth: barRow.implicitWidth + 12 + 16
                implicitHeight: barRow.implicitHeight
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
