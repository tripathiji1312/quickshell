pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

Singleton {
    id: root
    
    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource
    
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property real volume: {
        if (!sink?.audio) {
            return 0
        }
        const vol = sink.audio.volume ?? 0
        // Convert NaN to 0, but log when we get a valid value
        const result = isNaN(vol) ? 0 : vol
        if (!isNaN(vol) && vol > 0) {
            console.log("🔊 [Audio] Got valid volume:", vol, "→", result)
        }
        return result
    }
    readonly property int percentage: Math.round(volume * 100)
    
    readonly property bool sourceMuted: source?.audio?.muted ?? false
    readonly property real sourceVolume: source?.audio?.volume ?? 0
    readonly property int sourcePercentage: Math.round(sourceVolume * 100)
    
    Component.onCompleted: {
        console.log("🔊 [Audio] Service loaded. Sink:", sink, "Volume:", volume, "%:", percentage)
    }
    
    onSinkChanged: {
        console.log("🔊 [Audio] Sink changed to:", sink)
    }
    
    Connections {
        target: sink?.audio
        function onVolumeChanged() {
            console.log("🔊 [Audio] Sink audio volume changed! Raw:", sink?.audio?.volume, "Processed:", volume, "%:", percentage)
        }
    }
    
    onVolumeChanged: {
        if (volume > 0) {
            console.log("🔊 [Audio] Volume property changed to:", volume, "Percentage:", percentage)
        }
    }
    
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
