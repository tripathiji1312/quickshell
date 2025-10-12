pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    
    property bool inhibited: false
    
    function toggle() {
        if (inhibited) {
            disable()
        } else {
            enable()
        }
    }
    
    function enable() {
        inhibited = true
        enableProcess.running = true
    }
    
    function disable() {
        inhibited = false
        disableProcess.running = true
    }
    
    // Enable idle inhibitor using systemd-inhibit
    Process {
        id: enableProcess
        command: ["/bin/sh", "-c", "systemd-inhibit --what=idle --who=QuickShell --why='User requested' sleep infinity &"]
        running: false
    }
    
    // Disable by killing the inhibit process
    Process {
        id: disableProcess
        command: ["/bin/sh", "-c", "pkill -f 'systemd-inhibit.*QuickShell'"]
        running: false
    }
}
