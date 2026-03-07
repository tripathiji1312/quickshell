pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool ready: false
    property bool muted: false
    property real volume: 0
    readonly property int percentage: Math.round(volume * 100)

    property bool sourceReady: false
    property bool sourceMuted: false
    property real sourceVolume: 0
    readonly property int sourcePercentage: Math.round(sourceVolume * 100)

    Timer {
        interval: 250
        running: true
        repeat: true
        onTriggered: {
            if (!getSink.running)
                getSink.running = true
            if (!getSource.running)
                getSource.running = true
        }
    }

    Process {
        id: getSink
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: StdioCollector {
            onStreamFinished: {
                const s = text.trim()
                // Examples:
                // "Volume: 0.39"
                // "Volume: 0.39 [MUTED]"
                const m = s.match(/Volume:\s*([0-9.]+)/)
                if (m) {
                    const v = parseFloat(m[1])
                    if (!isNaN(v)) {
                        root.ready = true
                        root.volume = Math.max(0, Math.min(1.5, v))
                    }
                }
                root.muted = /\[MUTED\]/.test(s)
            }
        }
    }

    Process {
        id: getSource
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SOURCE@"]
        stdout: StdioCollector {
            onStreamFinished: {
                const s = text.trim()
                const m = s.match(/Volume:\s*([0-9.]+)/)
                if (m) {
                    const v = parseFloat(m[1])
                    if (!isNaN(v)) {
                        root.sourceReady = true
                        root.sourceVolume = Math.max(0, Math.min(1.5, v))
                    }
                }
                root.sourceMuted = /\[MUTED\]/.test(s)
            }
        }
    }

    function setVolume(newVolume) {
        setMute(false)
        setVolProc.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", Math.max(0, Math.min(1.5, newVolume)).toFixed(3)]
        setVolProc.running = true
    }

    function increaseVolume() {
        setVolume(volume + 0.05)
    }

    function decreaseVolume() {
        setVolume(volume - 0.05)
    }

    function setMute(m) {
        setMuteProc.command = ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", m ? "1" : "0"]
        setMuteProc.running = true
    }

    function toggleMute() {
        setMuteProc.command = ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]
        setMuteProc.running = true
    }

    function setSourceVolume(newVolume) {
        setSourceMute(false)
        setSourceVolProc.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SOURCE@", Math.max(0, Math.min(1.5, newVolume)).toFixed(3)]
        setSourceVolProc.running = true
    }

    function setSourceMute(m) {
        setSourceMuteProc.command = ["wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@", m ? "1" : "0"]
        setSourceMuteProc.running = true
    }

    function toggleSourceMute() {
        setSourceMuteProc.command = ["wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@", "toggle"]
        setSourceMuteProc.running = true
    }

    Process { id: setVolProc }
    Process { id: setMuteProc }
    Process { id: setSourceVolProc }
    Process { id: setSourceMuteProc }
}
