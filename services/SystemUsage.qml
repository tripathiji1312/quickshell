pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    
    property real cpuPerc: 0
    property real memUsed: 0
    property real memTotal: 1
    readonly property real memPerc: memTotal > 0 ? memUsed / memTotal : 0
    property real diskUsed: 0
    property real diskTotal: 1
    readonly property real diskPerc: diskTotal > 0 ? diskUsed / diskTotal : 0
    
    property real lastCpuIdle: 0
    property real lastCpuTotal: 0
    
    Component.onCompleted: {
        updateTimer.start()
        updateCpu()
        updateMemory()
        updateDisk()
    }
    
    function updateCpu() {
        cpuProcess.running = true
    }
    
    function updateMemory() {
        memProcess.running = true
    }
    
    function updateDisk() {
        diskProcess.running = true
    }
    
    function formatBytes(bytes) {
        const gb = bytes / (1024 ** 3)
        if (gb >= 1) return { value: gb, unit: "GB" }
        const mb = bytes / (1024 ** 2)
        if (mb >= 1) return { value: mb, unit: "MB" }
        const kb = bytes / 1024
        return { value: kb, unit: "KB" }
    }
    
    // CPU usage calculation
    Process {
        id: cpuProcess
        command: ["/bin/sh", "-c", "cat /proc/stat | grep '^cpu '"]
        running: false
        
        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split(/\s+/)
                if (parts.length >= 5) {
                    const user = parseInt(parts[1])
                    const nice = parseInt(parts[2])
                    const system = parseInt(parts[3])
                    const idle = parseInt(parts[4])
                    const total = user + nice + system + idle
                    
                    if (lastCpuTotal > 0) {
                        const totalDiff = total - lastCpuTotal
                        const idleDiff = idle - lastCpuIdle
                        if (totalDiff > 0) {
                            cpuPerc = 1 - (idleDiff / totalDiff)
                        }
                    }
                    
                    lastCpuIdle = idle
                    lastCpuTotal = total
                }
            }
        }
    }
    
    // Memory usage
    Process {
        id: memProcess
        command: ["/bin/sh", "-c", "free -b | grep Mem"]
        running: false
        
        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split(/\s+/)
                if (parts.length >= 3) {
                    memTotal = parseInt(parts[1])
                    memUsed = parseInt(parts[2])
                }
            }
        }
    }
    
    // Disk usage
    Process {
        id: diskProcess
        command: ["/bin/sh", "-c", "df -B1 / | tail -1"]
        running: false
        
        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split(/\s+/)
                if (parts.length >= 3) {
                    diskTotal = parseInt(parts[1])
                    diskUsed = parseInt(parts[2])
                }
            }
        }
    }
    
    // Update timer
    Timer {
        id: updateTimer
        interval: 2000
        repeat: true
        onTriggered: {
            updateCpu()
            updateMemory()
            updateDisk()
        }
    }
}
