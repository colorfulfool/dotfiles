pragma Singleton
import QtQuick

QtObject {
    property var execCalls: []
    property var screens: []

    function execDetached(args) {
        execCalls.push(args)
    }
}
