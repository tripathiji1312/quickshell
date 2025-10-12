import QtQuick 6.10
import QtQuick.Layouts 6.10
import Quickshell
import "../../../services" as QsServices

Item {
    id: root
    
    property var barWindow
    property var brightnessPopup
    
    readonly property var pywal: QsServices.Pywal
    readonly property var brightness: QsServices.Brightness
    readonly property bool isHovered: mouseArea.containsMouse
    readonly property int percentage: brightness.percentage
    
    implicitWidth: brightnessRow.implicitWidth
    implicitHeight: brightnessRow.implicitHeight
    
    // Show popup timer
    Timer {
        id: showTimer
        interval: 300
        onTriggered: {
            if (!barWindow || !barWindow.screen || !brightnessPopup) return
            
            const pos = root.mapToItem(barWindow.contentItem, 0, 0)
            const rightEdge = pos.x + root.width
            const screenWidth = barWindow.screen.width
            brightnessPopup.margins.right = Math.round(screenWidth - rightEdge)
            brightnessPopup.margins.top = Math.round(barWindow.height + 6)
            brightnessPopup.shouldShow = true
        }
    }
    
    // Hover detection
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        
        onEntered: showTimer.start()
        onExited: showTimer.stop()
        
        onWheel: wheel => {
            if (wheel.angleDelta.y > 0) {
                brightness.increaseBrightness()
            } else {
                brightness.decreaseBrightness()
            }
        }
    }
    
    RowLayout {
        id: brightnessRow
        anchors.centerIn: parent
        spacing: 6
        
        // Brightness icon
        Text {
            id: brightnessIcon
            Layout.alignment: Qt.AlignVCenter
            
            text: {
                if (percentage >= 75) return "󰃠"  // high
                if (percentage >= 50) return "󰃟"  // medium
                if (percentage >= 25) return "󰃞"  // low
                return "󰃝"  // very low
            }
            
            font.family: "Material Design Icons"
            font.pixelSize: 16
            color: pywal.foreground
            
            Behavior on color {
                ColorAnimation { duration: 300; easing.type: Easing.OutCubic }
            }
            
            scale: 1
            Behavior on scale {
                NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
            }
        }
        
        // Percentage text
        Text {
            id: percentageText
            Layout.alignment: Qt.AlignVCenter
            
            text: percentage + "%"
            font.family: "Inter"
            font.pixelSize: 12
            font.weight: Font.Medium
            color: pywal.foreground
            
            Behavior on color {
                ColorAnimation { duration: 300; easing.type: Easing.OutCubic }
            }
        }
    }
    
    // Pulse animation on brightness change
    Connections {
        target: brightness
        function onBrightnessChanged() {
            brightnessIcon.scale = 1.2
            brightnessIcon.scale = 1
        }
    }
}
