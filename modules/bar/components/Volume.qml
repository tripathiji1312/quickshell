import QtQuick 6.10
import QtQuick.Layouts 6.10
import Quickshell
import "../../../services" as QsServices
import "../../../components/effects"

// Volume indicator with number - no popup
Item {
    id: root
    
    property var barWindow
    property var volumePopup  // Kept for compatibility but not used
    
    readonly property var pywal: QsServices.Pywal
    readonly property var audio: QsServices.Audio
    readonly property bool isHovered: mouseArea.containsMouse
    readonly property bool isMuted: audio.muted
    readonly property int percentage: audio.percentage
    
    implicitWidth: volumeRow.implicitWidth
    implicitHeight: 20
    
    RowLayout {
        id: volumeRow
        anchors.centerIn: parent
        spacing: 3
        
        // Volume icon
        Text {
            id: volumeIcon
            
            text: {
                if (isMuted) return "󰖁"
                if (percentage >= 70) return "󰕾"
                if (percentage >= 30) return "󰖀"
                return "󰕿"
            }
            
            font.family: "Material Design Icons"
            font.pixelSize: 14
            
            color: {
                if (isMuted) return Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.35)
                if (isHovered) return pywal.primary
                return pywal.foreground
            }
            
            Behavior on color {
                ColorAnimation { duration: 150 }
            }
            
            scale: isHovered ? 1.05 : 1.0
            Behavior on scale {
                NumberAnimation { duration: 100 }
            }
        }
        
        // Percentage number with animated transitions
        Text {
            id: volumeText
            
            text: percentage
            font.family: "Inter"
            font.pixelSize: 10
            font.weight: Font.Medium
            
            color: {
                if (isMuted) return Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.35)
                return Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.7)
            }
            
            Behavior on color {
                ColorAnimation { duration: 150 }
            }
            
            // Number change animation
            Behavior on text {
                SequentialAnimation {
                    NumberAnimation {
                        target: volumeText
                        property: "scale"
                        to: 1.15
                        duration: 80
                    }
                    NumberAnimation {
                        target: volumeText
                        property: "scale"
                        to: 1.0
                        duration: 100
                    }
                }
            }
        }
    }
    
    // Interaction area
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        anchors.margins: -4
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onWheel: wheel => {
            if (wheel.angleDelta.y > 0) {
                audio.increaseVolume()
            } else {
                audio.decreaseVolume()
            }
        }
        
        onClicked: audio.toggleMute()
    }
    
    // Volume change pulse
    Connections {
        target: audio
        function onPercentageChanged() {
            pulseAnim.restart()
        }
    }
    
    SequentialAnimation {
        id: pulseAnim
        
        NumberAnimation {
            target: volumeIcon
            property: "scale"
            to: 1.2
            duration: 80
        }
        NumberAnimation {
            target: volumeIcon
            property: "scale"
            to: isHovered ? 1.05 : 1.0
            duration: 120
        }
    }
}
