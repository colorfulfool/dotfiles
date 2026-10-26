import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Shapes

Row {
    id: trayRow
    spacing: 4
    opacity: 0.7

    // Empty tray must not reserve a layout slot (and its 20px bar spacing).
    visible: SystemTray.items.values.length > 0

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
            // Row whose submenu is currently open. The submenu is rendered
            // in its own popup to the right so it never covers the entries
            // below the trigger.
            property Item expandedRow: null
            // Dropbox only ships a dark glyph plus a tiny state emblem that
            // washes out at 16px, so pin its readable base glyph in light mode.
            // (Vendored copy: dropbox auto-updates change its versioned image path.)
            readonly property bool isDropbox: ((trayCell.modelData.id || "") + " " + (trayCell.modelData.title || "")).toLowerCase().indexOf("dropbox") !== -1

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
                expandedRow = null;
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
                source: trayCell.isDropbox && BarTheme.isLight ? Qt.resolvedUrl("icons/dropbox-idle-dark.png") : modelData.icon
            }

            QsMenuOpener {
                id: menuOpener
                menu: trayCell.modelData.menu
            }

            QsMenuOpener {
                id: subOpener
                menu: trayCell.subHandle()
            }

            PopupWindow {
                id: menuWin
                visible: trayCell.menuOpen && trayCell.modelData.hasMenu
                anchor.item: trayCell
                anchor.rect.x: 0 - (menuBg.anchors.margins + trayCell.width/2)
                // Pill is 42 high (shell.qml) with the 16px icon centered.
                // Popup top is placed so the visible menuBg sits 4px below
                // the pill bottom (the 14px transparent margin is shadow
                // bleed, not gap).
                anchor.rect.y: trayCell.height + (42 - trayCell.height) / 2 - menuBg.anchors.margins - 1
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
                    bottomLeftRadius: 8
                    bottomRightRadius: 8
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
                                Layout.fillWidth: true
                                Layout.preferredHeight: visible ? (modelData.isSeparator ? 9 : 28) : 0
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

                                        Shape {
                                            visible: modelData.hasChildren
                                            Layout.preferredWidth: 5
                                            Layout.preferredHeight: 8
                                            Layout.alignment: Qt.AlignVCenter
                                            antialiasing: true

                                            ShapePath {
                                                fillColor: BarTheme.subdued
                                                strokeColor: "transparent"
                                                startX: 0
                                                startY: 0
                                                PathLine {
                                                    x: 5
                                                    y: 4
                                                }
                                                PathLine {
                                                    x: 0
                                                    y: 8
                                                }
                                                PathLine {
                                                    x: 0
                                                    y: 0
                                                }
                                            }
                                        }
                                    }

                                    MouseArea {
                                        id: entryMa
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: modelData.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                        onEntered: {
                                            if (!modelData.isSeparator) {
                                                trayCell.expandedText = modelData.hasChildren ? modelData.text : "";
                                                trayCell.expandedRow = modelData.hasChildren ? rowItem : null;
                                            }
                                        }
                                        onClicked: {
                                            if (!modelData.enabled)
                                                return;
                                            if (modelData.hasChildren) {
                                                trayCell.expandedText = modelData.text;
                                                trayCell.expandedRow = rowItem;
                                            } else {
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

            PopupWindow {
                id: subWin
                objectName: "submenuWin"
                visible: trayCell.menuOpen && trayCell.expandedRow !== null && trayCell.expandedText !== ""
                anchor.item: trayCell.expandedRow
                // Leave a small 2px gap from the parent menu background and
                // offset the popup up by its layout margin (8) so the first
                // submenu text lines up with the trigger row's text. Row
                // width + layout margin (8) + gap (2) - shadow margin (14)
                // positions the window itself.
                anchor.rect.x: trayCell.expandedRow ? trayCell.expandedRow.width + 8 + 2 - 14 : 0
                anchor.rect.y: -14 - 8
                color: "transparent"
                implicitWidth: subMenuLayout.implicitWidth + 48
                implicitHeight: subMenuLayout.implicitHeight + 44

                // Re-anchor when switching directly from one submenu trigger
                // to another while the popup is already visible.
                Connections {
                    target: subWin.anchor
                    function onItemChanged() {
                        subWin.anchor.updateAnchor();
                    }
                }

                RectangularShadow {
                    anchors.fill: subMenuBg
                    offset: Qt.vector2d(0, 2)
                    color: Qt.rgba(0, 0, 0, 0.55)
                    blur: 12
                    spread: 0
                    radius: 8
                }

                Rectangle {
                    id: subMenuBg
                    anchors.fill: parent
                    anchors.margins: 14
                    radius: 8
                    color: BarTheme.menu
                    clip: true

                    ColumnLayout {
                        id: subMenuLayout
                        anchors.fill: subMenuBg
                        anchors.margins: 8
                        spacing: 0

                        Repeater {
                            model: subOpener.children.values

                            delegate: Item {
                                required property var modelData
                                Layout.fillWidth: true
                                Layout.preferredHeight: visible ? (modelData.isSeparator ? 9 : 28) : 0
                                visible: modelData.text !== "" || modelData.isSeparator
                                implicitWidth: modelData.isSeparator ? 0 : subLabel.implicitWidth + 52

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
                                        text: {
                                            let t = modelData.text || "";
                                            if (modelData.buttonType !== QsMenuButtonType.None)
                                                t = (modelData.checkState !== Qt.Unchecked ? "✓ " : "    ") + t;
                                            return t;
                                        }
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

            HyprlandFocusGrab {
                active: trayCell.menuOpen && menuWin.backingWindowVisible
                windows: [menuWin, subWin]
                onCleared: trayCell.closeMenu()
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
