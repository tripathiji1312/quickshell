import QtQuick 6.10
import QtQuick.Layouts 6.10
import Quickshell
import qs.services

Item {
    id: popout
    
    property var wrapperItem
    property bool isHovered: false
    
    implicitHeight: contentColumn.implicitHeight + 32
    
    readonly property var player: Players.active
    
    ColumnLayout {
        id: contentColumn
        
        anchors {
            fill: parent
            margins: 16
        }
        spacing: 16
        
        // Album Art
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 280
            Layout.preferredHeight: 280
            
            color: Pywal.color1 || "#89b4fa"
            radius: 12
            clip: true
            
            Image {
                anchors.fill: parent
                anchors.margins: 2
                source: player?.trackArtUrl ?? ""
                fillMode: Image.PreserveAspectCrop
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
        
        // Track Info
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4
            
            Text {
                Layout.fillWidth: true
                text: player?.trackTitle ?? "No track playing"
                color: Pywal.foreground || "#cdd6f4"
                font.pixelSize: 16
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }
            
            Text {
                Layout.fillWidth: true
                text: player?.trackArtist ?? ""
                color: Pywal.foreground || "#cdd6f4"
                opacity: 0.8
                font.pixelSize: 13
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }
            
            Text {
                Layout.fillWidth: true
                text: player?.trackAlbum ?? ""
                color: Pywal.foreground || "#cdd6f4"
                opacity: 0.6
                font.pixelSize: 11
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
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
    
    function formatTime(seconds) {
        if (!seconds || seconds <= 0) return "0:00"
        const mins = Math.floor(seconds / 60)
        const secs = Math.floor(seconds % 60)
        return mins + ":" + (secs < 10 ? "0" : "") + secs
    }
}
