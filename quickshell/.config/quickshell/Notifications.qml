import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications

Scope {
    id: root

    readonly property int maxVisible: 4
    readonly property int cardWidth: 376
    readonly property int enterDuration: 260
    readonly property int leaveDuration: 200
    readonly property int slideDistance: cardWidth + 16

    property var liveRefs: ({})
    property var delegates: ({})
    property int nextGen: 0

    ListModel { id: popupModel }

    NotificationServer {
        id: server

        keepOnReload: false
        bodySupported: true
        bodyMarkupSupported: false
        actionsSupported: false
        imageSupported: true

        onNotification: function(notification) {
            root.add(notification)
        }
    }

    function add(notification) {
        if (!notification) return

        notification.tracked = true

        root.nextGen += 1
        const gen = root.nextGen
        root.liveRefs[gen] = notification

        notification.closed.connect(function() {
            if (root.liveRefs[gen] === notification) delete root.liveRefs[gen]
            root.closeRow(gen)
        })

        popupModel.insert(0, {
            gen: gen,
            appName: notification.appName || "",
            appIcon: notification.appIcon || "",
            image: notification.image || "",
            summary: notification.summary || "",
            body: notification.body || "",
            urgency: notification.urgency
        })

        while (popupModel.count > root.maxVisible)
            root.dropRow(popupModel.count - 1)
    }

    function removeRow(gen) {
        for (let i = popupModel.count - 1; i >= 0; --i) {
            if (popupModel.get(i).gen === gen) popupModel.remove(i)
        }
    }

    function dropRow(index) {
        if (index < 0 || index >= popupModel.count) return

        const gen = popupModel.get(index).gen
        const ref = root.liveRefs[gen]
        popupModel.remove(index)
        if (!ref) return

        delete root.liveRefs[gen]
        try {
            ref.dismiss()
        } catch (e) {
        }
    }

    function dismiss(gen) {
        const ref = root.liveRefs[gen]
        if (ref) {
            delete root.liveRefs[gen]
            try {
                ref.dismiss()
            } catch (e) {
            }
        }
        root.closeRow(gen)
    }

    function registerDelegate(gen, item) {
        if (!root.delegates[gen]) root.delegates[gen] = []
        root.delegates[gen].push(item)
    }

    function unregisterDelegate(gen, item) {
        const list = root.delegates[gen]
        if (!list) return
        const index = list.indexOf(item)
        if (index >= 0) list.splice(index, 1)
        if (list.length === 0) delete root.delegates[gen]
    }

    function closeRow(gen) {
        const list = root.delegates[gen]
        if (!list || list.length === 0) {
            root.finalizeRow(gen)
            return
        }

        for (const item of list) {
            if (item && typeof item.requestClose === "function") item.requestClose()
        }
    }

    function finalizeRow(gen) {
        root.removeRow(gen)
        delete root.liveRefs[gen]
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData
            visible: popupModel.count > 0

            WlrLayershell.namespace: "notifications"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            mask: Region {
                item: popupColumn
            }

            Column {
                id: popupColumn
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: 12
                anchors.rightMargin: 12
                width: root.cardWidth
                spacing: 8

                Repeater {
                    model: popupModel

                    delegate: Item {
                        id: cardSlot

                        required property int index
                        required property int gen
                        required property string appName
                        required property string appIcon
                        required property string image
                        required property string summary
                        required property string body
                        required property int urgency

                        property bool closing: false
                        property real progress: 0

                        width: popupColumn.width
                        height: closing ? card.height * progress : card.height

                        function requestClose() {
                            if (closing) return
                            closing = true
                            closeAnim.restart()
                        }

                        NotificationCard {
                            id: card
                            width: parent.width
                            x: (1 - cardSlot.progress) * root.slideDistance
                            opacity: cardSlot.progress
                            appName: cardSlot.appName
                            appIcon: cardSlot.appIcon
                            image: cardSlot.image
                            summary: cardSlot.summary
                            body: cardSlot.body
                            urgency: cardSlot.urgency
                            onDismissRequested: root.dismiss(cardSlot.gen)
                        }

                        NumberAnimation {
                            id: enterAnim
                            target: cardSlot
                            property: "progress"
                            from: 0
                            to: 1
                            duration: root.enterDuration
                            easing.type: Easing.OutCubic
                        }

                        Timer {
                            id: expireTimer
                            interval: 5000
                            running: !cardSlot.closing && !card.hovered
                            onTriggered: root.dismiss(cardSlot.gen)
                        }

                        NumberAnimation {
                            id: closeAnim
                            target: cardSlot
                            property: "progress"
                            from: 1
                            to: 0
                            duration: root.leaveDuration
                            easing.type: Easing.InCubic
                            onFinished: root.finalizeRow(cardSlot.gen)
                        }

                        Component.onCompleted: {
                            root.registerDelegate(cardSlot.gen, cardSlot)
                            enterAnim.start()
                        }
                        Component.onDestruction: root.unregisterDelegate(cardSlot.gen, cardSlot)
                    }
                }
            }
        }
    }
}
