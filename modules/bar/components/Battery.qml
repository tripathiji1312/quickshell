import QtQuick 6.10
import QtQuick.Layouts 6.10
import Quickshell
import Quickshell.Services.UPower
import "../../../services" as QsServices
import "../../../components/effects"

// Samsung-style animated battery - Matches the reference image
Item {
    id: root
    
    implicitWidth: batteryContainer.width
    implicitHeight: 24
    
    readonly property var battery: UPower.displayDevice
    readonly property var powerProfiles: QsServices.PowerProfiles
    readonly property var pywal: QsServices.Pywal
    readonly property real percentage: battery?.percentage ?? 0
    readonly property int batteryLevel: Math.round(percentage * 100)
    readonly property bool isCharging: battery?.state === UPowerDevice.Charging
    readonly property bool isFullyCharged: battery?.state === UPowerDevice.FullyCharged
    readonly property bool isPluggedIn: isCharging || isFullyCharged
    readonly property bool isWarning: batteryLevel <= 25 && batteryLevel > 15
    readonly property bool isLow: batteryLevel <= 15
    readonly property bool isCritical: isLow && !isPluggedIn
    
    // Track state changes for animations
    property bool wasPluggedIn: false
    property bool showExpandedMode: false
    property bool justPluggedIn: false
    
    // Detect plug-in event
    onIsPluggedInChanged: {
        if (isPluggedIn && !wasPluggedIn) {
            // Just plugged in - trigger expansion animation
            justPluggedIn = true
            showExpandedMode = true
            liquidFillAnim.restart()
            expandTimer.restart()
        }
        wasPluggedIn = isPluggedIn
    }
    
    // Timer to collapse back after showing liquid fill
    Timer {
        id: expandTimer
        interval: 4000
        onTriggered: {
            showExpandedMode = false
            justPluggedIn = false
        }
    }
    
    // Colors
    readonly property color normalColor: {
        if (isLow) return pywal.error
        if (isWarning) return pywal.warning
        if (batteryLevel >= 60) return Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.7)
        return Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.6)
    }
    
    readonly property color chargingColor: pywal.success
    readonly property color liquidColor: Qt.lighter(pywal.success, 1.2)
    readonly property color compactBatteryColor: {
        if (showExpandedMode || justPluggedIn) return chargingColor
        if (isPluggedIn && (isLow || isWarning)) return normalColor
        if (isPluggedIn) return chargingColor
        return normalColor
    }
    
    // Main container
    Item {
        id: batteryContainer
        anchors.centerIn: parent
        width: showExpandedMode ? expandedPill.width : normalBattery.width
        height: 24
        
        Behavior on width {
            NumberAnimation { 
                duration: 450
                easing.type: Easing.OutBack
                easing.overshoot: 1.1
            }
        }
        
        // ═══════════════════════════════════════════════════════════════
        // STATE 1 & 3: Normal / Charging compact view
        // ═══════════════════════════════════════════════════════════════
        Row {
            id: normalBattery
            anchors.centerIn: parent
            spacing: 4
            visible: !showExpandedMode
            opacity: showExpandedMode ? 0 : 1
            
            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }
            
            // Battery icon
            Item {
                width: 22
                height: 14
                anchors.verticalCenter: parent.verticalCenter
                
                // Battery body
                Rectangle {
                    id: batteryBody
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: 20
                    height: 12
                    radius: 3
                    color: "transparent"
                    border.width: 1.5
                    border.color: compactBatteryColor
                    
                    Behavior on border.color {
                        ColorAnimation { duration: 300 }
                    }
                    
                    // Fill level
                    Rectangle {
                        id: fillRect
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.margins: 2.5
                        width: Math.max(0, (parent.width - 5) * root.percentage)
                        radius: 1.5
                        color: compactBatteryColor
                        
                        Behavior on width {
                            NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
                        }
                        
                        // Charging shimmer
                        Rectangle {
                            id: chargeShimmer
                            visible: isCharging && !isFullyCharged && !showExpandedMode
                            anchors.fill: parent
                            radius: parent.radius
                            color: Qt.rgba(1, 1, 1, 0.12)
                            opacity: 0
                            
                            property real shimmerPos: 0
                            x: (parent.width + width) * shimmerPos - width
                            
                            SequentialAnimation on shimmerPos {
                                running: isCharging && !isFullyCharged && !showExpandedMode
                                loops: Animation.Infinite
                                NumberAnimation { from: -0.3; to: 1.3; duration: 1200; easing.type: Easing.InOutSine }
                                PauseAnimation { duration: 400 }
                            }

                            SequentialAnimation on opacity {
                                running: isCharging && !isFullyCharged && !showExpandedMode
                                loops: Animation.Infinite
                                NumberAnimation { from: 0.04; to: 0.16; duration: 600; easing.type: Easing.InOutSine }
                                NumberAnimation { from: 0.16; to: 0.04; duration: 600; easing.type: Easing.InOutSine }
                            }
                        }
                    }
                }
                
                // Terminal nub
                Rectangle {
                    anchors.left: batteryBody.right
                    anchors.leftMargin: -1
                    anchors.verticalCenter: parent.verticalCenter
                    width: 3
                    height: 5
                    radius: 1.5
                    color: compactBatteryColor
                    
                    Behavior on color {
                        ColorAnimation { duration: 300 }
                    }
                }
                
                // Charging bolt icon
                Text {
                    visible: isPluggedIn && !showExpandedMode
                    anchors.centerIn: batteryBody
                    text: "󱐋"
                    font.family: "Material Design Icons"
                    font.pixelSize: 9
                    color: batteryLevel > 50 ? pywal.background : pywal.foreground
                    opacity: 0.9
                    
                    SequentialAnimation on scale {
                        running: isCharging && !isFullyCharged && !showExpandedMode
                        loops: Animation.Infinite
                        NumberAnimation { to: 1.2; duration: 400; easing.type: Easing.OutCubic }
                        NumberAnimation { to: 1.0; duration: 400; easing.type: Easing.InCubic }
                    }
                }
            }
            
            // Percentage text
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: batteryLevel + "%"
                font.family: "Inter"
                font.pixelSize: 11
                font.weight: (isWarning || isLow) ? Font.Bold : Font.Medium
                color: compactBatteryColor
                
                Behavior on color {
                    ColorAnimation { duration: 300 }
                }
                
                // Critical pulse
                SequentialAnimation on opacity {
                    running: isCritical
                    loops: Animation.Infinite
                    NumberAnimation { to: 1.0; duration: 500 }
                    NumberAnimation { to: 0.3; duration: 500 }
                }
            }
        }
        
        // ═══════════════════════════════════════════════════════════════
        // STATE 2: Just plugged in - Samsung-style expanded pill
        // ═══════════════════════════════════════════════════════════════
        Rectangle {
            id: expandedPill
            anchors.centerIn: parent
            width: 52
            height: 20
            radius: 10
            visible: showExpandedMode
            opacity: showExpandedMode ? 1 : 0
            color: pywal.surfaceDim
            border.width: 1.5
            border.color: chargingColor
            
            Behavior on opacity {
                NumberAnimation { duration: 250 }
            }
            
            // Liquid fill inside
            Rectangle {
                id: liquidFillBg
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.margins: 2
                width: 0
                radius: parent.radius - 2
                color: chargingColor
                
                // Liquid fill animation
                SequentialAnimation {
                    id: liquidFillAnim
                    
                    NumberAnimation {
                        target: liquidFillBg
                        property: "width"
                        from: 0
                        to: (expandedPill.width - 4) * root.percentage
                        duration: 1500
                        easing.type: Easing.OutCubic
                    }
                }
                
                // Shimmer
                Rectangle {
                    id: liquidShimmer
                    anchors.fill: parent
                    radius: parent.radius
                    color: Qt.rgba(1, 1, 1, 0.10)
                    opacity: 0
                    
                    property real shimmerX: 0
                    x: (parent.width + width) * shimmerX - width
                    
                    SequentialAnimation on shimmerX {
                        running: showExpandedMode
                        loops: Animation.Infinite
                        NumberAnimation { from: -0.2; to: 1.2; duration: 1000 }
                        PauseAnimation { duration: 500 }
                    }

                    SequentialAnimation on opacity {
                        running: showExpandedMode
                        loops: Animation.Infinite
                        NumberAnimation { from: 0.03; to: 0.14; duration: 500; easing.type: Easing.InOutSine }
                        NumberAnimation { from: 0.14; to: 0.03; duration: 500; easing.type: Easing.InOutSine }
                    }
                }
            }
            
            // Percentage centered
            Text {
                anchors.centerIn: parent
                text: batteryLevel + "%"
                font.family: "Inter"
                font.pixelSize: 11
                font.weight: Font.Bold
                color: pywal.foreground
            }
        }
    }
}
