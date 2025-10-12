import QtQuick 6.10
import QtQuick.Layouts 6.10
import qs.services

Item {
    id: popup
    
    property var player
    property bool shouldBeActive: false
    
    implicitWidth: 350
    implicitHeight: contentColumn.implicitHeight + 32
    
    anchors.centerIn: parent
    
    opacity: 0
    scale: 0.95
    
    states: State {
        name: "active"
        when: popup.shouldBeActive
        
        PropertyChanges {
            popup.opacity: 1
            popup.scale: 1
        }
    }
    
    transitions: [
        Transition {
            from: ""
            to: "active"
            
            SequentialAnimation {
                NumberAnimation {
                    properties: "opacity,scale"
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }
        },
        Transition {
            from: "active"
            to: ""
            
            SequentialAnimation {
                NumberAnimation {
                    properties: "opacity,scale"
                    duration: 180
                    easing.type: Easing.InCubic
                }
            }
        }
    ]
    
    Rectangle {
        id: popupBg
        anchors.fill: parent
        radius: 16
        color: Pywal.background
        opacity: 0.98
        
        border.width: 1
        border.color: Qt.alpha(Pywal.colors.color1, 0.3)
        
        layer.enabled: true
        
        // Shadow effect
        Rectangle {
            anchors.fill: parent
            anchors.margins: -2
            radius: parent.radius + 2
            color: "transparent"
            border.width: 2
            border.color: Qt.alpha(Pywal.background, 0.5)
            z: -1
        }
        
        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16
            
            // Album art with smooth animation
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 200
                
                Rectangle {
                    anchors.centerIn: parent
                    width: 200
                    height: 200
                    radius: 12
                    color: Qt.alpha(Pywal.colors.color2, 0.15)
                    clip: true
                    
                    Image {
                        anchors.fill: parent
                        source: popup.player?.trackArtUrl ?? ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        smooth: true
                        
                        opacity: status === Image.Ready ? 1 : 0
                        
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 300
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                    
                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        radius: parent.radius
                        border.width: 1
                        border.color: Qt.alpha(Pywal.foreground, 0.1)
                    }
                    
                    // Placeholder icon
                    Text {
                        anchors.centerIn: parent
                        text: "♫"
                        font.pixelSize: 64
                        color: Pywal.foreground
                        opacity: 0.2
                        visible: !popup.player?.trackArtUrl || parent.children[0].status !== Image.Ready
                    }
                    
                    // Scale animation on show
                    scale: popup.shouldBeActive ? 1 : 0.95
                    Behavior on scale {
                        NumberAnimation {
                            duration: 250
                            easing.type: Easing.OutBack
                            easing.overshoot: 1.2
                        }
                    }
                }
            }
            
            // Track details
            Column {
                Layout.fillWidth: true
                spacing: 6
                
                Text {
                    width: parent.width
                    text: popup.player?.trackTitle ?? "No media"
                    color: Pywal.foreground
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                }
                
                Text {
                    width: parent.width
                    text: popup.player?.trackArtist ?? ""
                    color: Pywal.foreground
                    font.pixelSize: 14
                    elide: Text.ElideRight
                    opacity: 0.7
                    horizontalAlignment: Text.AlignHCenter
                }
                
                Text {
                    width: parent.width
                    text: popup.player?.trackAlbum ?? ""
                    color: Pywal.foreground
                    font.pixelSize: 12
                    elide: Text.ElideRight
                    opacity: 0.5
                    horizontalAlignment: Text.AlignHCenter
                    visible: text !== ""
                }
            }
            
            // Progress bar with time
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                
                Column {
                    anchors.fill: parent
                    spacing: 6
                    
                    Rectangle {
                        width: parent.width
                        height: 6
                        radius: 3
                        color: Qt.alpha(Pywal.foreground, 0.1)
                        
                        Rectangle {
                            height: parent.height
                            width: {
                                const pos = popup.player?.position ?? 0
                                const len = popup.player?.length ?? 1
                                return len > 0 ? parent.width * (pos / len) : 0
                            }
                            radius: parent.radius
                            color: Pywal.colors.color1
                            
                            Behavior on width {
                                NumberAnimation {
                                    duration: 1000
                                    easing.type: Easing.Linear
                                }
                            }
                        }
                    }
                    
                    Row {
                        width: parent.width
                        
                        Text {
                            text: formatTime(popup.player?.position ?? 0)
                            color: Pywal.foreground
                            font.pixelSize: 10
                            opacity: 0.5
                        }
                        
                        Item { width: parent.width - x; height: 1 }
                        
                        Text {
                            text: formatTime(popup.player?.length ?? 0)
                            color: Pywal.foreground
                            font.pixelSize: 10
                            opacity: 0.5
                        }
                    }
                }
            }
            
            // Control buttons
            Row {
                Layout.alignment: Qt.AlignHCenter
                spacing: 20
                
                // Previous
                Rectangle {
                    width: 44
                    height: 44
                    radius: 22
                    color: prevArea.pressed ? Qt.alpha(Pywal.colors.color2, 0.35) :
                           prevArea.containsMouse ? Qt.alpha(Pywal.colors.color2, 0.25) :
                           Qt.alpha(Pywal.foreground, 0.08)
                    
                    scale: prevArea.pressed ? 0.95 : 1
                    
                    Behavior on color {
                        ColorAnimation { duration: 180; easing.type: Easing.OutCubic }
                    }
                    
                    Behavior on scale {
                        NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: "⏮"
                        font.pixelSize: 18
                        color: Pywal.foreground
                        opacity: 0.9
                    }
                    
                    MouseArea {
                        id: prevArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: popup.player?.previous()
                    }
                }
                
                // Play/Pause
                Rectangle {
                    width: 56
                    height: 56
                    radius: 28
                    color: playArea.pressed ? Qt.alpha(Pywal.colors.color1, 0.5) :
                           playArea.containsMouse ? Qt.alpha(Pywal.colors.color1, 0.4) :
                           Qt.alpha(Pywal.colors.color1, 0.3)
                    
                    scale: playArea.pressed ? 0.95 : playArea.containsMouse ? 1.05 : 1
                    
                    Behavior on color {
                        ColorAnimation { duration: 180; easing.type: Easing.OutCubic }
                    }
                    
                    Behavior on scale {
                        NumberAnimation { duration: 150; easing.type: Easing.OutBack }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: popup.player?.isPlaying ? "⏸" : "▶"
                        font.pixelSize: 24
                        color: Pywal.colors.color1
                    }
                    
                    MouseArea {
                        id: playArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: popup.player?.togglePlaying()
                    }
                }
                
                // Next
                Rectangle {
                    width: 44
                    height: 44
                    radius: 22
                    color: nextArea.pressed ? Qt.alpha(Pywal.colors.color2, 0.35) :
                           nextArea.containsMouse ? Qt.alpha(Pywal.colors.color2, 0.25) :
                           Qt.alpha(Pywal.foreground, 0.08)
                    
                    scale: nextArea.pressed ? 0.95 : 1
                    
                    Behavior on color {
                        ColorAnimation { duration: 180; easing.type: Easing.OutCubic }
                    }
                    
                    Behavior on scale {
                        NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: "⏭"
                        font.pixelSize: 18
                        color: Pywal.foreground
                        opacity: 0.9
                    }
                    
                    MouseArea {
                        id: nextArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: popup.player?.next()
                    }
                }
            }
            
            // Player selector (if multiple players)
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                radius: 10
                color: Qt.alpha(Pywal.foreground, 0.05)
                visible: Players.list.length > 1
                
                Text {
                    anchors.centerIn: parent
                    text: Players.getIdentity(popup.player) + " • " + Players.list.length + " players"
                    color: Pywal.foreground
                    font.pixelSize: 11
                    opacity: 0.6
                }
            }
        }
    }
    
    function formatTime(microseconds: real): string {
        const totalSeconds = Math.floor(microseconds / 1000000)
        const minutes = Math.floor(totalSeconds / 60)
        const seconds = totalSeconds % 60
        return minutes + ":" + (seconds < 10 ? "0" : "") + seconds
    }
}
