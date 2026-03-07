import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import "../../services" as QsServices
import "../../config" as QsConfig
import "../../components/effects"

PanelWindow {
    id: root
    
    required property var pywal
    property bool showing: false
    
    readonly property var audio: QsServices.Audio
    property int currentVolume: 0
    property bool currentMuted: false
    
    // Track previous values to detect actual changes
    property int prevVolume: -1
    property bool prevMuted: false
    
    readonly property var appearance: QsConfig.AppearanceConfig
    readonly property var config: QsConfig.Config
    
    visible: showing
    
    // Top-right overlay position
    anchors {
        top: true
        right: true
    }
    
    margins {
        top: 20
        right: 12
    }
    
    implicitWidth: 250
    implicitHeight: 45
    color: "transparent"
    
    mask: Region { item: container }
    
    // Auto-hide timer
    Timer {
        id: hideTimer
        interval: config.osd.volumeTimeoutMs
        onTriggered: root.showing = false
    }
    
    // Watch for volume changes using onChanged handlers
    Connections {
        target: audio

        function onPercentageChanged() {
            root.currentVolume = audio.percentage
            if (prevVolume !== -1 && root.currentVolume !== prevVolume)
                root.show()
            prevVolume = root.currentVolume
        }

        function onMutedChanged() {
            root.currentMuted = audio.muted
            if (root.currentMuted !== prevMuted)
                root.show()
            prevMuted = root.currentMuted
        }
    }

    // If the backend doesn't emit notify signals reliably, poll and show on change.
    Timer {
        interval: 150
        running: true
        repeat: true
        onTriggered: {
            const v = audio.percentage
            const m = audio.muted

            root.currentVolume = v
            root.currentMuted = m

            if (prevVolume !== -1 && v !== prevVolume)
                root.show()
            if (m !== prevMuted)
                root.show()

            prevVolume = v
            prevMuted = m
        }
    }

    Component.onCompleted: {
        root.currentVolume = audio.percentage
        root.currentMuted = audio.muted
        prevVolume = root.currentVolume
        prevMuted = root.currentMuted
    }
    
    function show() {
        showing = true
        hideTimer.restart()
    }
    
    Rectangle {
        id: container
        anchors.fill: parent
        radius: 16
        
        color: Qt.rgba(
            pywal?.background?.r ?? 0.1, 
            pywal?.background?.g ?? 0.1, 
            pywal?.background?.b ?? 0.1, 
            0.95
        )
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.1)
        
        // Motion Design
        opacity: root.showing ? 1.0 : 0.0
        scale: root.showing ? 1.0 : 0.9
        transformOrigin: Item.Center
        
        Behavior on opacity {
            NumberAnimation { 
                duration: Material3Anim.short4
                easing.bezierCurve: root.showing ? Material3Anim.emphasizedDecelerate : Material3Anim.emphasizedAccelerate
            }
        }
        
        Behavior on scale {
            NumberAnimation { 
                duration: Material3Anim.short4
                easing.bezierCurve: root.showing ? Material3Anim.emphasizedDecelerate : Material3Anim.emphasizedAccelerate
            }
        }
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12
            
            // Icon - Material Design Icons
            Text {
                text: root.currentMuted ? "󰖁" : (root.currentVolume > 66 ? "󰕾" : (root.currentVolume > 33 ? "󰖀" : "󰕿"))
                font.family: "Material Design Icons"
                color: root.currentMuted ? Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.5) : pywal.primary
                font.pixelSize: 20
            }
            
            // Bar
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 6
                radius: 3
                color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.15)
                
                Rectangle {
                    width: parent.width * (root.currentVolume / 100)
                    height: parent.height
                    radius: 3
                    color: root.currentMuted ? Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.4) : pywal.primary
                    
                    Behavior on width {
                        NumberAnimation { 
                            duration: 100
                            easing.type: Easing.OutCubic
                        }
                    }
                    
                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }
                }
            }
            
            // Text
            Text {
                text: root.currentVolume + "%"
                color: pywal.foreground
                font.family: "Inter"
                font.pixelSize: 13
                font.weight: Font.DemiBold
                Layout.preferredWidth: 36
                horizontalAlignment: Text.AlignRight
            }
        }
    }
}
