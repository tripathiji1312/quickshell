import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import "../../services" as QsServices

PanelWindow {
    id: root
    
    required property var pywal
    property bool showing: false
    property int currentBrightness: 50
    
    visible: showing
    
    anchors {
        top: true
        right: true
    }
    
    margins {
        top: 120  // Below volume OSD
        right: 15
    }
    
    implicitWidth: 280
    implicitHeight: 90
    color: "transparent"
    
    mask: Region { item: container }
    
    Region {
        id: inputRgn
        item: showing ? container : null
    }
    
    // Auto-hide timer
    Timer {
        id: hideTimer
        interval: 2000
        onTriggered: root.showing = false
    }
    
    // Poll /tmp/brightness_osd file for changes
    Timer {
        id: pollTimer
        interval: 50  // Fast polling - 50ms (same as volume)
        repeat: true
        running: true
        
        onTriggered: {
            brightnessReadProc.running = true
        }
    }
    
    Process {
        id: brightnessReadProc
        command: ["cat", "/tmp/brightness_osd"]
        
        stdout: StdioCollector {
            onStreamFinished: {
                const bright = parseInt(text.trim()) || 50
                if (bright !== root.currentBrightness) {
                    console.log("💡 [BrightnessOSD] Brightness changed:", root.currentBrightness, "→", bright, "%")
                    root.currentBrightness = bright
                    root.show()
                }
            }
        }
    }
    
    function show() {
        showing = true
        hideTimer.restart()
    }
    
    Component.onCompleted: {
        console.log("💡 [BrightnessOSD] Component loaded - polling /tmp/brightness_osd every 50ms")
    }
    
    Rectangle {
        id: container
        anchors.fill: parent
        radius: 20
        
        // Glassmorphic background
        color: Qt.rgba(pywal.background.r, pywal.background.g, pywal.background.b, 0.85)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.15)
        
        opacity: root.showing ? 1.0 : 0.0
        scale: root.showing ? 1.0 : 0.85
        
        Behavior on opacity {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }
        
        Behavior on scale {
            NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
        }
        
        // Backdrop blur effect
        layer.enabled: true
        layer.effect: MultiEffect {
            blurEnabled: true
            blur: 0.05
            saturation: 0.1
        }
        
        // Gradient overlay
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            opacity: 0.05
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.1) }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 8
            
            // Header with icon and title
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                
                // Animated icon circle
                Rectangle {
                    Layout.preferredWidth: 48
                    Layout.preferredHeight: 48
                    radius: 24
                    color: Qt.rgba(pywal.color3.r, pywal.color3.g, pywal.color3.b, 0.2)
                    border.width: 2
                    border.color: pywal.color3
                    
                    Text {
                        anchors.centerIn: parent
                        text: {
                            if (currentBrightness > 66) return "󰃠"
                            if (currentBrightness > 33) return "󰃟"
                            return "󰃞"
                        }
                        font.family: "Material Design Icons"
                        font.pixelSize: 26
                        color: pywal.color3
                    }
                }
                
                // Title
                Text {
                    text: "Brightness"
                    font.family: "Inter"
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    color: pywal.foreground
                    Layout.fillWidth: true
                }
                
                // Percentage
                Text {
                    text: currentBrightness + "%"
                    font.family: "JetBrains Mono"
                    font.pixelSize: 22
                    font.weight: Font.Bold
                    color: pywal.color3
                }
            }
            
            // Progress bar
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 8
                
                // Background track
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: 6
                    radius: 3
                    color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.1)
                }
                
                // Progress fill
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width * (currentBrightness / 100)
                    height: 6
                    radius: 3
                    color: pywal.color3
                    
                    Behavior on width {
                        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                    }
                    
                    // Glow effect on progress
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowColor: pywal.color3
                        shadowBlur: 0.8
                        shadowOpacity: 0.5
                    }
                }
                
                // Progress indicator circle
                Rectangle {
                    x: parent.width * (currentBrightness / 100) - width / 2
                    anchors.verticalCenter: parent.verticalCenter
                    width: 14
                    height: 14
                    radius: 7
                    color: pywal.color3
                    border.width: 2
                    border.color: pywal.background
                    
                    Behavior on x {
                        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                    }
                }
            }
        }
    }
}
