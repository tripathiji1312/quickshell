import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell.Io
import "../../services" as QsServices
import "../../config" as QsConfig
import "../../components/effects"

PanelWindow {
    id: root
    
    required property var pywal
    property bool showing: false
    
    // Brightness reading
    property int currentBrightness: 50
    property int prevBrightness: -1

    readonly property var brightnessService: QsServices.Brightness
    
    readonly property var appearance: QsConfig.AppearanceConfig
    readonly property var config: QsConfig.Config
    
    visible: showing
    
    // Top-right overlay position, below volume OSD
    anchors {
        top: true
        right: true
    }
    
    margins {
        top: 75
        right: 12
    }
    
    implicitWidth: 286
    implicitHeight: 60
    color: "transparent"
    
    mask: Region { item: container }
    
    Timer {
        id: hideTimer
        interval: config.osd.brightnessTimeoutMs
        onTriggered: root.showing = false
    }
    
    // Fast polling for responsive OSD (100ms when showing, 300ms otherwise)
    // Use Brightness service (portable backlight detection)
    readonly property int pct: brightnessService.percentage

    onPctChanged: {
        if (pct !== root.currentBrightness)
            root.currentBrightness = pct
    }
    
    // Detect changes and show OSD
    onCurrentBrightnessChanged: {
        if (prevBrightness !== -1 && currentBrightness !== prevBrightness) {
            show()
        }
        prevBrightness = currentBrightness
    }
    
    function show() {
        showing = true
        hideTimer.restart()
    }
    
    Rectangle {
        id: container
        anchors.fill: parent
        radius: 22
        color: pywal.surfaceContainerHighest
        border.width: 1
        border.color: pywal.outlineVariant
        
        opacity: root.showing ? 1.0 : 0.0
        scale: root.showing ? 1.0 : 0.94
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
            anchors.margins: 16
            spacing: 14
            
            // Icon - Material Design Icons
            Text {
                text: root.currentBrightness > 66 ? "󰃠" : (root.currentBrightness > 33 ? "󰃟" : "󰃞")
                font.family: "Material Design Icons"
                color: pywal.warning
                font.pixelSize: 22
            }
            
            // Bar
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 10
                radius: 5
                color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.12)
                
                Rectangle {
                    width: parent.width * (root.currentBrightness / 100)
                    height: parent.height
                    radius: 5
                    color: pywal.warning
                    
                    Behavior on width {
                        NumberAnimation { 
                            duration: 100
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                Rectangle {
                    width: 12
                    height: 12
                    radius: 6
                    x: Math.max(0, Math.min(parent.width - width, parent.width * (root.currentBrightness / 100) - width / 2))
                    y: (parent.height - height) / 2
                    color: pywal.warning
                    border.width: 2
                    border.color: pywal.surfaceContainerHighest
                }
            }
            
            // Text
            Text {
                text: root.currentBrightness + "%"
                color: pywal.foreground
                font.family: "Inter"
                font.pixelSize: 14
                font.weight: Font.DemiBold
                Layout.preferredWidth: 42
                horizontalAlignment: Text.AlignRight
            }
        }
    }
}
