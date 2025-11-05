pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Centralized logging service with debug mode control
Singleton {
    id: root
    
    // Enable via environment variable: QS_DEBUG=1
    readonly property bool debugMode: {
        const envDebug = Quickshell.env("QS_DEBUG")
        return envDebug === "1" || envDebug === "true"
    }
    
    // Log levels (using lowercase to comply with QML naming rules)
    readonly property int levelTrace: 0
    readonly property int levelDebug: 1
    readonly property int levelInfo: 2
    readonly property int levelWarn: 3
    readonly property int levelError: 4
    
    property int minLevel: debugMode ? levelDebug : levelInfo
    
    Component.onCompleted: {
        if (debugMode) {
            console.log("🔍 [Logger] Debug mode enabled (QS_DEBUG=1)")
        }
    }
    
    function trace(component, msg) {
        if (levelTrace >= minLevel) {
            console.log(`[TRACE][${component}]`, msg)
        }
    }
    
    function debug(component, msg) {
        if (levelDebug >= minLevel) {
            console.log(`[DEBUG][${component}]`, msg)
        }
    }
    
    function info(component, msg) {
        if (levelInfo >= minLevel) {
            console.log(`[INFO][${component}]`, msg)
        }
    }
    
    function warn(component, msg) {
        if (levelWarn >= minLevel) {
            console.warn(`[WARN][${component}]`, msg)
        }
    }
    
    function error(component, msg, details) {
        if (levelError >= minLevel) {
            if (details !== undefined) {
                console.error(`[ERROR][${component}]`, msg, details)
            } else {
                console.error(`[ERROR][${component}]`, msg)
            }
        }
    }
    
    // Performance timing helpers
    property var timers: ({})
    
    function timeStart(label) {
        timers[label] = new Date().getTime()
    }
    
    function timeEnd(label) {
        if (timers[label]) {
            const elapsed = new Date().getTime() - timers[label]
            debug("Performance", `${label}: ${elapsed}ms`)
            delete timers[label]
        }
    }
}
