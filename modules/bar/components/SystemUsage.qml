import QtQuick 6.10
import QtQuick.Layouts 6.10
import Quickshell
import "../../../services" as QsServices

Item {
    id: root
    
    readonly property var pywal: QsServices.Pywal
    readonly property var system: QsServices.SystemUsage
    readonly property bool isHovered: mouseArea.containsMouse
    
    implicitWidth: systemRow.implicitWidth
    implicitHeight: systemRow.implicitHeight
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
    }
    
    RowLayout {
        id: systemRow
        anchors.centerIn: parent
        spacing: 12
        
        // CPU
        RowLayout {
            spacing: 4
            
            Text {
                text: "󰘚"
                font.family: "Material Design Icons"
                font.pixelSize: 14
                color: pywal.foreground
                
                Behavior on color {
                    ColorAnimation { duration: 300; easing.type: Easing.OutCubic }
                }
            }
            
            Text {
                text: Math.round(system.cpuPerc * 100) + "%"
                font.family: "Inter"
                font.pixelSize: 11
                font.weight: Font.Medium
                color: pywal.foreground
            }
        }
        
        // Separator
        Rectangle {
            width: 1
            height: 12
            color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.2)
        }
        
        // Memory
        RowLayout {
            spacing: 4
            
            Text {
                text: "󰍛"
                font.family: "Material Design Icons"
                font.pixelSize: 14
                color: pywal.foreground
                
                Behavior on color {
                    ColorAnimation { duration: 300; easing.type: Easing.OutCubic }
                }
            }
            
            Text {
                text: Math.round(system.memPerc * 100) + "%"
                font.family: "Inter"
                font.pixelSize: 11
                font.weight: Font.Medium
                color: pywal.foreground
            }
        }
        
        // Separator
        Rectangle {
            width: 1
            height: 12
            color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.2)
        }
        
        // Disk
        RowLayout {
            spacing: 4
            
            Text {
                text: "󰋊"
                font.family: "Material Design Icons"
                font.pixelSize: 14
                color: pywal.foreground
                
                Behavior on color {
                    ColorAnimation { duration: 300; easing.type: Easing.OutCubic }
                }
            }
            
            Text {
                text: Math.round(system.diskPerc * 100) + "%"
                font.family: "Inter"
                font.pixelSize: 11
                font.weight: Font.Medium
                color: pywal.foreground
            }
        }
    }
}
