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
            implicitHeight: mainPill.implicitHeight + 28
            mask: Region {
                item: mainPill.pillItem
                Region {
                    item: pluginsPill.pillItem
                }
            }
            BackgroundEffect.blurRegion: Region {
                item: mainPill.pillItem
                shape: RegionShape.Rect
                radius: 16
                Region {
                    item: pluginsPill.pillItem
                    shape: RegionShape.Rect
                    radius: 16
                }
            }

            Item {
                id: pillsRow
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: BarTheme.barMarginTop
                width: mainPill.implicitWidth
                height: mainPill.implicitHeight

                Pill {
                    id: mainPill
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter

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

                Pill {
                    id: pluginsPill
                    anchors.left: mainPill.right
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    padding: 14

                    PluginsModule {
                    }
                }
            }
        }
    }
}
