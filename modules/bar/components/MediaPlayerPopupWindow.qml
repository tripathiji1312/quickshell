import Quickshell
import Quickshell.Wayland
import QtQuick 6.10
import QtQuick.Layouts 6.10
import qs.services
import "../../../services" as QsServices

PanelWindow {
    id: popupWindow
    
    property bool shouldShow: false
    property bool isHovered: false
    
    readonly property var player: Players.active
    
    // Non-animated dimensions
    readonly property real targetWidth: shouldShow ? 360 : 0
    readonly property real targetHeight: shouldShow ? (player ? contentColumn.implicitHeight + 32 : 0) : 0
    
    visible: shouldShow && player !== null
    screen: Quickshell.screens[0]  // Use first screen by default
    
    anchors {
        top: true
        left: true
    }
    
    margins {
        top: 40  // Bar height + gap
        left: 0  // Will be set dynamically
    }
    
    implicitWidth: targetWidth
    implicitHeight: targetHeight
    
    color: "transparent"
    
    // Smooth animations
    Behavior on implicitWidth {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }
    
    Behavior on implicitHeight {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }
    
    // Background with expanding bar design
    Rectangle {
        anchors.fill: parent
        radius: 12
        color: Pywal.background || "#1e1e2e"
        opacity: shouldShow ? 0.98 : 0
        
        border.width: 1
        border.color: Pywal.color2 || "#89b4fa"
        
        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }
        
        Behavior on color {
            ColorAnimation { duration: 200 }
        }
    }
    
    // Content
    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16
        visible: player !== null
        
        // Album art
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 280
            Layout.preferredHeight: 280
            radius: 12
            color: Pywal.color1 || "#89b4fa"
            clip: true
            
            Image {
                anchors.fill: parent
                anchors.margins: 2
                source: player?.trackArtUrl ?? ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                smooth: true
                visible: player?.trackArtUrl ?? false
            }
            
            // Fallback icon
            Text {
                anchors.centerIn: parent
                text: "🎵"
                font.pixelSize: 80
                visible: !(player?.trackArtUrl ?? false)
                opacity: 0.6
            }
        }
        
        // Track info
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4
            
            Text {
                Layout.fillWidth: true
                text: player?.trackTitle ?? "Unknown"
                color: Pywal.foreground || "#cdd6f4"
                font.pixelSize: 16
                font.weight: Font.Bold
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
            }
            
            Text {
                Layout.fillWidth: true
                text: player?.trackArtist ?? ""
                color: Pywal.foreground || "#cdd6f4"
                font.pixelSize: 13
                opacity: 0.8
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
            }
            
            Text {
                Layout.fillWidth: true
                text: player?.trackAlbum ?? ""
                color: Pywal.foreground || "#cdd6f4"
                font.pixelSize: 11
                opacity: 0.6
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
            }
        }
        
        // Progress Bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 6
            Layout.topMargin: 8
            
            color: Pywal.color1 || "#89b4fa"
            opacity: 0.3
            radius: 3
            
            Rectangle {
                width: player ? (parent.width * (player.position / player.length)) : 0
                height: parent.height
                color: Pywal.color2 || "#cba6f7"
                radius: 3
                
                Behavior on width {
                    NumberAnimation { duration: 100 }
                }
            }
        }
        
        // Time labels
        RowLayout {
            Layout.fillWidth: true
            
            Text {
                text: formatTime(player?.position ?? 0)
                color: Pywal.foreground || "#cdd6f4"
                opacity: 0.6
                font.pixelSize: 10
            }
            
            Item { Layout.fillWidth: true }
            
            Text {
                text: formatTime(player?.length ?? 0)
                color: Pywal.foreground || "#cdd6f4"
                opacity: 0.6
                font.pixelSize: 10
            }
        }
        
        // Playback Controls
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 8
            spacing: 16
            
            Item { Layout.fillWidth: true }
            
            // Previous
            Rectangle {
                Layout.preferredWidth: 44
                Layout.preferredHeight: 44
                
                color: prevHover.containsMouse ? Pywal.color1 || "#89b4fa" : "transparent"
                opacity: prevHover.containsMouse ? 0.3 : 0.1
                radius: 22
                
                Behavior on opacity {
                    NumberAnimation { duration: 150 }
                }
                
                Text {
                    anchors.centerIn: parent
                    text: "⏮"
                    font.pixelSize: 20
                    color: Pywal.foreground || "#cdd6f4"
                }
                
                MouseArea {
                    id: prevHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    
                    onClicked: {
                        if (player) player.previous()
                    }
                }
            }
            
            // Play/Pause
            Rectangle {
                Layout.preferredWidth: 56
                Layout.preferredHeight: 56
                
                color: playHover.containsMouse ? Pywal.color2 || "#cba6f7" : Pywal.color1 || "#89b4fa"
                radius: 28
                
                Behavior on color {
                    ColorAnimation { duration: 150 }
                }
                
                Text {
                    anchors.centerIn: parent
                    text: (player?.isPlaying ?? false) ? "⏸" : "▶"
                    font.pixelSize: 24
                    color: Pywal.background || "#1e1e2e"
                }
                
                MouseArea {
                    id: playHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    
                    onClicked: {
                        if (player) player.togglePlaying()
                    }
                }
            }
            
            // Next
            Rectangle {
                Layout.preferredWidth: 44
                Layout.preferredHeight: 44
                
                color: nextHover.containsMouse ? Pywal.color1 || "#89b4fa" : "transparent"
                opacity: nextHover.containsMouse ? 0.3 : 0.1
                radius: 22
                
                Behavior on opacity {
                    NumberAnimation { duration: 150 }
                }
                
                Text {
                    anchors.centerIn: parent
                    text: "⏭"
                    font.pixelSize: 20
                    color: Pywal.foreground || "#cdd6f4"
                }
                
                MouseArea {
                    id: nextHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    
                    onClicked: {
                        if (player) player.next()
                    }
                }
            }
            
            Item { Layout.fillWidth: true }
        }
    }
    
    // Hover area to keep popup open
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        z: 50  // Make sure it's above content
        
        onEntered: {
            popupWindow.isHovered = true
            QsServices.Logger.debug("MediaPlayerPopupWindow", "Hover entered")
        }
        
        onExited: {
            popupWindow.isHovered = false
            QsServices.Logger.debug("MediaPlayerPopupWindow", "Hover exited")
        }
    }
    
    onShouldShowChanged: {
        QsServices.Logger.debug("MediaPlayerPopupWindow", `shouldShow: ${shouldShow}`)
    }
    
    onIsHoveredChanged: {
        QsServices.Logger.debug("MediaPlayerPopupWindow", `isHovered: ${isHovered}`)
    }
    
    function formatTime(seconds) {
        if (!seconds || seconds <= 0) return "0:00"
        const mins = Math.floor(seconds / 60)
        const secs = Math.floor(seconds % 60)
        return mins + ":" + (secs < 10 ? "0" : "") + secs
    }
}
