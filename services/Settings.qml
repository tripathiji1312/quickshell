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
            }
        }
    }
    
    function saveSettings() {
        const settings = {
            dndEnabled: root.dndEnabled,
            caffeineEnabled: root.caffeineEnabled,
            focusModeEnabled: root.focusModeEnabled,
            focusModeMinutesLeft: root.focusModeMinutesLeft
        }
        
        const json = JSON.stringify(settings, null, 2)
        saveProc.exec(["sh", "-c", `mkdir -p ~/.config/quickshell && echo '${json}' > ${root.configPath}`])
    }
    
    Process {
        id: saveProc
    }
    
    onDndEnabledChanged: saveSettings()
    onCaffeineEnabledChanged: saveSettings()
    onFocusModeEnabledChanged: saveSettings()
    onFocusModeMinutesLeftChanged: saveSettings()
}
