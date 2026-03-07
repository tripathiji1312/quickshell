pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import "." as QsServices

Singleton {
    id: root
    
    property bool inhibited: false
    property int inhibitorPid: -1
    
    onInhibitedChanged: {
        QsServices.Logger.debug("IdleInhibitor", `Inhibited changed: ${inhibited}`)
        if (inhibited) {
            enableInhibitor()
        } else {
            disableInhibitor()
        }
    }
    
    function enableInhibitor() {
        QsServices.Logger.info("IdleInhibitor", "Enabling")
        enableProcess.running = true
    }
    
    function disableInhibitor() {
        QsServices.Logger.info("IdleInhibitor", "Disabling")
        disableProcess.running = true
    }
    
    // Enable idle inhibitor using systemd-inhibit
    Process {
        id: enableProcess
        command: ["/bin/sh", "-c", "systemd-inhibit --what=idle --who=QuickShell --why='Caffeine mode enabled' sleep infinity & echo $!"]
        running: false
        
        stdout: SplitParser {
            onRead: data => {
                const pid = parseInt(data.trim())
                if (!isNaN(pid) && pid > 0) {
                    root.inhibitorPid = pid
                    QsServices.Logger.debug("IdleInhibitor", `Started PID=${pid}`)
                }
            }
        }
    }
    
    // Disable idle inhibitor
    Process {
        id: disableProcess
        command: ["/bin/sh", "-c", root.inhibitorPid > 0 ? 
                  `kill ${root.inhibitorPid} 2>/dev/null || pkill -f 'systemd-inhibit.*QuickShell'` :
                  "pkill -f 'systemd-inhibit.*QuickShell'"]
        running: false
        
        onExited: {
            root.inhibitorPid = -1
            QsServices.Logger.debug("IdleInhibitor", "Stopped")
        }
    }
    
    Component.onCompleted: {
        QsServices.Logger.debug("IdleInhibitor", "Service loaded")
    }
}
