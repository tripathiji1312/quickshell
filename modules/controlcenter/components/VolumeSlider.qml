import QtQuick 6.10
import QtQuick.Layouts 6.10
import QtQuick.Controls 6.10
import Quickshell
import "../../../components/effects"
import "../../../services" as QsServices

Rectangle {
    id: root
    
    required property var audio
    property var pywal
    
    // Current volume value - use PipeWire audio service
    readonly property int currentVolume: audio.percentage
    readonly property bool isMuted: audio.muted
    
    // Solid color tokens
    readonly property color surfaceColor: pywal ? Qt.lighter(pywal.background, 1.25) : "#2a2a3a"
    readonly property color textColor: pywal ? pywal.foreground : "#e6e6e6"
    readonly property color accentColor: pywal ? pywal.primary : "#a6e3a1"
    
    Layout.fillWidth: true
    Layout.preferredHeight: 48
    
    radius: 24
    color: surfaceColor
    
    Behavior on color {
        ColorAnimation {
            duration: Material3Anim.medium2
            easing.bezierCurve: Material3Anim.standard
        }
    }
    
    RowLayout {
        anchors.fill: parent
        spacing: 0
        
        // Mute Button
        Rectangle {
            id: muteBtn
            Layout.preferredWidth: 48
            Layout.fillHeight: true
            radius: 24
            color: muteMouse.containsMouse 
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
                text: root.isMuted ? "󰝟" : (root.currentVolume > 66 ? "󰕾" : (root.currentVolume > 33 ? "󰖀" : "󰕿"))
                font.family: "Material Design Icons"
                font.pixelSize: 20
                color: root.isMuted ? root.accentColor : root.textColor
                
                Behavior on color {
                    ColorAnimation {
                        duration: Material3Anim.short3
                        easing.bezierCurve: Material3Anim.standard
                    }
                }
            }
            
            MouseArea {
                id: muteMouse
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: root.audio.toggleMute()
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
            value: root.currentVolume
            live: false
            
            onMoved: root.audio.setVolume(value / 100)
            
            background: Rectangle {
                x: slider.leftPadding
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                implicitWidth: 200
                implicitHeight: 48
                width: slider.availableWidth
                height: implicitHeight
                radius: 24
                color: "transparent"
                
                // Progress fill
                Rectangle {
                    width: slider.visualPosition * parent.width
                    height: parent.height
                    radius: 24
                    color: root.accentColor
                    opacity: 0.2
                    
                    Behavior on width {
                        NumberAnimation {
                            duration: Material3Anim.short2
                            easing.bezierCurve: Material3Anim.standard
                        }
                    }
                }
            }
            
            handle: Rectangle {
                visible: false
            }
        }
        
        // Percentage Text
        Text {
            Layout.rightMargin: 16
            Layout.preferredWidth: 40
            text: root.currentVolume + "%"
            font.family: "Inter"
            font.pixelSize: 13
            font.weight: Font.DemiBold
            color: root.textColor
            horizontalAlignment: Text.AlignRight
        }
    }
}
