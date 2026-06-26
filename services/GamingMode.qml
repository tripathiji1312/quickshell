pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import "." as QsServices

Singleton {
    id: root
    
    property bool enabled: false
    property bool dndEnabled: false
    property real previousBrightness: 0.5
    property bool didSetBrightness: false
    
    // Performance settings
    readonly property string performanceGovernor: "performance"
    readonly property string balancedGovernor: "schedutil"
    
    onEnabledChanged: {
        QsServices.Logger.info("GamingMode", `Gaming mode ${enabled ? "ENABLED" : "DISABLED"}`)
        
        if (enabled) {
            // Save current DND state
            dndEnabled = notifs.dnd
            didSetBrightness = false
            
            // Enable performance mode
            setCpuGovernor(performanceGovernor)
            
            // Enable DND
            notifs.dnd = true
            
            // Boost brightness (optional - can be customized)
            if (brightness.brightness < 0.8) {
                previousBrightness = brightness.brightness
                brightness.setBrightness(1.0)
                didSetBrightness = true
            }
        } else {
            // Restore balanced mode
            setCpuGovernor(balancedGovernor)
            
            // Restore DND only if user hasn't manually changed it
            if (notifs.dnd === true)
                notifs.dnd = dndEnabled
            
            // Restore brightness only if gaming mode set it
            if (didSetBrightness)
                brightness.setBrightness(previousBrightness)
        }
    }
    
    function toggle() {
        enabled = !enabled
    }
    
    readonly property var validGovernors: ["performance", "schedutil", "powersave", "ondemand", "conservative", "userspace"]
    
    function setCpuGovernor(governor) {
        if (!validGovernors.includes(governor)) {
            QsServices.Logger.warn("GamingMode", `Invalid CPU governor: ${governor}`)
            return
        }
        QsServices.Logger.info("GamingMode", `Setting CPU governor to: ${governor}`)
        cpuGovernorProc.exec([
            "sh", "-c",
            "printf '%s' \"$1\" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor",
            "sh", governor
        ])
    }
    
    // Process to set CPU governor (requires passwordless sudo for cpufreq)
    Process {
        id: cpuGovernorProc
        
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0)
                    QsServices.Logger.debug("GamingMode", `CPU governor output: ${text.trim()}`)
            }
        }
        
        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0) {
                    QsServices.Logger.warn("GamingMode", `CPU governor error: ${text.trim()}`)
                    QsServices.Logger.info("GamingMode", "Tip: add passwordless tee to /etc/sudoers.d/cpufreq if desired")
                }
            }
        }
    }
    
    // Check current CPU governor on startup
    Component.onCompleted: {
        checkGovernorProc.running = true
    }
    
    Process {
        id: checkGovernorProc
        command: ["cat", "/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor"]
        running: false
        
        stdout: StdioCollector {
            onStreamFinished: {
                const currentGovernor = text.trim()
                QsServices.Logger.debug("GamingMode", `Current CPU governor: ${currentGovernor}`)
                // Auto-detect if gaming mode was already enabled
                if (currentGovernor === performanceGovernor) {
                    enabled = true
                }
            }
        }
    }
    
    // Reference to services (will be set by Control Center)
    readonly property var notifs: QsServices.Notifs
    readonly property var brightness: QsServices.Brightness
}
