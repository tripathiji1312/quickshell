import Quickshell
import Quickshell.Wayland
import Quickshell.Io
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
    property int currentBrightness: 50
    
    readonly property var appearance: QsConfig.AppearanceConfig
    
    visible: showing
    
    // Top-right overlay position, below volume OSD
    anchors {
        top: true
        right: true
    }
    
    margins {
        top: 70
        right: 12
    }
    
    implicitWidth: 250
    implicitHeight: 45
    color: "transparent"
    
    mask: Region { item: container }
    
    Timer {
        id: hideTimer
        interval: 2000
        onTriggered: root.showing = false
    }
    
    Timer {
        id: pollTimer
        interval: 50
        repeat: true
        running: true
        onTriggered: brightnessReadProc.running = true
    }
    
    Process {
        id: brightnessReadProc
        command: ["cat", "/tmp/brightness_osd"]
        stdout: StdioCollector {
            onStreamFinished: {
                const val = parseInt(text.trim()) || 50
                if (val !== root.currentBrightness) {
                    root.currentBrightness = val
                    root.show()
                }
            }
        }
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
            0.85
        )
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.1)
        
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
            
            Text {
                text: "☀️"
                color: pywal.foreground
                font.pixelSize: 16
            }
            
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 4
                radius: 2
                color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.2)
                
                Rectangle {
                    width: parent.width * (root.currentBrightness / 100)
                    height: parent.height
                    radius: 2
                    color: pywal?.primary ?? "#a6e3a1"
                    
                    Behavior on width {
                        NumberAnimation { 
                            duration: Material3Anim.short4
                            easing.bezierCurve: Material3Anim.standardDecelerate
                        }
                    }
                }
            }
            
            Text {
                text: root.currentBrightness + "%"
                color: pywal.foreground
                font.pixelSize: 12
                font.weight: Font.Medium
                Layout.preferredWidth: 30
                horizontalAlignment: Text.AlignRight
            }
        }
    }
}

