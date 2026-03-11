import QtQuick 6.10
import Quickshell
import qs.services
import "../../../components/effects"

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
            if (mouseArea.pressed) return Qt.alpha(Pywal.error, 0.3)
            if (mouseArea.containsMouse) return Qt.alpha(Pywal.error, 0.2)
            return Qt.alpha(Pywal.error, 0.12)
        }
        
        border.width: 0
        border.color: Qt.alpha(Pywal.error, mouseArea.containsMouse ? 0.4 : 0.2)
        
        scale: mouseArea.pressed ? 0.92 : (mouseArea.containsMouse ? 1.05 : 1.0)
        
        Behavior on color {
            ColorAnimation {
                duration: Material3Anim.short3
                easing.type: Easing.OutCubic
            }
        }
        
        Behavior on border.color {
            ColorAnimation {
                duration: Material3Anim.short3
                easing.type: Easing.OutCubic
            }
        }
        
        Behavior on scale {
            NumberAnimation {
                duration: Material3Anim.short3
                easing.type: Easing.OutBack
                easing.overshoot: 1.1
            }
        }
    }
    
    // Power icon
    Text {
        anchors.centerIn: parent
        text: "󰐥"
        font.family: "Material Design Icons"
        color: Pywal.error
        font.pixelSize: 16
        font.bold: true
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            // Execute shutdown command
            Quickshell.execDetached(["systemctl", "poweroff"])
        }
    }
}
