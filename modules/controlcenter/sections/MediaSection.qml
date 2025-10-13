import QtQuick 6.10
import QtQuick.Layouts 6.10
import QtQuick.Controls 6.10
import Quickshell
import "../../../services" as QsServices

Item {
    id: root
    
    readonly property var pywal: QsServices.Pywal
    readonly property var players: QsServices.Players
    
    // Selected player - automatically update when active player changes
    property var selectedPlayer: players.active
    
    // Watch for changes in active player and update selection
    Connections {
        target: players
        function onActiveChanged() {
            if (players.active && (!selectedPlayer || selectedPlayer !== players.active)) {
                selectedPlayer = players.active
            }
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 8
        
        // Header with player selector
        RowLayout {
            Layout.fillWidth: true
            spacing: 12
            
            Text {
                text: "Media Player"
                font.family: "Inter"
                font.pixelSize: 16
                font.weight: Font.Bold
                color: pywal.foreground
                Layout.fillWidth: true
            }
            
            // Player selector dropdown (only show if multiple players)
            Rectangle {
                Layout.preferredHeight: 32
                Layout.preferredWidth: 160
                radius: 8
                color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.08)
                visible: players.list.length > 1
                z: 200  // Ensure dropdown appears above other content
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 6
                    
                    Text {
                        text: "󰓃"
                        font.family: "Material Design Icons"
                        font.pixelSize: 16
                        color: pywal.color2
                    }
                    
                    Text {
                        Layout.fillWidth: true
                        text: selectedPlayer?.identity ?? "Select Player"
                        font.family: "Inter"
                        font.pixelSize: 11
                        color: pywal.foreground
                        elide: Text.ElideRight
                    }
                    
                    Text {
                        text: playerSelectorMenu.visible ? "󰅃" : "󰅀"
                        font.family: "Material Design Icons"
                        font.pixelSize: 14
                        color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.6)
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: playerSelectorMenu.visible = !playerSelectorMenu.visible
                }
                
                // Dropdown menu
                Rectangle {
                    id: playerSelectorMenu
                    visible: false
                    anchors.top: parent.bottom
                    anchors.topMargin: 4
                    anchors.left: parent.left
                    width: parent.width
                    height: Math.min(playerMenuColumn.implicitHeight + 8, 200)  // Max height to prevent overflow
                    radius: 8
                    color: pywal.background
                    border.width: 1
                    border.color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.15)
                    z: 300  // Higher z-index for dropdown
                    
                    // Shadow effect
                    layer.enabled: true
                    layer.effect: Item {
                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            border.color: Qt.rgba(0, 0, 0, 0.2)
                            border.width: 1
                            radius: 8
                        }
                    }
                    
                    ColumnLayout {
                        id: playerMenuColumn
                        anchors.fill: parent
                        anchors.margins: 4
                        spacing: 2
                        
                        Repeater {
                            model: players.list
                            
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 32
                                radius: 6
                                color: playerMouseArea.containsMouse ? 
                                       Qt.rgba(pywal.color2.r, pywal.color2.g, pywal.color2.b, 0.2) : 
                                       "transparent"
                                
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 6
                                    spacing: 8
                                    
                                    Text {
                                        text: modelData.isPlaying ? "󰐊" : "󰏤"
                                        font.family: "Material Design Icons"
                                        font.pixelSize: 14
                                        color: modelData.isPlaying ? pywal.color2 : Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.5)
                                    }
                                    
                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.identity ?? "Unknown"
                                        font.family: "Inter"
                                        font.pixelSize: 11
                                        color: pywal.foreground
                                        elide: Text.ElideRight
                                    }
                                    
                                    Text {
                                        text: "󰄬"
                                        font.family: "Material Design Icons"
                                        font.pixelSize: 12
                                        color: pywal.color2
                                        visible: selectedPlayer === modelData
                                    }
                                }
                                
                                MouseArea {
                                    id: playerMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    
                                    onClicked: {
                                        selectedPlayer = modelData
                                        playerSelectorMenu.visible = false
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Player content or no player message
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            // No player active
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 16
                visible: !selectedPlayer
                
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "󰝚"
                    font.family: "Material Design Icons"
                    font.pixelSize: 56
                    color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.2)
                }
                
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "No media playing"
                    font.family: "Inter"
                    font.pixelSize: 15
                    font.weight: Font.Medium
                    color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.5)
                }
                
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Start playing media to control it here"
                    font.family: "Inter"
                    font.pixelSize: 12
                    color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.35)
                }
            }
            
            // Active player
            ColumnLayout {
                anchors.fill: parent
                spacing: 8
                visible: selectedPlayer
                
                // Album art with glow effect
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 220  // Reduced from 300px to fit all controls
                    
                    // Glow/shadow effect
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width - 20
                        height: parent.height - 20
                        radius: 16
                        color: pywal.color2
                        opacity: selectedPlayer?.trackArtUrl ? 0.15 : 0
                        
                        Behavior on opacity {
                            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                        }
                    }
                    
                    Rectangle {
                        id: albumArtRect
                        anchors.centerIn: parent
                        width: parent.width - 24
                        height: parent.height - 24
                        radius: 14
                        color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.05)
                        clip: true
                        
                        scale: albumMouseArea.containsMouse ? 1.02 : 1.0
                        
                        Behavior on scale {
                            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                        }
                        
                        Image {
                            id: albumArtImage
                            anchors.fill: parent
                            source: selectedPlayer?.trackArtUrl ?? ""
                            fillMode: Image.PreserveAspectCrop
                            smooth: true
                            asynchronous: true
                            
                            opacity: status === Image.Ready ? 1 : 0
                            
                            Behavior on opacity {
                                NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                            }
                        }
                        
                        // Fallback icon with animation
                        Text {
                            anchors.centerIn: parent
                            text: "󰝚"
                            font.family: "Material Design Icons"
                            font.pixelSize: 72
                            color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.15)
                            visible: albumArtImage.status !== Image.Ready
                            
                            SequentialAnimation on opacity {
                                running: visible
                                loops: Animation.Infinite
                                NumberAnimation { from: 0.15; to: 0.3; duration: 1200; easing.type: Easing.InOutCubic }
                                NumberAnimation { from: 0.3; to: 0.15; duration: 1200; easing.type: Easing.InOutCubic }
                            }
                        }
                        
                        // Gradient overlay for playing indicator
                        Rectangle {
                            anchors.fill: parent
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "transparent" }
                                GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.3) }
                            }
                            visible: albumArtImage.status === Image.Ready
                        }
                        
                        // Playing indicator
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                            anchors.margins: 12
                            width: 36
                            height: 36
                            radius: 18
                            color: selectedPlayer?.isPlaying ? pywal.color2 : Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.3)
                            
                            Behavior on color {
                                ColorAnimation { duration: 200 }
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                text: selectedPlayer?.isPlaying ? "󰐊" : "󰏤"
                                font.family: "Material Design Icons"
                                font.pixelSize: 18
                                color: selectedPlayer?.isPlaying ? pywal.background : pywal.foreground
                            }
                        }
                        
                        MouseArea {
                            id: albumMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                        }
                    }
                }
                
                // Track info with better spacing
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1
                    Layout.topMargin: 4
                    
                    Text {
                        Layout.fillWidth: true
                        text: selectedPlayer?.trackTitle ?? "Unknown Track"
                        font.family: "Inter"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: pywal.foreground
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        horizontalAlignment: Text.AlignHCenter
                    }
                    
                    Text {
                        Layout.fillWidth: true
                        text: selectedPlayer?.trackArtist ?? "Unknown Artist"
                        font.family: "Inter"
                        font.pixelSize: 13
                        color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.7)
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        horizontalAlignment: Text.AlignHCenter
                    }
                    
                    Text {
                        Layout.fillWidth: true
                        text: selectedPlayer?.trackAlbum ?? ""
                        font.family: "Inter"
                        font.pixelSize: 11
                        color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.5)
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        horizontalAlignment: Text.AlignHCenter
                        visible: text !== ""
                    }
                }
                
                // Seek bar with improved design
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    
                    Slider {
                        id: seekSlider
                        Layout.fillWidth: true
                        from: 0
                        to: selectedPlayer?.length ?? 100
                        value: selectedPlayer?.position ?? 0
                        
                        onMoved: {
                            if (selectedPlayer) {
                                selectedPlayer.setPosition(value)
                            }
                        }
                        
                        background: Rectangle {
                            x: seekSlider.leftPadding
                            y: seekSlider.topPadding + seekSlider.availableHeight / 2 - height / 2
                            width: seekSlider.availableWidth
                            height: 6
                            radius: 3
                            color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.1)
                            
                            Rectangle {
                                width: seekSlider.visualPosition * parent.width
                                height: parent.height
                                color: pywal.color2
                                radius: 3
                                
                                Behavior on width {
                                    NumberAnimation { duration: 100 }
                                }
                            }
                        }
                        
                        handle: Rectangle {
                            x: seekSlider.leftPadding + seekSlider.visualPosition * (seekSlider.availableWidth - width)
                            y: seekSlider.topPadding + seekSlider.availableHeight / 2 - height / 2
                            width: 18
                            height: 18
                            radius: 9
                            color: pywal.background
                            border.color: pywal.color2
                            border.width: 2
                            
                            scale: seekSlider.pressed ? 1.2 : 1.0
                            
                            Behavior on scale {
                                NumberAnimation { duration: 100 }
                            }
                        }
                    }
                    
                    // Time labels
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: formatTime(selectedPlayer?.position ?? 0)
                            font.family: "Inter"
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.6)
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Text {
                            text: formatTime(selectedPlayer?.length ?? 0)
                            font.family: "Inter"
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.6)
                        }
                    }
                }
                
                // Playback controls with animations
                RowLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 2
                    spacing: 10
                    
                    // Previous button
                    Rectangle {
                        width: 48
                        height: 48
                        radius: 24
                        color: prevHover.containsMouse ? 
                               Qt.rgba(pywal.color1.r, pywal.color1.g, pywal.color1.b, 0.15) : 
                               Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.05)
                        
                        scale: prevHover.pressed ? 0.92 : 1.0
                        
                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                        
                        Behavior on scale {
                            NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: "󰒮"
                            font.family: "Material Design Icons"
                            font.pixelSize: 26
                            color: pywal.foreground
                        }
                        
                        MouseArea {
                            id: prevHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            
                            onClicked: {
                                if (selectedPlayer) {
                                    selectedPlayer.previous()
                                }
                            }
                        }
                    }
                    
                    // Play/Pause button (larger, prominent)
                    Rectangle {
                        width: 60
                        height: 60
                        radius: 30
                        color: pywal.color2
                        
                        scale: playHover.pressed ? 0.92 : (playHover.containsMouse ? 1.05 : 1.0)
                        
                        Behavior on scale {
                            NumberAnimation { duration: 150; easing.type: Easing.OutBack }
                        }
                        
                        // Pulsing effect when playing
                        Rectangle {
                            anchors.fill: parent
                            radius: parent.radius
                            color: pywal.color2
                            opacity: 0
                            
                            SequentialAnimation on opacity {
                                running: selectedPlayer?.isPlaying ?? false
                                loops: Animation.Infinite
                                NumberAnimation { from: 0; to: 0.3; duration: 1000; easing.type: Easing.OutCubic }
                                NumberAnimation { from: 0.3; to: 0; duration: 1000; easing.type: Easing.InCubic }
                            }
                            
                            SequentialAnimation on scale {
                                running: selectedPlayer?.isPlaying ?? false
                                loops: Animation.Infinite
                                NumberAnimation { from: 1.0; to: 1.15; duration: 1000; easing.type: Easing.OutCubic }
                                NumberAnimation { from: 1.15; to: 1.0; duration: 1000; easing.type: Easing.InCubic }
                            }
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: (selectedPlayer?.isPlaying ?? false) ? "󰏤" : "󰐊"
                            font.family: "Material Design Icons"
                            font.pixelSize: 36
                            color: pywal.background
                        }
                        
                        MouseArea {
                            id: playHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            
                            onClicked: {
                                if (selectedPlayer) {
                                    selectedPlayer.togglePlaying()
                                }
                            }
                        }
                    }
                    
                    // Next button
                    Rectangle {
                        width: 48
                        height: 48
                        radius: 24
                        color: nextHover.containsMouse ? 
                               Qt.rgba(pywal.color1.r, pywal.color1.g, pywal.color1.b, 0.15) : 
                               Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.05)
                        
                        scale: nextHover.pressed ? 0.92 : 1.0
                        
                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                        
                        Behavior on scale {
                            NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: "󰒭"
                            font.family: "Material Design Icons"
                            font.pixelSize: 26
                            color: pywal.foreground
                        }
                        
                        MouseArea {
                            id: nextHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            
                            onClicked: {
                                if (selectedPlayer) {
                                    selectedPlayer.next()
                                }
                            }
                        }
                    }
                }
                
                Item { Layout.fillHeight: true }
            }
        }
    }
    
    // Helper function to format time
    function formatTime(microseconds) {
        if (!microseconds || microseconds === 0 || microseconds < 0) {
            return "0:00"
        }
        const seconds = Math.floor(microseconds / 1000000)
        const mins = Math.floor(seconds / 60)
        const secs = seconds % 60
        return mins + ":" + (secs < 10 ? "0" : "") + secs
    }
}
