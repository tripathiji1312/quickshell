import Quickshell
import Quickshell.Services.UPower
import QtQuick
import Quickshell.Io

Scope {
    id: root

    property list<var> warnLevels: [
        { level: 20, title: "Battery low", message: "Plug in soon", icon: "battery_alert", warned: false },
        { level: 10, title: "Battery very low", message: "Save your work", icon: "battery_alert", warned: false },
        { level: 5, title: "Battery critical", message: "Plug in now", icon: "battery_alert", warned: false }
    ]

    property int criticalLevel: 2
    property int criticalActionDelayMs: 5000
    property string criticalAction: "hibernate" // hibernate|poweroff|none

    function _resetWarned(): void {
        for (let i = 0; i < warnLevels.length; i++)
            warnLevels[i].warned = false
    }

    function _notify(title: string, body: string): void {
        // Use notify-send if present; otherwise just log.
        notifyProc.exec(["notify-send", title, body])
    }

    Process {
        id: notifyProc
    }

    Connections {
        target: UPower

        function onOnBatteryChanged(): void {
            if (!UPower.onBattery)
                root._resetWarned()
        }
    }

    Connections {
        target: UPower.displayDevice

        function onPercentageChanged(): void {
            if (!UPower.onBattery)
                return

            const p = Math.round(UPower.displayDevice.percentage * 100)

            // warn levels
            const sorted = [...warnLevels].sort((a, b) => b.level - a.level)
            for (let i = 0; i < sorted.length; i++) {
                const lvl = sorted[i]
                if (p <= lvl.level && !lvl.warned) {
                    lvl.warned = true
                    root._notify(lvl.title, `${lvl.message} (${p}%)`)
                }
            }

            if (!criticalTimer.running && p <= criticalLevel && criticalAction !== "none") {
                root._notify("Battery critical", `Running ${criticalAction} in ${Math.round(criticalActionDelayMs / 1000)}s (${p}%)`)
                criticalTimer.start()
            }
        }
    }

    Timer {
        id: criticalTimer
        interval: root.criticalActionDelayMs

        onTriggered: {
            if (root.criticalAction === "hibernate")
                Quickshell.execDetached(["systemctl", "hibernate"])
            else if (root.criticalAction === "poweroff")
                Quickshell.execDetached(["systemctl", "poweroff"])
        }
    }
}
