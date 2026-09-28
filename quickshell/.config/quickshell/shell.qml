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
            exclusiveZone: 50
            implicitWidth: 1000
            implicitHeight: Math.max(leftPill.implicitHeight, rightPill.implicitHeight) + 28
            mask: Region {
                item: leftPill.pillItem
                Region {
                    item: rightPill.pillItem
                }
            }
            BackgroundEffect.blurRegion: Region {
                item: leftPill.pillItem
                shape: RegionShape.Rect
                radius: 16
                Region {
                    item: rightPill.pillItem
                    shape: RegionShape.Rect
                    radius: 16
                }
            }

            RowLayout {
                anchors.horizontalCenter: parent.horizontalCenter
                // Shift so the notch gap stays centered even when the pills differ in width
                anchors.horizontalCenterOffset: (rightPill.width - leftPill.width) / 2
                anchors.top: parent.top
                anchors.topMargin: 8
                spacing: 200 // space for the MacBook notch

                Pill {
                    id: leftPill

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

                Pill {
                    id: rightPill

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
