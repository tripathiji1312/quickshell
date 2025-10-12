import QtQuick 6.10
import QtQuick.Layouts 6.10
import Quickshell
import qs.services
import "../../../components"

Item {
    id: root
    
    property var barWindow  // Reference to parent bar window
    property var popoutWrapper  // Reference to popout wrapper
    
    width: Math.max(120, root.hasPlayer ? contentRow.implicitWidth : 120)
    height: Math.max(24, root.hasPlayer ? contentRow.implicitHeight : 24)
    implicitWidth: width
    implicitHeight: height
    
    readonly property var player: Players.active
    readonly property bool hasPlayer: player !== null
    readonly property bool isPlaying: player?.isPlaying ?? false
    
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
                        width: 2
                        height: root.isPlaying ? (Math.random() * 10 + 6) : 4
                        radius: 1
                        color: Pywal.colors.color1
                        opacity: 0.8
                        
                        Behavior on height {
                            NumberAnimation {
                                duration: 180
                                easing.type: Easing.OutCubic
                            }
                        }
                        
                        // Continuous animation when playing
                        SequentialAnimation on height {
                            running: root.isPlaying
                            loops: Animation.Infinite
                            
                            NumberAnimation {
                                to: Math.random() * 12 + 4
                                duration: 300 + Math.random() * 200
                                easing.type: Easing.InOutSine
                            }
                            NumberAnimation {
                                to: Math.random() * 12 + 4
                                duration: 300 + Math.random() * 200
                                easing.type: Easing.InOutSine
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
                font.pixelSize: 13
                font.weight: Font.Medium
                elide: Text.ElideRight
                opacity: 0.9
            }
            
            Text {
                id: artistText
                width: parent.width
                text: root.player?.trackArtist ?? ""
                color: Pywal.foreground
                font.pixelSize: 11
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
    
    // "No media" placeholder when no player
    Item {
        id: noMediaRow
        anchors.fill: parent
        visible: !root.hasPlayer
        z: 0
        
        Row {
            anchors.centerIn: parent
            spacing: 8
            
            // Music note icon
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "♪"
                color: Pywal.colors.color1
                font.pixelSize: 18
                font.weight: Font.Medium
                
                SequentialAnimation on opacity {
                    running: true
                    loops: Animation.Infinite
                    
                    NumberAnimation {
                        from: 0.7
                        to: 0.3
                        duration: 2000
                        easing.type: Easing.InOutSine
                    }
                    NumberAnimation {
                        from: 0.3
                        to: 0.7
                        duration: 2000
                        easing.type: Easing.InOutSine
                    }
                }
            }
            
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "No media"
                color: Pywal.foreground
                font.pixelSize: 12
                opacity: 0.5
            }
        }
    }
    
    // Hover area to show popout - place ABOVE content
    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        acceptedButtons: Qt.NoButton
        z: 100  // Make sure it's on top
        
        onEntered: {
            hideTimer.stop()  // Cancel any pending hide
            if (root.hasPlayer && root.popoutWrapper) {
                showTimer.restart()  // Restart to reset the 400ms countdown
            }
        }
        
        onExited: {
            showTimer.stop()  // Stop show timer if we leave
            // Only start hide timer if popup is actually showing
            if (root.popoutWrapper && root.popoutWrapper.hasCurrent) {
                hideTimer.start()
            }
        }
    }
    
    Timer {
        id: showTimer
        interval: 400
        onTriggered: {
            if (root.hasPlayer && root.popoutWrapper) {
                root.popoutWrapper.currentName = "mediaplayer"
                root.popoutWrapper.hasCurrent = true
            }
        }
    }
    
    Timer {
        id: hideTimer
        interval: 300
        onTriggered: {
            if (root.popoutWrapper) {
                // Only hide if not hovering anymore
                if (!hoverArea.containsMouse) {
                    root.popoutWrapper.hasCurrent = false
                    root.popoutWrapper.currentName = ""
                }
            }
        }
    }
}
