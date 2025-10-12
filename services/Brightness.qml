pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root
    
    property real brightness: 0.5
    property real maxBrightness: 1.0
    readonly property int percentage: Math.round(brightness * 100)
    
    // AMD backlight path (common locations)
    readonly property string backlightPath: "/sys/class/backlight/amdgpu_bl0/brightness"
    readonly property string maxBrightnessPath: "/sys/class/backlight/amdgpu_bl0/max_brightness"
    
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
        const rawValue = Math.round(newValue * maxValue)
        
        // Use brightnessctl or ddcutil for AMD
        const cmd = "brightnessctl set " + Math.round(newValue * 100) + "%"
        setBrightnessProcess.command = ["/bin/sh", "-c", cmd]
        setBrightnessProcess.running = true
        
        brightness = newValue
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
    
    // Set brightness
    Process {
        id: setBrightnessProcess
        running: false
    }
    
    // Update timer
    Timer {
        id: updateTimer
        interval: 1000
        repeat: true
        onTriggered: readBrightness()
    }
}
