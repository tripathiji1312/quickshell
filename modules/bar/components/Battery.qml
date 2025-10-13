import QtQuick 6.10
import QtQuick.Layouts 6.10
import Quickshell
import Quickshell.Services.UPower
import qs.services

Item {
    id: root
    
    implicitWidth: 70  // Reduced from 85px
    implicitHeight: 28
    
    readonly property var battery: UPower.displayDevice
    readonly property real percentage: battery?.percentage ?? 0
    readonly property int batteryLevel: Math.round(percentage * 100)
    readonly property bool isCharging: battery?.state === UPowerDevice.Charging || battery?.state === UPowerDevice.FullyCharged
    readonly property bool isLow: batteryLevel <= 25 && !isCharging
    readonly property bool isCritical: batteryLevel <= 15 && !isCharging
    
    property bool showPlugAnimation: false
    property bool wasCharging: false
    
    // Minimal color palette
    readonly property color batteryColor: {
        if (isCritical) return "#f38ba8"  // Red critical
        if (isLow) return "#fab387"  // Orange low
        return Pywal.foreground || "#cdd6f4"  // Normal
    }
    
    Component.onCompleted: {
        wasCharging = isCharging
    }
    
    // Watch for charging state changes
    onIsChargingChanged: {
        if (isCharging && !wasCharging) {
            // Just plugged in - show plug animation for 3 seconds
            showPlugAnimation = true
            plugAnimationTimer.restart()
        }
        wasCharging = isCharging
    }
    
    // Timer to hide plug animation after 3 seconds
    Timer {
        id: plugAnimationTimer
        interval: 3000  // Show plug animation for 3 seconds
        onTriggered: {
            showPlugAnimation = false
        }
    }
    
    // PLUG-IN ANIMATION - Green liquid filling pill (3 seconds only)
    Rectangle {
        id: plugAnimationPill
        anchors.fill: parent
        radius: 14
        visible: showPlugAnimation
        opacity: showPlugAnimation ? 1 : 0
        color: "#95a3b3"  // Silver-grey pill base
        
        Behavior on opacity {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }
        
        // Green liquid filling from 0 to current percentage
        Rectangle {
            id: plugLiquidFill
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: 2
            width: 0
            radius: parent.radius - 2
            color: "#a6e3a1"  // Green liquid
            
            // Animate from 0 to current percentage
            NumberAnimation on width {
                running: showPlugAnimation
                from: 0
                to: (plugAnimationPill.width - 4) * root.percentage
                duration: 2000
                easing.type: Easing.OutCubic
            }
            
            // Intense shimmer during plug animation
            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.5; color: Qt.rgba(1, 1, 1, 0.4) }
                    GradientStop { position: 1.0; color: "transparent" }
                }
                
                SequentialAnimation on x {
                    running: showPlugAnimation
                    loops: Animation.Infinite
                    
                    NumberAnimation {
                        from: -parent.width
                        to: parent.width
                        duration: 1000
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }
        
        // Centered power icon and percentage (black)
        RowLayout {
            anchors.centerIn: parent
            spacing: 5
            
            Text {
                text: "󰚥"
                font.family: "Material Design Icons"
                font.pixelSize: 13
                color: "#000000"
                opacity: 0.8
                
                // Pulse effect during plug animation
                SequentialAnimation on scale {
                    running: showPlugAnimation
                    loops: Animation.Infinite
                    
                    NumberAnimation { to: 1.2; duration: 600; easing.type: Easing.OutCubic }
                    NumberAnimation { to: 1.0; duration: 600; easing.type: Easing.InCubic }
                }
            }
            
            Text {
                text: root.batteryLevel + "%"
                color: "#000000"
                font.pixelSize: 11
                font.weight: Font.Bold
                opacity: 0.9
            }
        }
    }
    
    // NORMAL CHARGING ANIMATION - Better continuous animation
    Rectangle {
        id: chargingPill
        anchors.fill: parent
        radius: 14
        visible: isCharging && !showPlugAnimation
        opacity: (isCharging && !showPlugAnimation) ? 1 : 0
        color: "#95a3b3"  // Silver-grey pill base
        
        Behavior on opacity {
            NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
        }
        
        // Green liquid base (current percentage)
        Rectangle {
            id: liquidFill
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: 2
            width: Math.max(0, (parent.width - 4) * root.percentage)
            radius: parent.radius - 2
            color: "#a6e3a1"  // Green liquid
            
            Behavior on width {
                NumberAnimation { 
                    duration: 800
                    easing.type: Easing.OutCubic
                }
            }
            
            // Gentle wave/shimmer effect
            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.5; color: Qt.rgba(1, 1, 1, 0.25) }
                    GradientStop { position: 1.0; color: "transparent" }
                }
                
                SequentialAnimation on x {
                    running: isCharging && !showPlugAnimation
                    loops: Animation.Infinite
                    
                    NumberAnimation {
                        from: -parent.width
                        to: parent.width
                        duration: 2000
                        easing.type: Easing.InOutQuad
                    }
                    PauseAnimation { duration: 500 }
                }
            }
            
            // Breathing glow effect on liquid
            SequentialAnimation on opacity {
                running: isCharging && !showPlugAnimation
                loops: Animation.Infinite
                
                NumberAnimation { to: 1.0; duration: 1500; easing.type: Easing.InOutQuad }
                NumberAnimation { to: 0.75; duration: 1500; easing.type: Easing.InOutQuad }
            }
        }
        
        // Energy particles flowing effect
        Repeater {
            model: 3
            
            Rectangle {
                width: 3
                height: 3
                radius: 1.5
                color: Qt.rgba(1, 1, 1, 0.7)
                x: 0
                y: chargingPill.height / 2 - 1.5
                opacity: 0
                
                SequentialAnimation on x {
                    running: isCharging && !showPlugAnimation
                    loops: Animation.Infinite
                    
                    PauseAnimation { duration: index * 400 }
                    NumberAnimation {
                        from: 4
                        to: chargingPill.width - 4
                        duration: 1800
                        easing.type: Easing.InOutQuad
                    }
                }
                
                SequentialAnimation on opacity {
                    running: isCharging && !showPlugAnimation
                    loops: Animation.Infinite
                    
                    PauseAnimation { duration: index * 400 }
                    NumberAnimation { to: 0.8; duration: 300 }
                    NumberAnimation { to: 0.8; duration: 1200 }
                    NumberAnimation { to: 0.0; duration: 300 }
                }
            }
        }
        
        // Centered power icon and percentage (black)
        RowLayout {
            anchors.centerIn: parent
            spacing: 6
            
            Text {
                text: "󰚥"
                font.family: "Material Design Icons"
                font.pixelSize: 14
                color: "#000000"
                opacity: 0.8
                
                // Subtle pulse
                SequentialAnimation on opacity {
                    running: isCharging && !showPlugAnimation
                    loops: Animation.Infinite
                    
                    NumberAnimation { to: 0.9; duration: 1500; easing.type: Easing.InOutQuad }
                    NumberAnimation { to: 0.6; duration: 1500; easing.type: Easing.InOutQuad }
                }
            }
            
            Text {
                text: root.batteryLevel + "%"
                color: "#000000"
                font.pixelSize: 12
                font.weight: Font.Bold
                opacity: 0.9
            }
        }
    }
    
    // UNPLUGGED DISPLAY - Minimal, no pill (centered in fixed width)
    RowLayout {
        id: batteryRow
        anchors.centerIn: parent
        spacing: 6
        visible: !isCharging
        opacity: !isCharging ? 1 : 0
        
        Behavior on opacity {
            NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
        }
        
        // Minimal battery icon
        Item {
            Layout.preferredWidth: 20
            Layout.preferredHeight: 12
            
            // Main battery body
            Rectangle {
                id: batteryBody
                anchors.fill: parent
                radius: 2
                color: "transparent"
                border.width: 1.5
                border.color: root.batteryColor
                
                Behavior on border.color {
                    ColorAnimation { duration: 300 }
                }
                
                // Battery terminal (small nub)
                Rectangle {
                    anchors.left: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: 2
                    height: 6
                    radius: 1
                    color: root.batteryColor
                    
                    Behavior on color {
                        ColorAnimation { duration: 300 }
                    }
                }
                
                // Battery fill - clips to percentage
                Rectangle {
                    id: batteryFill
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.margins: 2
                    width: Math.max(0, (parent.width - 4) * root.percentage)
                    radius: 1
                    color: root.batteryColor
                    
                    Behavior on width {
                        NumberAnimation { 
                            duration: 400
                            easing.type: Easing.OutCubic
                        }
                    }
                    
                    Behavior on color {
                        ColorAnimation { duration: 300 }
                    }
                }
            }
        }
        
        // Percentage text
        Text {
            text: root.batteryLevel + "%"
            color: root.batteryColor
            font.pixelSize: 11
            font.weight: root.isLow ? Font.DemiBold : Font.Normal
            
            Behavior on color {
                ColorAnimation { duration: 300 }
            }
            
            // Pulse on critical
            SequentialAnimation on opacity {
                running: root.isCritical
                loops: Animation.Infinite
                
                NumberAnimation {
                    to: 1.0
                    duration: 800
                }
                NumberAnimation {
                    to: 0.5
                    duration: 800
                }
            }
        }
    }
}
