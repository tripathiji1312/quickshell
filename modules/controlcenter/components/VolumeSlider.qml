import QtQuick 6.10
import QtQuick.Layouts 6.10
import QtQuick.Controls 6.10
import Quickshell

Rectangle {
    id: root
    
    required property var audio
    property var pywal
    
    Layout.fillWidth: true
    Layout.preferredHeight: 48
    
    radius: 24
    color: Qt.rgba(1, 1, 1, 0.1)
    
    RowLayout {
        anchors.fill: parent
        spacing: 0
        
        // Mute Button
        Rectangle {
            Layout.preferredWidth: 48
            Layout.fillHeight: true
            radius: 24
            color: "transparent"
            
            Text {
                anchors.centerIn: parent
                text: root.audio.muted ? "󰝟" : "󰕾"
                font.family: "Material Design Icons"
                font.pixelSize: 20
                color: "#e6e6e6"
            }
            
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.audio.toggleMute()
            }
        }
        
        // Slider
        Slider {
            id: slider
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.rightMargin: 16
            
            from: 0
            to: 100 // Audio percentage is usually 0-100 or 0-1.5
            value: root.audio.percentage
            
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
                
                // Progress
                Rectangle {
                    width: slider.visualPosition * parent.width
                    height: parent.height
                    radius: 24
                    color: "#e6e6e6"
                    opacity: 0.2
                }
            }
            
            handle: Rectangle {
                // Invisible handle, just use the bar interaction
                visible: false
            }
        }
        
        // Percentage Text
        Text {
            Layout.rightMargin: 20
            text: Math.round(root.audio.percentage) + "%"
            font.family: "Inter"
            font.pixelSize: 13
            font.weight: Font.Medium
            color: "#e6e6e6"
        }
    }
}
