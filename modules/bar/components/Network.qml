import QtQuick 6.10
import QtQuick.Layouts 6.10
import Quickshell
import "../../../services" as QsServices

Item {
    id: root
    
    property var barWindow
    property var networkPopup
    
    readonly property var pywal: QsServices.Pywal
    readonly property var network: QsServices.Network
    readonly property bool isHovered: mouseArea.containsMouse
    readonly property bool isConnected: network.active !== null
    readonly property string displayName: isConnected ? network.active.ssid : "WiFi"
    readonly property bool isEnabled: network.wifiEnabled
    readonly property int signalStrength: isConnected ? network.active.strength : 0
    
    implicitWidth: networkRow.implicitWidth
    implicitHeight: networkRow.implicitHeight
    
    // Click to toggle popup
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            if (!networkPopup) return
            
            if (networkPopup.shouldShow) {
                networkPopup.shouldShow = false
            } else {
                if (!barWindow || !barWindow.screen) return
                
                const pos = root.mapToItem(barWindow.contentItem, 0, 0)
                const rightEdge = pos.x + root.width
                const screenWidth = barWindow.screen.width
                
                networkPopup.margins.right = Math.round(screenWidth - rightEdge)
                networkPopup.margins.top = Math.round(barWindow.height + 6)
                networkPopup.shouldShow = true
            }
        }
    }
    
    RowLayout {
        id: networkRow
        anchors.centerIn: parent
        spacing: 6
        
        // WiFi icon with signal strength indication
        Text {
            id: wifiIcon
            Layout.alignment: Qt.AlignVCenter
            
            text: {
                if (!isEnabled) return "󰖪"  // wifi off
                if (!isConnected) return "󰖪"  // wifi disconnected
                if (signalStrength >= 75) return "󰤨"  // wifi full
                if (signalStrength >= 50) return "󰤥"  // wifi good
                if (signalStrength >= 25) return "󰤢"  // wifi ok
                return "󰤟"  // wifi weak
            }
            
            font.family: "Material Design Icons"
            font.pixelSize: 16
            
            color: {
                if (!isEnabled) return Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.4)
                if (!isConnected) return Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.6)
                if (signalStrength >= 50) return pywal.color2  // Good signal - green
                if (signalStrength >= 25) return pywal.color3  // Medium signal - orange
                return pywal.color1  // Weak signal - red
            }
            
            Behavior on color {
                ColorAnimation { duration: 300; easing.type: Easing.OutCubic }
            }
            
            // Pulse animation when scanning
            SequentialAnimation on scale {
                running: network.scanning
                loops: Animation.Infinite
                NumberAnimation { to: 1.15; duration: 600; easing.type: Easing.InOutCubic }
                NumberAnimation { to: 1.0; duration: 600; easing.type: Easing.InOutCubic }
            }
        }
        
        // Network name with truncation
        Text {
            id: networkText
            Layout.alignment: Qt.AlignVCenter
            Layout.maximumWidth: 120  // Maximum width to prevent expansion
            
            text: displayName
            font.family: "Inter"
            font.pixelSize: 12
            font.weight: Font.Medium
            
            color: {
                if (!isEnabled) return Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.4)
                if (!isConnected) return Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.6)
                if (isConnected) return pywal.color2  // Connected - green
                return pywal.foreground
            }
            
            elide: Text.ElideRight
            
            Behavior on color {
                ColorAnimation { duration: 300; easing.type: Easing.OutCubic }
            }
        }
        
        // Connection indicator - signal bars
        Row {
            visible: isConnected && isEnabled
            Layout.alignment: Qt.AlignVCenter
            spacing: 1
            
            Repeater {
                model: 4
                
                Rectangle {
                    width: 2
                    height: 3 + (index * 2)
                    radius: 1
                    anchors.bottom: parent.bottom
                    
                    color: {
                        const threshold = (index + 1) * 25
                        if (signalStrength >= threshold) {
                            return pywal.color2
                        }
                        return Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.2)
                    }
                    
                    Behavior on color {
                        ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }
                }
            }
            
            opacity: 0
            scale: 0
            
            Component.onCompleted: {
                opacity = 1
                scale = 1
            }
            
            Behavior on opacity {
                NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
            }
            
            Behavior on scale {
                NumberAnimation { duration: 250; easing.type: Easing.OutBack }
            }
        }
    }
}
