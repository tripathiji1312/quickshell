import QtQuick 6.10
import QtQuick.Layouts 6.10
import Quickshell
import qs.services
import "../../../components"

Item {
    id: root
    
    property var barWindow
    property var mediaPopup  // Reference to popup window
    
    implicitWidth: contentRow.implicitWidth
    implicitHeight: contentRow.implicitHeight
    
    readonly property var player: Players.active
    readonly property bool hasPlayer: player !== null
    readonly property bool isPlaying: player?.isPlaying ?? false
    
    // Hover state
    property bool isHovered: false
    
    // Main compact content row
    RowLayout {
        id: contentRow
        anchors.fill: parent
        spacing: 8
        
        // Animated playing indicator (equalizer bars)
        Item {
            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
            visible: root.hasPlayer
            
            Row {
                anchors.centerIn: parent
                spacing: 2
                
                Repeater {
                    model: 3
                    
                    Rectangle {
                        width: 3
                        height: 4
                        radius: 1.5
                        color: Pywal.colors.color1
                        opacity: root.isPlaying ? 0.9 : 0.4
                        
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 300
                                easing.type: Easing.OutCubic
                            }
                        }
                        
                        // Smooth continuous animation when playing
                        SequentialAnimation on height {
                            running: root.isPlaying
                            loops: Animation.Infinite
                            
                            // Each bar has different timing for natural wave effect
                            NumberAnimation {
                                to: index === 0 ? 14 : (index === 1 ? 16 : 12)
                                duration: 400 + (index * 50)
                                easing.type: Easing.InOutQuad
                            }
                            NumberAnimation {
                                to: index === 0 ? 6 : (index === 1 ? 8 : 10)
                                duration: 450 + (index * 50)
                                easing.type: Easing.InOutQuad
                            }
                            NumberAnimation {
                                to: index === 0 ? 10 : (index === 1 ? 14 : 7)
                                duration: 420 + (index * 50)
                                easing.type: Easing.InOutQuad
                            }
                            NumberAnimation {
                                to: 4
                                duration: 400 + (index * 50)
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }
                }
            }
        }
        
        // Track info
        Column {
            Layout.fillWidth: true
            Layout.preferredWidth: 200
            Layout.maximumWidth: 250
            spacing: 2
            visible: root.hasPlayer
            
            Text {
                id: titleText
                width: parent.width
                text: root.player?.trackTitle ?? "No media"
                color: Pywal.foreground
                font.pixelSize: 12
                font.weight: Font.Medium
                elide: Text.ElideRight
                opacity: 0.9
            }
            
            Text {
                id: artistText
                width: parent.width
                text: root.player?.trackArtist ?? ""
                color: Pywal.foreground
                font.pixelSize: 10
                elide: Text.ElideRight
                opacity: 0.6
            }
        }
        
        // Play/Pause button
        Rectangle {
            Layout.preferredWidth: 28
            Layout.preferredHeight: 28
            radius: 14
            visible: root.hasPlayer
            
            color: {
                if (playPauseArea.pressed) return Qt.alpha(Pywal.colors.color1, 0.3)
                if (playPauseArea.containsMouse) return Qt.alpha(Pywal.colors.color1, 0.2)
                return Qt.alpha(Pywal.colors.color1, 0.15)
            }
            
            Behavior on color {
                ColorAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }
            
            Text {
                anchors.centerIn: parent
                text: root.isPlaying ? "⏸" : "▶"
                color: Pywal.colors.color1
                font.pixelSize: 14
                opacity: 0.9
            }
            
            MouseArea {
                id: playPauseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                
                onClicked: {
                    if (root.player) {
                        root.player.togglePlaying()
                    }
                }
            }
        }
    }
    
    // Hover area to show popout
    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        acceptedButtons: Qt.NoButton
        z: 100
        
        onEntered: {
            root.isHovered = true
            hideTimer.stop()
            if (root.hasPlayer && root.mediaPopup) {
                showTimer.restart()
                console.log("MediaPlayer hover entered")
            }
        }
        
        onExited: {
            root.isHovered = false
            showTimer.stop()
            // Only start hide timer if popup is showing
            if (root.mediaPopup?.shouldShow) {
                hideTimer.start()
                console.log("MediaPlayer hover exited, starting hide timer")
            }
        }
    }
    
    Timer {
        id: showTimer
        interval: 400
        onTriggered: {
            if (root.hasPlayer && root.mediaPopup) {
                // Get X position for alignment
                var globalPos = root.mapToItem(null, 0, root.height)
                root.mediaPopup.margins.left = Math.round(globalPos.x)
                root.mediaPopup.margins.top = Math.round(globalPos.y + 8)
                root.mediaPopup.shouldShow = true
                console.log("Showing popup at:", root.mediaPopup.margins.left, root.mediaPopup.margins.top)
            }
        }
    }
    
    Timer {
        id: hideTimer
        interval: 300
        onTriggered: {
            console.log("Hide timer triggered - isHovered:", root.isHovered, "popup.isHovered:", root.mediaPopup?.isHovered)
            // Check if mouse is over player OR popup before hiding
            if (root.mediaPopup && !root.isHovered && !root.mediaPopup.isHovered) {
                root.mediaPopup.shouldShow = false
                console.log("Hiding popup")
            } else {
                console.log("NOT hiding - still hovered")
            }
        }
    }
}
