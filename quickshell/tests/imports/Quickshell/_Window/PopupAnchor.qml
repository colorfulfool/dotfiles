import QtQuick

Item {
    visible: false
    width: 0
    height: 0
    property Item item: null
    property PopupRect rect: popupRect

    PopupRect {
        id: popupRect
    }
}
