import QtQuick

QtObject {
    property bool active: false
    property var windows: []
    signal cleared()
    function triggerCleared() { cleared() }
}
