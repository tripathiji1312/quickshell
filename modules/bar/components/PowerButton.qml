import QtQuick 6.10
import Quickshell
import qs.services

Item {
    id: root
    
    implicitWidth: 32
    implicitHeight: 32
    
    // Background circle
    Rectangle {
        id: buttonBg
        anchors.centerIn: parent
        width: 28
        height: 28
        radius: 14
        
        color: {
            if (mouseArea.pressed) return Qt.alpha(Pywal.colors.color1, 0.3)
            if (mouseArea.containsMouse) return Qt.alpha(Pywal.colors.color1, 0.2)
            return Qt.alpha(Pywal.colors.color1, 0.12)
        }
        
        border.width: 1
        border.color: Qt.alpha(Pywal.colors.color1, mouseArea.containsMouse ? 0.4 : 0.2)
        
        scale: mouseArea.pressed ? 0.92 : (mouseArea.containsMouse ? 1.05 : 1.0)
        
        Behavior on color {
            ColorAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }
        
        Behavior on border.color {
            ColorAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }
        
        Behavior on scale {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutBack
                easing.overshoot: 1.1
            }
        }
    }
    
    // Power icon
    Text {
        anchors.centerIn: parent
        text: "⏻"
        color: Pywal.colors.color1
        font.pixelSize: 16
        font.bold: true
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            console.log("Power button clicked - executing shutdown")
            // Execute shutdown command
            Quickshell.execDetached(["systemctl", "poweroff"])
        }
    }
}
