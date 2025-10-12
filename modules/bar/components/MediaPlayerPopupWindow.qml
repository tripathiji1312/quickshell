import Quickshell
import Quickshell.Wayland
import QtQuick 6.10
import qs.services

PanelWindow {
    id: popupWindow
    
    property var player: Players.active
    property bool shouldShow: false
    property var targetScreen
    
    visible: shouldShow && player !== null
    screen: targetScreen
    
    anchors {
        top: true
        left: true
    }
    
    margins {
        top: 32 + 8  // Bar height + gap
        left: 233    // Will be set dynamically
    }
    
    implicitWidth: 350
    implicitHeight: contentColumn.implicitHeight + 32
    
    color: "transparent"
    
    onVisibleChanged: {
        console.log("===== MediaPlayerPopupWindow visible changed to:", visible)
        console.log("Margins:", margins.top, margins.left, "Size:", implicitWidth, implicitHeight)
    }
    
    onShouldShowChanged: {
        console.log("===== MediaPlayerPopupWindow shouldShow changed to:", shouldShow)
    }
    
    // Background
    Rectangle {
        anchors.fill: parent
        radius: 12
        color: Pywal.background
        border.width: 1
        border.color: Qt.alpha(Pywal.colors.color1, 0.3)
        
        opacity: popupWindow.visible ? 1.0 : 0.0
        scale: popupWindow.visible ? 1.0 : 0.95
        
        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
        
        Behavior on scale {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutBack
            }
        }
        
        Column {
            id: contentColumn
            anchors.centerIn: parent
            width: parent.width - 32
            spacing: 12
            
            // Album art
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 200
                height: 200
                radius: 8
                color: Qt.alpha(Pywal.colors.color1, 0.1)
                clip: true
                
                Image {
                    anchors.fill: parent
                    source: popupWindow.player?.trackArtUrl ?? ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }
            }
            
            // Track info
            Column {
                width: parent.width
                spacing: 4
                
                Text {
                    width: parent.width
                    text: popupWindow.player?.trackTitle ?? "Unknown"
                    color: Pywal.foreground
                    font.pixelSize: 16
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }
                
                Text {
                    width: parent.width
                    text: popupWindow.player?.trackArtist ?? ""
                    color: Pywal.foreground
                    font.pixelSize: 13
                    opacity: 0.7
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }
                
                Text {
                    width: parent.width
                    text: popupWindow.player?.trackAlbum ?? ""
                    color: Pywal.foreground
                    font.pixelSize: 11
                    opacity: 0.5
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }
            }
            
            // Controls
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 16
                
                // Previous button
                Rectangle {
                    width: 44
                    height: 44
                    radius: 22
                    color: prevMouse.containsMouse ? Qt.alpha(Pywal.colors.color1, 0.2) : Qt.alpha(Pywal.colors.color1, 0.1)
                    
                    Text {
                        anchors.centerIn: parent
                        text: "⏮"
                        color: Pywal.colors.color1
                        font.pixelSize: 18
                    }
                    
                    MouseArea {
                        id: prevMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (popupWindow.player) popupWindow.player.previous()
                    }
                }
                
                // Play/Pause button
                Rectangle {
                    width: 56
                    height: 56
                    radius: 28
                    color: playMouse.containsMouse ? Qt.alpha(Pywal.colors.color1, 0.3) : Qt.alpha(Pywal.colors.color1, 0.2)
                    
                    Text {
                        anchors.centerIn: parent
                        text: popupWindow.player?.isPlaying ? "⏸" : "▶"
                        color: Pywal.colors.color1
                        font.pixelSize: 24
                    }
                    
                    MouseArea {
                        id: playMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (popupWindow.player) popupWindow.player.togglePlaying()
                    }
                }
                
                // Next button
                Rectangle {
                    width: 44
                    height: 44
                    radius: 22
                    color: nextMouse.containsMouse ? Qt.alpha(Pywal.colors.color1, 0.2) : Qt.alpha(Pywal.colors.color1, 0.1)
                    
                    Text {
                        anchors.centerIn: parent
                        text: "⏭"
                        color: Pywal.colors.color1
                        font.pixelSize: 18
                    }
                    
                    MouseArea {
                        id: nextMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (popupWindow.player) popupWindow.player.next()
                    }
                }
            }
        }
    }
}
