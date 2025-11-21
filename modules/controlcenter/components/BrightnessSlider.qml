import QtQuick 6.10
import QtQuick.Layouts 6.10
import QtQuick.Controls 6.10
import Quickshell

Rectangle {
    id: root
    
    required property var brightness
    property var pywal
    
    Layout.fillWidth: true
    Layout.preferredHeight: 48
    
    radius: 24
    color: Qt.rgba(1, 1, 1, 0.1)
    
    RowLayout {
        anchors.fill: parent
        spacing: 0
        
        // Icon
        Rectangle {
            Layout.preferredWidth: 48
            Layout.fillHeight: true
            radius: 24
            color: "transparent"
            
            Text {
                anchors.centerIn: parent
                text: "󰃠"
                font.family: "Material Design Icons"
                font.pixelSize: 20
                color: "#e6e6e6"
            }
        }
        
        // Slider
        Slider {
            id: slider
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.rightMargin: 16
            
            from: 0
            to: 100
            value: root.brightness.percentage
            
            onMoved: root.brightness.setBrightness(value / 100)
            
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
                visible: false
            }
        }
        
        // Percentage Text
        Text {
            Layout.rightMargin: 20
            text: Math.round(root.brightness.percentage) + "%"
            font.family: "Inter"
            font.pixelSize: 13
            font.weight: Font.Medium
            color: "#e6e6e6"
        }
    }
}
