//@ pragma Env XDG_CONFIG_HOME = /home/colorfulfool/.config/qs-env
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

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
                top: 0
            }
            color: "transparent"
            exclusionMode: ExclusionMode.Normal
            exclusiveZone: BarTheme.barHeight + BarTheme.barMarginTop
            implicitWidth: 1000
            implicitHeight: pill.implicitHeight + 28
            mask: Region {
                item: pill.pillItem
            }
            BackgroundEffect.blurRegion: Region {
                item: pill.pillItem
                shape: RegionShape.Rect
                radius: 16
            }

            Pill {
                id: pill
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: BarTheme.barMarginTop

                WorkspaceModule {
                    screen: modelData
                }
                TrayModule {
                }
                CpuModule {
                }
                MemoryModule {
                }

                RowLayout {
                    spacing: 8

                    NetworkModule {
                    }
                    BluetoothModule {
                    }
                    AudioModule {
                    }
                }

                BatteryModule {
                }
            }
        }
    }
}
