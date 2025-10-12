pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

Singleton {
    id: root
    
    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource
    
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property int percentage: Math.round(volume * 100)
    
    readonly property bool sourceMuted: source?.audio?.muted ?? false
    readonly property real sourceVolume: source?.audio?.volume ?? 0
    readonly property int sourcePercentage: Math.round(sourceVolume * 100)
    
    function setVolume(newVolume) {
        if (sink?.audio) {
            sink.audio.muted = false
            sink.audio.volume = Math.max(0, Math.min(1.5, newVolume))
        }
    }
    
    function toggleMute() {
        if (sink?.audio) {
            sink.audio.muted = !sink.audio.muted
        }
    }
    
    function increaseVolume() {
        setVolume(volume + 0.05)
    }
    
    function decreaseVolume() {
        setVolume(volume - 0.05)
    }
    
    function setSourceVolume(newVolume) {
        if (source?.audio) {
            source.audio.muted = false
            source.audio.volume = Math.max(0, Math.min(1.5, newVolume))
        }
    }
    
    function toggleSourceMute() {
        if (source?.audio) {
            source.audio.muted = !source.audio.muted
        }
    }
}
