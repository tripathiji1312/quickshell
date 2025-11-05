pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    
    property real brightness: 0.5
    property real maxBrightness: 1.0
    
    // Alias for easier access
    readonly property real level: brightness
    readonly property int percentage: Math.round(brightness * 100)
    
    // Updated backlight path
    readonly property string backlightPath: "/sys/class/backlight/amdgpu_bl1/brightness"
    readonly property string maxBrightnessPath: "/sys/class/backlight/amdgpu_bl1/max_brightness"
    
    property int currentValue: 0
    property int maxValue: 255
    
    Component.onCompleted: {
        readMaxBrightness()
        readBrightness()
        updateTimer.start()
    }
    
    function readMaxBrightness() {
        maxBrightnessProcess.running = true
    }
    
    function readBrightness() {
        brightnessProcess.running = true
    }
    
    function setBrightness(value) {
        // Clamp between 0 and 1
        const newValue = Math.max(0, Math.min(1, value))
        
        // Use brightnessctl for AMD
        const cmd = "brightnessctl set " + Math.round(newValue * 100) + "% && cat " + backlightPath
        setBrightnessProcess.command = ["/bin/sh", "-c", cmd]
        setBrightnessProcess.running = true
        
        // Read brightness will be triggered by the update timer
    }
    
    function increaseBrightness() {
        setBrightness(brightness + 0.05)
    }
    
    function decreaseBrightness() {
        setBrightness(brightness - 0.05)
    }
    
    // Read max brightness
    Process {
        id: maxBrightnessProcess
        command: ["/bin/cat", maxBrightnessPath]
        running: false
        
        stdout: SplitParser {
            onRead: data => {
                const value = parseInt(data.trim())
                if (!isNaN(value) && value > 0) {
                    maxValue = value
                }
            }
        }
    }
    
    // Read current brightness
    Process {
        id: brightnessProcess
        command: ["/bin/cat", backlightPath]
        running: false
        
        stdout: SplitParser {
            onRead: data => {
                const value = parseInt(data.trim())
                if (!isNaN(value)) {
                    currentValue = value
                    brightness = maxValue > 0 ? value / maxValue : 0
                }
            }
        }
    }
    
    // Set brightness process
    Process {
        id: setBrightnessProcess
        running: false
    }
    
    // Update timer - optimized interval
    Timer {
        id: updateTimer
        interval: 2000  // Reduced frequency from 1000ms to 2000ms (brightness changes infrequently)
        repeat: true
        triggeredOnStart: true  // Get immediate first read
        onTriggered: readBrightness()
    }
}
