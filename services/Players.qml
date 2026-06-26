pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import QtQuick 6.10

Singleton {
    id: root

    readonly property var list: Mpris.players.values
    
    // Consumer visibility control - set to false to pause polling when UI is hidden
    property bool visible: true
    
    property var active: null
    
    // React to MPRIS player changes via Connections (event-driven)
    Connections {
        target: Mpris.players
        
        function onValuesChanged() {
            root.updateActivePlayer()
        }
    }
    
    function updateActivePlayer() {
        var newActive = null
        // Find the first playing player
        for (var i = 0; i < list.length; i++) {
            if (list[i]?.isPlaying) {
                newActive = list[i]
                break
            }
        }
        // Update active if changed (null when nothing is playing)
        if (active !== newActive) {
            active = newActive
        }
    }
    
    Component.onCompleted: updateActivePlayer()
    
    // Fallback timer for edge cases (only runs when visible)
    Timer {
        interval: 2000  // Increased from 1000ms since we have event-driven updates
        running: root.visible && list.length > 0
        repeat: true
        triggeredOnStart: true
        onTriggered: root.updateActivePlayer()
    }

    // Playerctl-based control methods (MPRIS D-Bus methods from QuickShell are unreliable)
    function togglePlaying(playerName = "") {
        if (playerName)
            ctrlProc.exec(["playerctl", "--player", playerName, "play-pause"])
        else
            ctrlProc.exec(["playerctl", "play-pause"])
    }

    function next(playerName = "") {
        if (playerName)
            ctrlProc.exec(["playerctl", "--player", playerName, "next"])
        else
            ctrlProc.exec(["playerctl", "next"])
    }

    function previous(playerName = "") {
        if (playerName)
            ctrlProc.exec(["playerctl", "--player", playerName, "previous"])
        else
            ctrlProc.exec(["playerctl", "previous"])
    }

    function stop(playerName = "") {
        if (playerName)
            ctrlProc.exec(["playerctl", "--player", playerName, "stop"])
        else
            ctrlProc.exec(["playerctl", "stop"])
    }

    Process {
        id: ctrlProc
    }

    function setPosition(microseconds, playerName = "") {
        var args = ["playerctl", "position", String(Math.floor(microseconds))]
        if (playerName)
            args = ["playerctl", "--player", playerName, "position", String(Math.floor(microseconds))]
        ctrlProc.exec(args)
    }

    function getIdentity(player: var): string {
        return player?.identity ?? "Unknown";
    }
}
