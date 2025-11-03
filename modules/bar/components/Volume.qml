import QtQuick 6.10
import QtQuick.Layouts 6.10
import Quickshell
import "../../../services" as QsServices

Item {
    id: root
    
    property var barWindow
    property var volumePopup
    
    readonly property var pywal: QsServices.Pywal
    readonly property var audio: QsServices.Audio
    readonly property var volumeMonitor: QsServices.VolumeMonitor
    readonly property bool isHovered: mouseArea.containsMouse
    readonly property bool isMuted: volumeMonitor.muted
    readonly property int percentage: volumeMonitor.percentage
    
    implicitWidth: volumeRow.implicitWidth
    implicitHeight: volumeRow.implicitHeight
    
    // Show popup timer
    Timer {
        id: showTimer
        interval: 300
        onTriggered: {
            console.log("Volume timer triggered - barWindow:", barWindow, "popup:", volumePopup)
            if (!barWindow) {
                console.log("ERROR: barWindow is null/undefined")
                return
            }
            if (!barWindow.screen) {
                console.log("ERROR: barWindow.screen is null/undefined")
                return
            }
            if (!volumePopup) {
                console.log("ERROR: volumePopup is null/undefined")
                return
            }
            
            const pos = root.mapToItem(barWindow.contentItem, 0, 0)
            const rightEdge = pos.x + root.width
            const screenWidth = barWindow.screen.width
            volumePopup.margins.right = Math.round(screenWidth - rightEdge)
            volumePopup.margins.top = Math.round(barWindow.height + 6)
            volumePopup.shouldShow = true
            console.log("Volume popup showing at right:", volumePopup.margins.right, "top:", volumePopup.margins.top)
        }
    }
    
    // Hover detection
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        
        onEntered: {
            console.log("Volume hover entered")
            showTimer.start()
        }
        
        onExited: {
            console.log("Volume hover exited")
            showTimer.stop()
        }
        
        onWheel: wheel => {
            if (wheel.angleDelta.y > 0) {
                audio.increaseVolume()
            } else {
                audio.decreaseVolume()
            }
        }
        
        onClicked: {
            audio.toggleMute()
        }
    }
    
    RowLayout {
        id: volumeRow
        anchors.centerIn: parent
        spacing: 6
        
        // Volume icon
        Text {
            id: volumeIcon
            Layout.alignment: Qt.AlignVCenter
            
            text: {
                if (isMuted) return "󰖁"  // muted
                if (percentage >= 70) return "󰕾"  // high
                if (percentage >= 30) return "󰖀"  // medium
                return "󰕿"  // low
            }
            
            font.family: "Material Design Icons"
            font.pixelSize: 16
            
            color: {
                if (isMuted) return Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.4)
                return pywal.foreground
            }
            
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
            
            color: {
                if (isMuted) return Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.4)
                return pywal.foreground
            }
            
            Behavior on color {
                ColorAnimation { duration: 300; easing.type: Easing.OutCubic }
            }
        }
    }
    
    // Pulse animation on volume change
    Connections {
        target: audio
        function onVolumeChanged() {
            volumeIcon.scale = 1.2
            volumeIcon.scale = 1
        }
    }
}
