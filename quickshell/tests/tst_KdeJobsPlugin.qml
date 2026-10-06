import QtQuick
import QtTest
import QtQuick.Window
import Quickshell
import "../.config/quickshell"
import "../.config/quickshell/plugins" as Plugins

TestCase {
    name: "KdeJobsPlugin"
    width: 400
    height: 200

    Window {
        id: win
        width: 400
        height: 200
        visible: true

        Plugins.KdeJobsPlugin {
            id: jobs
            width: 16
            height: 16
        }
    }

    function init() {
        Quickshell.execCalls = []
        jobs.jobAddress = ""
        jobs.jobOpen = false
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

    function findByObjectName(o, name) {
        var found = null
        visit(o, function(x) {
            if (!found && x.objectName === name)
                found = x
        })
        return found
    }

    function jobWindow() {
        return findByObjectName(jobs, "jobWin")
    }

    function iconMouseArea() {
        return findByObjectName(jobs, "iconMa")
    }

    function test_jobWindowHiddenByDefault() {
        compare(jobs.jobOpen, false)
        compare(jobs.jobWindowVisible, false)
        var jw = jobWindow()
        tryVerify(() => jw !== null)
        tryVerify(() => jw.visible === false)

        jobs.jobAddress = "0xabc"
        tryVerify(() => jobs.active === true)
        tryVerify(() => jobs.jobWindowVisible === false)
    }

    function test_clickIconTogglesJobWindow() {
        jobs.jobAddress = "0xabc"
        var ma = iconMouseArea()
        tryVerify(() => ma !== null)
        mouseClick(ma)
        tryVerify(() => jobs.jobOpen === true)
        tryVerify(() => jobs.jobWindowVisible === true)
        var jw = jobWindow()
        tryVerify(() => jw.visible === true)

        mouseClick(ma)
        tryVerify(() => jobs.jobOpen === false)
        tryVerify(() => jobs.jobWindowVisible === false)
        tryVerify(() => jw.visible === false)
    }

    function test_jobWindowPlacedNearIcon() {
        jobs.jobAddress = "0xabc"
        var jw = jobWindow()
        var iconCell = findByObjectName(jobs, "iconCell")
        var jobBg = findByObjectName(jobs, "jobBg")
        tryVerify(() => jw !== null && iconCell !== null && jobBg !== null)

        verify(jw.anchor.item === iconCell, "popup anchored to icon")
        var m = jobBg.anchors.margins
        compare(jw.anchor.rect.x, 0 - (m + iconCell.width / 2), "x centered on icon")
        compare(jw.anchor.rect.y, iconCell.height + (42 - iconCell.height) / 2 - m - 1, "y just below the bar")
    }

    function test_iconHoverShowsPointerCursor() {
        var ma = iconMouseArea()
        tryVerify(() => ma !== null)
        compare(ma.hoverEnabled, true)
        compare(ma.cursorShape, Qt.PointingHandCursor)
    }
}
