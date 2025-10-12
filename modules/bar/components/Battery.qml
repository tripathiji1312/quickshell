import QtQuick 6.10
import QtQuick.Layouts 6.10
import Quickshell
import Quickshell.Services.UPower
import qs.services

Item {
    id: root
    
    implicitWidth: 65  // Fixed size
    implicitHeight: 24  // Fixed size
    
    readonly property var battery: UPower.displayDevice
    readonly property real percentage: battery?.percentage ?? 0
    readonly property int batteryLevel: Math.round(percentage * 100)
    readonly property bool isCharging: battery?.state === UPowerDevice.Charging || battery?.state === UPowerDevice.FullyCharged
    readonly property bool isLow: batteryLevel <= 25 && !isCharging
    readonly property bool isCritical: batteryLevel <= 15 && !isCharging
    
    property bool showChargingAnimation: false
    property bool wasCharging: false
    
    // Minimal color palette
    readonly property color batteryColor: {
        if (isCharging) return Pywal.color2 || "#a6e3a1"  // Green when charging
        if (isCritical) return "#f38ba8"  // Red critical
        if (isLow) return "#fab387"  // Orange low
        return Pywal.foreground || "#cdd6f4"  // Normal
    }
    
    Component.onCompleted: {
        wasCharging = isCharging
    }
    
    // Watch for charging state changes
    onIsChargingChanged: {
        console.log("Battery charging state changed:", isCharging, "was:", wasCharging)
        if (isCharging && !wasCharging) {
            // Just plugged in - show animation
            console.log("SHOWING CHARGING ANIMATION")
            showChargingAnimation = true
            chargingAnimationTimer.restart()
        }
        wasCharging = isCharging
    }
    
    // Timer to hide charging animation after 3 seconds
    Timer {
        id: chargingAnimationTimer
        interval: 3000
        onTriggered: {
            console.log("Hiding charging animation")
            showChargingAnimation = false
        }
    }
    
    // Charging animation pill - shown when plugged in
    Item {
        id: chargingPill
        visible: showChargingAnimation
        opacity: showChargingAnimation ? 1 : 0
        anchors.fill: parent
        
        Behavior on opacity {
            NumberAnimation { duration: 300 }
        }
        
        // Beautiful green pill background
        Rectangle {
            id: pillBackground
            anchors.fill: parent
            radius: 12
            color: Pywal.color2 || "#a6e3a1"
            opacity: 0.2
            
            // Animated loading fill
            Rectangle {
                id: loadingFill
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 0
                radius: parent.radius
                color: Pywal.color2 || "#a6e3a1"
                opacity: 0.6
                
                // Smooth fill animation to current percentage
                NumberAnimation on width {
                    running: showChargingAnimation
                    from: 0
                    to: pillBackground.width * root.percentage
                    duration: 2000
                    easing.type: Easing.OutCubic
                }
                
                // Shimmer effect
                Rectangle {
                    width: parent.width
                    height: parent.height
                    radius: parent.radius
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 0.5; color: Qt.rgba(1, 1, 1, 0.3) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                    
                    // Moving shimmer
                    SequentialAnimation on x {
                        running: showChargingAnimation
                        loops: Animation.Infinite
                        
                        NumberAnimation {
                            from: -parent.width
                            to: parent.width
                            duration: 1500
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }
            
            // Percentage text in center - minimal and classy
            Text {
                anchors.centerIn: parent
                text: root.batteryLevel + "%"
                color: Pywal.color2 || "#a6e3a1"
                font.pixelSize: 12
                font.weight: Font.DemiBold
                
                // Subtle pulse effect
                SequentialAnimation on opacity {
                    running: showChargingAnimation
                    loops: Animation.Infinite
                    
                    NumberAnimation {
                        to: 1.0
                        duration: 1000
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        to: 0.7
                        duration: 1000
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }
    }
    
    // Normal battery display
    RowLayout {
        id: batteryRow
        anchors.fill: parent
        spacing: 6
        visible: !showChargingAnimation
        opacity: !showChargingAnimation ? 1 : 0
        
        Behavior on opacity {
            NumberAnimation { duration: 300 }
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
                    
                    // Subtle charging pulse on fill
                    SequentialAnimation on opacity {
                        running: root.isCharging && !showChargingAnimation
                        loops: Animation.Infinite
                        
                        NumberAnimation {
                            to: 0.9
                            duration: 1200
                            easing.type: Easing.InOutQuad
                        }
                        NumberAnimation {
                            to: 0.6
                            duration: 1200
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }
            
            // Charging indicator - small circle that moves across battery
            Rectangle {
                id: chargingIndicator
                width: 3
                height: 3
                radius: 1.5
                color: Pywal.color2 || "#a6e3a1"
                opacity: 0
                
                anchors.verticalCenter: batteryBody.verticalCenter
                x: 2
                
                // Slide animation when charging
                SequentialAnimation on x {
                    running: root.isCharging && !showChargingAnimation
                    loops: Animation.Infinite
                    
                    NumberAnimation {
                        to: batteryBody.width - 5
                        duration: 1500
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        to: 2
                        duration: 1500
                        easing.type: Easing.InOutQuad
                    }
                }
                
                SequentialAnimation on opacity {
                    running: root.isCharging && !showChargingAnimation
                    loops: Animation.Infinite
                    
                    NumberAnimation {
                        to: 0.8
                        duration: 1500
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        to: 0.3
                        duration: 1500
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }
        
        // Percentage text - minimal
        Text {
            text: root.batteryLevel + "%"
            color: root.batteryColor
            font.pixelSize: 11
            font.weight: root.isLow ? Font.DemiBold : Font.Normal
            
            Behavior on color {
                ColorAnimation { duration: 300 }
            }
            
            // Subtle pulse on critical
            SequentialAnimation on opacity {
                running: root.isCritical && !root.isCharging
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
    
    // Minimal background pill (for normal display)
    Rectangle {
        anchors.fill: parent
        anchors.margins: -5
        radius: 12
        color: root.batteryColor
        opacity: showChargingAnimation ? 0 : 0.08
        z: -1
        visible: !showChargingAnimation
        
        Behavior on color {
            ColorAnimation { duration: 300 }
        }
        
        Behavior on opacity {
            NumberAnimation { duration: 300 }
        }
        
        // Subtle border on low battery
        border.width: root.isLow ? 1 : 0
        border.color: root.batteryColor
        
        Behavior on border.width {
            NumberAnimation { duration: 200 }
        }
    }
}
