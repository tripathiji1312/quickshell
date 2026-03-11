import QtQuick 6.10
import QtQuick.Layouts 6.10
import QtQuick.Controls 6.10
import Quickshell
import "../../../components/effects"

Rectangle {
    id: root
    
    required property var brightness
    property var pywal
    
    // Current brightness value
    readonly property int currentBrightness: brightness ? Math.round((brightness.percentage ?? 0)) : 0
    
    // Solid color tokens
    readonly property color surfaceColor: pywal ? pywal.surfaceContainerHighest : "#1a1a1a"
    readonly property color textColor: pywal ? pywal.foreground : "#dddddd"
    readonly property color accentColor: pywal ? pywal.warning : "#cc9966"  // Warm color for brightness
    
    Layout.fillWidth: true
    Layout.preferredHeight: 54
    
    radius: 22
    color: surfaceColor
    border.width: 1
    border.color: pywal ? pywal.outlineVariant : Qt.rgba(1, 1, 1, 0.12)
    
    Behavior on color {
        ColorAnimation {
            duration: Material3Anim.medium2
            easing.bezierCurve: Material3Anim.standard
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0
        
        // Icon
        Rectangle {
            id: iconBtn
            Layout.preferredWidth: 52
            Layout.fillHeight: true
            radius: 20
            color: iconMouse.containsMouse 
                ? Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.1) 
                : "transparent"
            
            Behavior on color {
                ColorAnimation {
                    duration: Material3Anim.short3
                    easing.bezierCurve: Material3Anim.standard
                }
            }
            
            Text {
                anchors.centerIn: parent
                text: root.currentBrightness > 70 ? "󰃠" : (root.currentBrightness > 30 ? "󰃟" : "󰃞")
                font.family: "Material Design Icons"
                font.pixelSize: 20
                color: root.accentColor
            }
            
            MouseArea {
                id: iconMouse
                anchors.fill: parent
                hoverEnabled: true
            }
        }
        
        // Slider
        Slider {
            id: slider
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.rightMargin: 12
            
            from: 0
            to: 100
            value: root.currentBrightness
            live: false
            
            onMoved: root.brightness.setBrightness(value / 100)
            
            background: Rectangle {
                x: slider.leftPadding
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                implicitWidth: 200
                implicitHeight: 30
                width: slider.availableWidth
                height: implicitHeight
                radius: 15
                color: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.08)
                
                // Progress fill
                Rectangle {
                    width: slider.visualPosition * parent.width
                    height: parent.height
                    radius: 15
                    color: root.accentColor
                    opacity: 0.34
                    
                    Behavior on width {
                        NumberAnimation {
                            duration: Material3Anim.short2
                            easing.bezierCurve: Material3Anim.standard
                        }
                    }
                }

                Rectangle {
                    width: 10
                    height: 10
                    radius: 5
                    x: Math.max(0, Math.min(parent.width - width, slider.visualPosition * parent.width - width / 2))
                    y: (parent.height - height) / 2
                    color: root.accentColor
                    border.width: 2
                    border.color: root.surfaceColor
                }
            }
            
            handle: Rectangle {
                visible: false
            }
        }
        
        // Percentage Text
        Text {
            Layout.rightMargin: 16
            Layout.preferredWidth: 44
            text: root.currentBrightness + "%"
            font.family: "Inter"
            font.pixelSize: 13
            font.weight: Font.DemiBold
            color: root.textColor
            horizontalAlignment: Text.AlignRight
        }
    }
}
