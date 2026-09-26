import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

Row {
    id: trayRow
    spacing: 4
    opacity: 0.7

    property var openMenuCell: null

    Repeater {
        model: SystemTray.items

        Item {
            id: trayCell
            required property var modelData
            implicitWidth: 16
            implicitHeight: 16

            property bool menuOpen: false
            property string expandedText: ""

            function subHandle() {
                if (!trayCell.expandedText)
                    return null;
                const kids = menuOpener.children.values;
                for (let i = 0; i < kids.length; ++i)
                    if (kids[i] && kids[i].text === trayCell.expandedText)
                        return kids[i];
                return null;
            }

            function closeMenu() {
                menuOpen = false;
                expandedText = "";
                if (trayRow.openMenuCell === trayCell)
                    trayRow.openMenuCell = null;
            }

            function openMenu() {
                if (trayRow.openMenuCell && trayRow.openMenuCell !== trayCell)
                    trayRow.openMenuCell.closeMenu();
                trayRow.openMenuCell = trayCell;
                menuOpen = true;
            }

            IconImage {
                anchors.centerIn: parent
                width: 16
                height: 16
                smooth: true
                mipmap: true
                source: modelData.icon
            }

            QsMenuOpener {
                id: menuOpener
                menu: trayCell.modelData.menu
            }

            QsMenuOpener {
                id: subOpener
                menu: trayCell.subHandle()
            }

            HyprlandFocusGrab {
                active: trayCell.menuOpen && menuWin.backingWindowVisible
                windows: [menuWin]
                onCleared: trayCell.closeMenu()
            }

            PopupWindow {
                id: menuWin
                visible: trayCell.menuOpen && trayCell.modelData.hasMenu
                anchor.window: trayCell.QsWindow.window
                anchor.item: trayCell
                anchor.rect.x: -menuBg.anchors.margins
                anchor.rect.y: trayCell.height
                color: "transparent"
                implicitWidth: menuLayout.implicitWidth + 48
                implicitHeight: menuLayout.implicitHeight + 44

                RectangularShadow {
                    anchors.fill: menuBg
                    offset: Qt.vector2d(0, 2)
                    color: Qt.rgba(0, 0, 0, 0.55)
                    blur: 12
                    spread: 0
                    radius: 8
                }

                Rectangle {
                    id: menuBg
                    anchors.fill: parent
                    anchors.margins: 14
                    radius: 8
                    color: BarTheme.menu
                    clip: true

                    ColumnLayout {
                        id: menuLayout
                        anchors.fill: menuBg
                        anchors.margins: 8
                        spacing: 0

                        Repeater {
                            model: menuOpener.children.values

                            delegate: Item {
                                required property var modelData
                                property bool expanded: !modelData.isSeparator && modelData.hasChildren && trayCell.expandedText !== "" && trayCell.expandedText === modelData.text
                                Layout.fillWidth: true
                                Layout.preferredHeight: visible ? ((modelData.isSeparator ? 9 : 28) + (expanded ? subLayout.implicitHeight : 0)) : 0
                                visible: modelData.text !== "" || modelData.isSeparator
                                implicitWidth: modelData.isSeparator ? 0 : rowLabel.implicitWidth + 52

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: parent.width
                                    height: 1
                                    visible: modelData.isSeparator
                                    color: BarTheme.separator
                                }

                                Item {
                                    id: rowItem
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.top: parent.top
                                    height: 28
                                    visible: !modelData.isSeparator

                                    Rectangle {
                                        anchors.fill: parent
                                        radius: 4
                                        color: entryMa.containsMouse ? BarTheme.hover : "transparent"
                                    }

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 10
                                        anchors.rightMargin: 10
                                        spacing: 8

                                        BarText {
                                            id: rowLabel
                                            Layout.fillWidth: true
                                            verticalAlignment: Text.AlignVCenter
                                            text: {
                                                let t = modelData.text || "";
                                                if (modelData.buttonType !== QsMenuButtonType.None)
                                                    t = (modelData.checkState !== Qt.Unchecked ? "✓ " : "    ") + t;
                                                return t;
                                            }
                                            color: modelData.enabled ? BarTheme.fg : BarTheme.subdued
                                            elide: Text.ElideRight
                                        }

                                        BarText {
                                            visible: modelData.hasChildren
                                            text: trayCell.expandedText !== "" && trayCell.expandedText === modelData.text ? "⌄" : ">"
                                            color: BarTheme.subdued
                                        }
                                    }

                                    MouseArea {
                                        id: entryMa
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: modelData.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                        onEntered: {
                                            if (!modelData.isSeparator)
                                                trayCell.expandedText = modelData.hasChildren ? modelData.text : "";
                                        }
                                        onClicked: {
                                            if (!modelData.enabled)
                                                return;
                                            if (modelData.hasChildren) {
                                                trayCell.expandedText = modelData.text;
                                            } else {
                                                modelData.triggered();
                                                trayCell.closeMenu();
                                            }
                                        }
                                    }
                                }

                                ColumnLayout {
                                    id: subLayout
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.top: rowItem.bottom
                                    visible: trayCell.expandedText !== "" && trayCell.expandedText === modelData.text && !modelData.isSeparator
                                    spacing: 0

                                    Repeater {
                                        model: subOpener.children.values

                                        delegate: Item {
                                            required property var modelData
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: modelData.isSeparator ? 9 : 28
                                            visible: modelData.text !== "" || modelData.isSeparator
                                            implicitWidth: modelData.isSeparator ? 0 : subLabel.implicitWidth + 44

                                            Rectangle {
                                                anchors.centerIn: parent
                                                width: parent.width
                                                height: 1
                                                visible: modelData.isSeparator
                                                color: BarTheme.separator
                                            }

                                            Item {
                                                anchors.left: parent.left
                                                anchors.right: parent.right
                                                anchors.top: parent.top
                                                anchors.leftMargin: 12
                                                height: 28
                                                visible: !modelData.isSeparator

                                                Rectangle {
                                                    anchors.fill: parent
                                                    radius: 4
                                                    color: subMa.containsMouse ? BarTheme.hover : "transparent"
                                                }

                                                BarText {
                                                    id: subLabel
                                                    anchors.fill: parent
                                                    anchors.leftMargin: 10
                                                    anchors.rightMargin: 10
                                                    verticalAlignment: Text.AlignVCenter
                                                    text: modelData.text || ""
                                                    color: modelData.enabled ? BarTheme.fg : BarTheme.subdued
                                                    elide: Text.ElideRight
                                                }

                                                MouseArea {
                                                    id: subMa
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: modelData.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                                    onClicked: {
                                                        if (!modelData.enabled)
                                                            return;
                                                        modelData.triggered();
                                                        trayCell.closeMenu();
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: mouse => {
                    if (mouse.button === Qt.LeftButton) {
                        modelData.activate();
                    } else if (modelData.hasMenu) {
                        if (trayCell.menuOpen)
                            trayCell.closeMenu();
                        else
                            trayCell.openMenu();
                    } else {
                        modelData.secondaryActivate();
                    }
                }
            }
        }
    }
}
