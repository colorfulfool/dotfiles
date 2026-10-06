import QtQuick
import QtQuick.Window

Window {
    id: popupWindow
    property bool backingWindowVisible: true
    property int implicitWidth: 0
    property int implicitHeight: 0
    property PopupAnchor anchor: popupAnchor

    PopupAnchor {
        id: popupAnchor
    }
}
