pragma Singleton

import QtQuick 6.10
import Quickshell
import Quickshell.Io
import "." as QsServices

// Quick Settings Persistence Service
Singleton {
    id: root
    
    property bool dndEnabled: false
    property bool caffeineEnabled: false
    property bool focusModeEnabled: false
    property int focusModeMinutesLeft: 0
    
    readonly property string configPath: `${Quickshell.env("HOME")}/.config/quickshell/settings.json`
    
    property bool _loading: true
    property string _pendingJson: ""
    
    Timer {
        id: saveTimer
        interval: 500
        repeat: false
        onTriggered: doSaveSettings()
    }
    
    Component.onCompleted: {
        loadSettings()
    }
    
    function loadSettings() {
        loadProc.running = true
    }
    
    Process {
        id: loadProc
        command: ["cat", root.configPath]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const settings = JSON.parse(text)
                    root.dndEnabled = settings.dndEnabled ?? false
                    root.caffeineEnabled = settings.caffeineEnabled ?? false
                    root.focusModeEnabled = settings.focusModeEnabled ?? false
                    root.focusModeMinutesLeft = settings.focusModeMinutesLeft ?? 0
                } catch(e) {
                    QsServices.Logger.warn("Settings", `Failed to load: ${e?.message ?? e}`)
                }
                root._loading = false
            }
        }
    }
    
    function saveSettings() {
        if (_loading) return
        saveTimer.restart()
    }
    
    function doSaveSettings() {
        const settings = {
            dndEnabled: root.dndEnabled,
            caffeineEnabled: root.caffeineEnabled,
            focusModeEnabled: root.focusModeEnabled,
            focusModeMinutesLeft: root.focusModeMinutesLeft
        }
        
        const json = JSON.stringify(settings, null, 2)
        const parts = root.configPath.split("/")
        const dir = parts.slice(0, -1).join("/")
        const tmpPath = root.configPath + ".tmp"
        
        writeProc.exec(["sh", "-c",
            "mkdir -p \"$1\" && printf '%s' \"$2\" > \"$3\" && mv \"$3\" \"$4\"",
            "sh", dir, json, tmpPath, root.configPath
        ])
    }
    
    Process {
        id: writeProc
    }
    
    onDndEnabledChanged: saveSettings()
    onCaffeineEnabledChanged: saveSettings()
    onFocusModeEnabledChanged: saveSettings()
    onFocusModeMinutesLeftChanged: saveSettings()
}
