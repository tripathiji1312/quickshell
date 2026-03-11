import QtQuick 6.10
import QtQuick.Layouts 6.10
import Quickshell
import qs.services
import "../../../components"
import "../../../components/effects"

// Compact Music Widget - Fixed buttons, proper text reset
Item {
    id: root
    
    property var barWindow
    property var mediaPopup
    
    // Always show - either player content or "No media" text
    // Use fixed width for no media state to avoid circular dependency
    implicitWidth: hasPlayer ? contentRow.implicitWidth : 70
    implicitHeight: 22
    visible: true
    
    readonly property var player: Players.active
    readonly property bool hasPlayer: player !== null
    readonly property bool isPlaying: player?.isPlaying ?? false
    readonly property real progress: player?.position ?? 0
    readonly property real duration: player?.length ?? 1
    readonly property real progressPercent: duration > 0 ? progress / duration : 0
    
    property bool isHovered: contentMouse.containsMouse || noMediaMouse.containsMouse
    
    // Reset text position when paused
    onIsPlayingChanged: {
        if (!isPlaying) {
            marqueeAnim.stop()
            titleText.x = titleText.needsScroll ? 0 : (80 - titleText.implicitWidth) / 2
        }
    }
    
    // No media placeholder
    RowLayout {
        id: noMediaRow
        anchors.centerIn: parent
        spacing: 6
        visible: !hasPlayer
        opacity: !hasPlayer ? 1 : 0
        
        Behavior on opacity { NumberAnimation { duration: 200 } }
        
        Text {
            text: "󰎇"
            font.family: "Material Design Icons"
            font.pixelSize: 14
            color: Qt.rgba(Pywal.foreground.r, Pywal.foreground.g, Pywal.foreground.b, 0.4)
            Layout.alignment: Qt.AlignVCenter
        }
        
        Text {
            text: "No media"
            font.family: "Inter"
            font.pixelSize: 10
            font.weight: Font.Medium
            color: Qt.rgba(Pywal.foreground.r, Pywal.foreground.g, Pywal.foreground.b, 0.4)
            Layout.alignment: Qt.AlignVCenter
        }
    }
    
    // Mouse area for no media state (outside layout)
    MouseArea {
        id: noMediaMouse
        anchors.fill: parent
        visible: !hasPlayer
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }
    
    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: 6
        visible: hasPlayer
        opacity: hasPlayer ? 1 : 0
        
        Behavior on opacity { NumberAnimation { duration: 200 } }
        
        // Vinyl Record with glow
        Item {
            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
            Layout.alignment: Qt.AlignVCenter
            
            // Glow when playing
            Rectangle {
                visible: root.isPlaying
                anchors.centerIn: parent
                width: 22
                height: 22
                radius: 11
                color: "transparent"
                border.width: 1
                border.color: Qt.rgba(Pywal.primary.r, Pywal.primary.g, Pywal.primary.b, 0.3)
                
                SequentialAnimation on opacity {
                    running: root.isPlaying
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.3; duration: 1000 }
                    NumberAnimation { to: 1.0; duration: 1000 }
                }
            }
            
            Rectangle {
                id: vinyl
                anchors.centerIn: parent
                width: 16
                height: 16
                radius: 8
                color: Pywal.surfaceContainerLow
                
                rotation: 0
                
                RotationAnimation on rotation {
                    running: root.isPlaying
                    from: vinyl.rotation
                    to: vinyl.rotation + 360
                    duration: 2500
                    loops: Animation.Infinite
                }
                
                // Groove rings
                Repeater {
                    model: 2
                    Rectangle {
                        anchors.centerIn: parent
                        width: 10 - index * 3
                        height: width
                        radius: width / 2
                        color: "transparent"
                        border.width: 0.5
                        border.color: Qt.rgba(1, 1, 1, 0.08)
                    }
                }
                
                // Center label
                Rectangle {
                    anchors.centerIn: parent
                    width: 5
                    height: 5
                    radius: 2.5
                    color: Pywal.primary
                    
                    Rectangle {
                        anchors.centerIn: parent
                        width: 2
                        height: 2
                        radius: 1
                        color: Qt.rgba(0, 0, 0, 0.5)
                    }
                }
            }
        }
        
        // Track Title - Marquee with proper reset
        Item {
            Layout.preferredWidth: 80
            Layout.preferredHeight: parent.height
            Layout.alignment: Qt.AlignVCenter
            clip: true
            
            MouseArea {
                id: contentMouse
                anchors.fill: parent
                hoverEnabled: true
            }
            
            Text {
                id: titleText
                anchors.verticalCenter: parent.verticalCenter
                
                text: root.player?.trackTitle ?? "Unknown"
                color: Pywal.foreground
                font.pixelSize: 10
                font.weight: Font.Medium
                
                property bool needsScroll: implicitWidth > 80
                
                x: needsScroll ? 0 : (80 - implicitWidth) / 2
                
                Behavior on x {
                    enabled: !marqueeAnim.running
                    NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                }
                
                SequentialAnimation {
                    id: marqueeAnim
                    running: titleText.needsScroll && root.isPlaying
                    loops: Animation.Infinite
                    
                    PauseAnimation { duration: 2000 }
                    NumberAnimation {
                        target: titleText
                        property: "x"
                        to: -(titleText.implicitWidth + 20)
                        duration: titleText.implicitWidth * 30
                        easing.type: Easing.Linear
                    }
                    PropertyAction { 
                        target: titleText
                        property: "x"
                        value: 80
                    }
                    NumberAnimation {
                        target: titleText
                        property: "x"
                        to: 0
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
        
        // Stylish divider
        Rectangle {
            Layout.preferredWidth: 1
            Layout.preferredHeight: 12
            Layout.alignment: Qt.AlignVCenter
            radius: 0.5
            color: Qt.rgba(Pywal.foreground.r, Pywal.foreground.g, Pywal.foreground.b, 0.18)
        }
        
        // Controls - Fixed with proper click handling
        RowLayout {
            Layout.alignment: Qt.AlignVCenter
            spacing: 2
            
            // Previous button
            Rectangle {
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                radius: 10
                color: prevArea.containsMouse ? Qt.rgba(Pywal.foreground.r, Pywal.foreground.g, Pywal.foreground.b, 0.15) : "transparent"
                
                Behavior on color { ColorAnimation { duration: 100 } }
                Behavior on scale { NumberAnimation { duration: 80 } }
                scale: prevArea.pressed ? 0.9 : 1.0
                
                Text {
                    anchors.centerIn: parent
                    text: "󰒮"
                    font.family: "Material Design Icons"
                    font.pixelSize: 13
                    color: prevArea.containsMouse ? Pywal.primary : Pywal.foreground
                    
                    Behavior on color { ColorAnimation { duration: 100 } }
                }
                
                MouseArea {
                    id: prevArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    
                    onClicked: {
                        if (root.player && root.player.canGoPrevious) {
                            root.player.previous()
                        }
                    }
                }
            }
            
            // Play/Pause button - Main action
            Rectangle {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                radius: 12
                color: playArea.containsMouse ? Qt.lighter(Pywal.primary, 1.08) : Pywal.primary
                
                Behavior on scale { NumberAnimation { duration: 80 } }
                scale: playArea.pressed ? 0.85 : (playArea.containsMouse ? 1.05 : 1.0)
                
                // Glow effect
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width + 4
                    height: parent.height + 4
                    radius: width / 2
                    color: "transparent"
                    border.width: 2
                    border.color: Qt.rgba(Pywal.primary.r, Pywal.primary.g, Pywal.primary.b, playArea.containsMouse ? 0.3 : 0)
                    z: -1
                    
                    Behavior on border.color { ColorAnimation { duration: 150 } }
                }
                
                Text {
                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: root.isPlaying ? 0 : 1
                    text: root.isPlaying ? "󰏤" : "󰐊"
                    font.family: "Material Design Icons"
                    font.pixelSize: 14
                    color: Pywal.onPrimary
                }
                
                MouseArea {
                    id: playArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    
                    onClicked: {
                        if (root.player && root.player.canTogglePlaying) {
                            root.player.togglePlaying()
                        }
                    }
                }
            }
            
            // Next button
            Rectangle {
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                radius: 10
                color: nextArea.containsMouse ? Qt.rgba(Pywal.foreground.r, Pywal.foreground.g, Pywal.foreground.b, 0.15) : "transparent"
                
                Behavior on color { ColorAnimation { duration: 100 } }
                Behavior on scale { NumberAnimation { duration: 80 } }
                scale: nextArea.pressed ? 0.9 : 1.0
                
                Text {
                    anchors.centerIn: parent
                    text: "󰒭"
                    font.family: "Material Design Icons"
                    font.pixelSize: 13
                    color: nextArea.containsMouse ? Pywal.primary : Pywal.foreground
                    
                    Behavior on color { ColorAnimation { duration: 100 } }
                }
                
                MouseArea {
                    id: nextArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    
                    onClicked: {
                        if (root.player && root.player.canGoNext) {
                            root.player.next()
                        }
                    }
                }
            }
        }
        
        // Beautiful progress bar
        Item {
            Layout.preferredWidth: 35
            Layout.preferredHeight: 4
            Layout.alignment: Qt.AlignVCenter
            
            Rectangle {
                anchors.fill: parent
                radius: 2
                color: Qt.rgba(Pywal.foreground.r, Pywal.foreground.g, Pywal.foreground.b, 0.12)
                
                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.width * root.progressPercent
                    radius: 2
                    color: Pywal.primary
                    
                    Behavior on width {
                        NumberAnimation { duration: 200 }
                    }
                    
                    // Playhead dot
                    Rectangle {
                        visible: root.isPlaying
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: 6
                        height: 6
                        radius: 3
                        color: Pywal.onPrimary
                        
                        SequentialAnimation on scale {
                            running: root.isPlaying
                            loops: Animation.Infinite
                            NumberAnimation { to: 1.2; duration: 600 }
                            NumberAnimation { to: 1.0; duration: 600 }
                        }
                    }
                }
            }
        }
    }
}
