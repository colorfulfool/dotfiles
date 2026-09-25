//@ pragma IconTheme breeze-dark
//@ pragma Env XDG_CONFIG_HOME = /home/colorfulfool/.config/qs-env
import Quickshell
import Quickshell.Wayland
import QtQuick
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
            implicitWidth: pill.implicitWidth
            implicitHeight: pill.implicitHeight
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
                id: pill
                anchors.centerIn: parent
                implicitWidth: barRow.implicitWidth + 48
                implicitHeight: 42
                color: BarTheme.pill
                radius: 32
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
