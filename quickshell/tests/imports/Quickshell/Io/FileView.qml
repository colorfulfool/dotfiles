import QtQuick

QtObject {
    property string path: ""
    property bool watchChanges: false
    property bool blockLoading: false
    signal fileChanged()
    function text() { return "" }
    function reload() {}
}
