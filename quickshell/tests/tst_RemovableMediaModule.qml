import QtQuick
import QtTest
import QtQuick.Window
import Quickshell
import "../.config/quickshell"

TestCase {
    name: "RemovableMediaModule"
    width: 400
    height: 200

    Window {
        id: win
        width: 400
        height: 200
        visible: true

        RemovableMediaModule {
            id: media
            width: 400
            height: 60
            devices: [
                { dev: "/dev/sdb1", label: "USBSTICK", mountpoint: "", size: "8G" }
            ]
        }
    }

    function init() {
        Quickshell.execCalls = []
        media.devices = [
            { dev: "/dev/sdb1", label: "USBSTICK", mountpoint: "", size: "8G" }
        ]
        var menu = findByProperty(media, "menuOpen")
        if (menu)
            menu.menuOpen = false
    }

    function visit(o, fn) {
        if (!o)
            return
        fn(o)
        var kids = []
        if (o.children)
            kids = kids.concat(o.children)
        if (o.data)
            kids = kids.concat(o.data)
        if (o.contentItem)
            kids = kids.concat(o.contentItem)
        for (var i = 0; i < kids.length; ++i)
            visit(kids[i], fn)
    }

    function findByProperty(o, prop) {
        var found = null
        visit(o, function(x) {
            if (!found && x[prop] !== undefined)
                found = x
        })
        return found
    }

    function collectMouseAreas() {
        var list = []
        visit(media, function(x) {
            if (x.cursorShape !== undefined && x.acceptedButtons !== undefined)
                list.push(x)
        })
        return list
    }

    function firstMouseArea() {
        var list = collectMouseAreas()
        return list.length > 0 ? list[0] : null
    }

    function test_leftClickEjects() {
        tryVerify(() => firstMouseArea() !== null)
        var ma = firstMouseArea()
        mouseClick(ma, ma.width / 2, ma.height / 2, Qt.LeftButton)
        tryVerify(() => Quickshell.execCalls.length === 1)
        compare(Quickshell.execCalls[0][3], "eject-media")
    }

    function test_rightClickOpensMenu() {
        tryVerify(() => firstMouseArea() !== null)
        var ma = firstMouseArea()
        mouseClick(ma, ma.width / 2, ma.height / 2, Qt.RightButton)
        var menu = findByProperty(media, "menuOpen")
        tryVerify(() => menu.menuOpen === true)
        tryVerify(() => menu.visible === true)
    }

    function test_hoverShowsPointerCursor() {
        tryVerify(() => firstMouseArea() !== null)
        var ma = firstMouseArea()
        compare(ma.hoverEnabled, true)
        compare(ma.cursorShape, Qt.PointingHandCursor)
    }

    function test_outsideClickClosesMenu() {
        tryVerify(() => firstMouseArea() !== null)
        mouseClick(firstMouseArea(), 8, 8, Qt.RightButton)
        var menu = findByProperty(media, "menuOpen")
        tryVerify(() => menu.menuOpen === true)
        var grab = findByProperty(media, "windows")
        tryVerify(() => grab.active === true)
        grab.triggerCleared()
        tryVerify(() => menu.menuOpen === false)
        tryVerify(() => grab.active === false)
    }
}
