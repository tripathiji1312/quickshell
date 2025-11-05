pragma Singleton

import Quickshell
import Quickshell.Services.Mpris
import QtQuick 6.10

Singleton {
    id: root

    readonly property var list: Mpris.players.values
    
    // Active player should be the currently playing one, or first in list if none playing
    property var active: {
        // Find the first playing player
        for (var i = 0; i < list.length; i++) {
            if (list[i]?.isPlaying) {
                return list[i]
            }
        }
        // If no player is playing, return the first one
        return list[0] ?? null
    }
    
    // Watch for changes in player states and update active player - optimized
    Timer {
        interval: 1000  // Reduced from 500ms to 1000ms (media state doesn't change that often)
        running: true
        repeat: true
        triggeredOnStart: true  // Get immediate first read
        onTriggered: {
            var newActive = null
            // Find the first playing player
            for (var i = 0; i < list.length; i++) {
                if (list[i]?.isPlaying) {
                    newActive = list[i]
                    break
                }
            }
            // If no player is playing, use first one
            if (!newActive && list.length > 0) {
                newActive = list[0]
            }
            // Update active if changed
            if (active !== newActive) {
                active = newActive
            }
        }
    }

    function getIdentity(player: var): string {
        return player?.identity ?? "Unknown";
    }
}
