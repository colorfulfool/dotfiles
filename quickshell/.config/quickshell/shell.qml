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
            implicitWidth: pill.implicitWidth + 28
            implicitHeight: pill.implicitHeight + 28
            BackgroundEffect.blurRegion: Region {
                item: pill
                shape: RegionShape.Rect
                radius: 16
            }

            Item {
                anchors.fill: parent

                RectangularShadow {
                    anchors.fill: pill
                    offset: Qt.vector2d(0, 2)
                    color: Qt.rgba(0, 0, 0, 0.55)
                    blur: 12
                    spread: 0
                    radius: 32
                }

                Rectangle {
                    id: pill
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 8
                    implicitWidth: barRow.implicitWidth + 48
                    implicitHeight: 42
                    color: BarTheme.pill
                    radius: 32
                    clip: true
                    Behavior on implicitWidth {
                        NumberAnimation {
                            duration: BarTheme.pillResizeDuration
                            easing.type: BarTheme.pillResizeEasing
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
}
