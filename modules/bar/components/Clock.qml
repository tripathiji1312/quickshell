import QtQuick 6.10
import QtQuick.Layouts 6.10
import qs.services

Item {
    id: root
    
    implicitWidth: clockRow.implicitWidth
    implicitHeight: clockRow.implicitHeight
    
    Row {
        id: clockRow
        anchors.centerIn: parent
        spacing: 12
        
        // Time display with background
        Rectangle {
            width: timeText.width + 16
            height: timeText.height + 8
            radius: 6
            color: Qt.alpha(Pywal.colors.color1, 0.15)
            anchors.verticalCenter: parent.verticalCenter
            
            Text {
                id: timeText
                anchors.centerIn: parent
                
                text: Time.format("hh:mm")
                color: Pywal.foreground
                font.pixelSize: 14
                font.weight: Font.DemiBold
                font.family: "monospace"
            }
        }
        
        // Date display
        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0
            
            Text {
                text: Time.format("ddd")
                color: Pywal.colors.color1
                font.pixelSize: 11
                font.weight: Font.Medium
                opacity: 0.8
            }
            
            Text {
                text: Time.format("MMM d")
                color: Pywal.foreground
                font.pixelSize: 10
                opacity: 0.5
            }
        }
    }
}
