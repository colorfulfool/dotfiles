import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

Row {
    Layout.leftMargin: 3
    Layout.rightMargin: 3
    Layout.topMargin: 6
    Layout.bottomMargin: 6
    spacing: 5
    opacity: 0.7

    Repeater {
        model: SystemTray.items

        Item {
            id: trayCell
            required property var modelData
            implicitWidth: 16
            implicitHeight: 16

            IconImage {
                anchors.centerIn: parent
                width: 16
                height: 16
                smooth: true
                mipmap: true
                source: modelData.icon
            }

            QsMenuAnchor {
                id: trayMenu
                menu: trayCell.modelData.menu
                anchor.item: trayCell
                anchor.edges: Edges.Bottom
                anchor.gravity: Edges.Bottom
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: mouse => {
                    if (mouse.button === Qt.LeftButton) {
                        modelData.activate();
                    } else if (modelData.hasMenu) {
                        if (trayMenu.visible)
                            trayMenu.close();
                        else
                            trayMenu.open();
                    } else {
                        modelData.secondaryActivate();
                    }
                }
            }
        }
    }
}
