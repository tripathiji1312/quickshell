import QtQuick 6.10
import QtQuick.Layouts 6.10
import Quickshell

Rectangle {
    id: root
    
    required property var systemUsage
    property var pywal
    
    Layout.fillWidth: true
    Layout.preferredHeight: 100
    
    radius: 24
    color: Qt.rgba(1, 1, 1, 0.05)
    border.color: Qt.rgba(1, 1, 1, 0.1)
    border.width: 1
    
    RowLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16
        
        // CPU
        StatCircle {
            icon: ""
            label: "CPU"
            value: (root.systemUsage.cpuPerc ?? 0) * 100
            color: root.pywal.color1 ?? "#f38ba8"
        }
        
        // RAM
        StatCircle {
            icon: ""
            label: "RAM"
            value: (root.systemUsage.memPerc ?? 0) * 100
            color: root.pywal.color2 ?? "#fab387"
        }
        
        // Disk
        StatCircle {
            icon: "󰋊"
            label: "Disk"
            value: (root.systemUsage.diskPerc ?? 0) * 100
            color: root.pywal.color3 ?? "#f9e2af"
        }
        
        // GPU (if available)
        StatCircle {
            visible: root.systemUsage.hasGpu
            icon: "󰢮"
            label: "GPU"
            value: root.systemUsage.gpuUsage ?? 0
            color: root.pywal.color4 ?? "#a6e3a1"
        }
    }
    
    component StatCircle: ColumnLayout {
        property string icon
        property string label
        property real value
        property color color
        
        Layout.fillWidth: true
        spacing: 8
        
        Box {
            Layout.alignment: Qt.AlignHCenter
            width: 50
            height: 50
            
            // Background track
            Rectangle {
                anchors.fill: parent
                radius: 25
                color: Qt.rgba(1, 1, 1, 0.1)
            }
            
            // Progress Arc (Simplified as a clip rect for now, or use a Shader/Canvas if needed for true arc)
            // Using a simple height-based fill for robustness without complex canvas logic
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                height: parent.height * (value / 100)
                radius: 25
                color: parent.parent.color
                opacity: 0.3
            }
            
            Text {
                anchors.centerIn: parent
                text: parent.parent.icon
                font.family: "Material Design Icons"
                font.pixelSize: 20
                color: "#e6e6e6"
            }
        }
        
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: Math.round(parent.value) + "%"
            font.family: "Inter"
            font.pixelSize: 12
            font.weight: Font.Bold
            color: "#e6e6e6"
        }
        
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: parent.label
            font.family: "Inter"
            font.pixelSize: 10
            color: Qt.rgba(1, 1, 1, 0.5)
        }
    }
    
    // Helper Box
    component Box: Item {}
}
