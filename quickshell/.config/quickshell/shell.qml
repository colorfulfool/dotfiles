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
            exclusiveZone: 40
            implicitWidth: 1000
            implicitHeight: pill.implicitHeight + 28
            mask: Region {
                item: pill.pillItem
            }
            BackgroundEffect.blurRegion: Region {
                item: pill.pillItem
                shape: RegionShape.Rect
                radius: 8
            }

            Pill {
                id: pill
                anchors.horizontalCenter: parent.horizontalCenter
                // Shift the natural-width pill so the notch gap lands on screen center
                anchors.horizontalCenterOffset: (rightGroup.implicitWidth - leftGroup.implicitWidth) / 2
                anchors.top: parent.top
                anchors.topMargin: 0
                spacing: 0

                RowLayout {
                    id: leftGroup
                    spacing: 20

                    WorkspaceModule {
                        screen: modelData
                    }
                    TrayModule {
                    }
                    CpuModule {
                    }
                    MemoryModule {
                    }
                }

                // Empty space inside the pill for the MacBook notch
                Item {
                    implicitWidth: 210
                    implicitHeight: 1
                }

                RowLayout {
                    id: rightGroup
                    spacing: 20

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
}
