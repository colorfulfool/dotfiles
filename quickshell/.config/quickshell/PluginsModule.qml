import QtQuick
import "plugins"

// Standalone plugin strip, styled like TrayModule (spacing 4, dimmed).
Row {
    id: pluginsRow
    spacing: 4
    opacity: 0.7

    TailscalePlugin {
    }

    SleepGuardPlugin {
    }
}
