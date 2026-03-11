import QtQuick 6.10
import QtQuick.Layouts 6.10
import QtQuick.Controls 6.10
import QtQuick.Effects
import Quickshell
import "../../../components/effects"

Rectangle {
    id: root
    
    required property var mpris
    property var pywal
    
    // Get active player safely
    readonly property var activePlayer: mpris?.active ?? null
    readonly property bool hasPlayer: activePlayer !== null
    readonly property bool isPlaying: hasPlayer && (activePlayer.isPlaying ?? false)
    readonly property string trackTitle: hasPlayer ? (activePlayer.trackTitle ?? "Unknown") : ""
    readonly property string trackArtist: hasPlayer ? (activePlayer.trackArtist ?? "") : ""
    
    // Store art URL separately to prevent flickering - only update when we have a valid new URL
    property string artUrl: ""
    
    onActivePlayerChanged: updateArtUrl()
    
    // Connection to MPRIS service for when active player changes
    Connections {
        target: mpris
        function onActiveChanged() {
            root.updateArtUrl()
        }
    }
    
    Connections {
        target: activePlayer
        function onTrackArtUrlChanged() {
            root.updateArtUrl()
        }
        function onTrackTitleChanged() {
            root.updateArtUrl()
        }
    }
    
    function updateArtUrl() {
        if (activePlayer && activePlayer.trackArtUrl && activePlayer.trackArtUrl !== "") {
            artUrl = activePlayer.trackArtUrl
        }
    }
    
    // Color tokens
    readonly property color surfaceColor: pywal ? Qt.lighter(pywal.background, 1.12) : "#1e1e2e"
    readonly property color textColor: pywal ? pywal.foreground : "#dddddd"
    readonly property color textDim: pywal ? Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.7) : Qt.rgba(1, 1, 1, 0.7)
    readonly property color accentColor: pywal ? pywal.primary : "#a6e3a1"
    
    Layout.fillWidth: true
    Layout.preferredHeight: hasPlayer ? 100 : 0
    
    radius: 18
    color: surfaceColor
    clip: true
    visible: hasPlayer
    
    Behavior on Layout.preferredHeight {
        NumberAnimation {
            duration: Material3Anim.medium2
            easing.bezierCurve: Material3Anim.emphasizedDecelerate
        }
    }
    
    // Blurred album art background
    Image {
        id: bgImage
        anchors.fill: parent
        anchors.margins: -20
        source: root.artUrl
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        visible: false
    }
    
    MultiEffect {
        anchors.fill: parent
        source: bgImage
        blurEnabled: true
        blur: 1.0
        blurMax: 48
        saturation: 0.4
        brightness: -0.35
        opacity: bgImage.status === Image.Ready ? 1 : 0
        
        Behavior on opacity {
            NumberAnimation {
                duration: Material3Anim.medium4
                easing.bezierCurve: Material3Anim.standard
            }
        }
    }
    
    // Dark overlay for readability
    Rectangle {
        anchors.fill: parent
        color: pywal ? Qt.rgba(pywal.background.r, pywal.background.g, pywal.background.b, 0.4) : Qt.rgba(0, 0, 0, 0.3)
        visible: bgImage.status === Image.Ready
    }
    
    // Initial load timer - poll for artwork until found
    Timer {
        id: artworkPoller
        interval: 200
        repeat: true
        running: root.hasPlayer && root.artUrl === ""
        property int attempts: 0
        onTriggered: {
            root.updateArtUrl()
            attempts++
            if (attempts > 25 || root.artUrl !== "") {
                running = false
                attempts = 0
            }
        }
    }
    
    // Delayed initialization to ensure MPRIS data is ready
    Timer {
        id: initTimer
        interval: 100
        running: true
        repeat: false
        onTriggered: {
            root.updateArtUrl()
            // Start artwork poller if still no art
            if (root.hasPlayer && root.artUrl === "") {
                artworkPoller.running = true
            }
        }
    }
    
    Component.onCompleted: {
        // Immediate attempt
        updateArtUrl()
    }
    
    // Content
    RowLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 14
        
        // Album Art
        Rectangle {
            Layout.preferredWidth: 72
            Layout.preferredHeight: 72
            radius: 12
            color: Qt.rgba(1, 1, 1, 0.1)
            clip: true
            
            // Shadow
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: Qt.rgba(0, 0, 0, 0.4)
                shadowBlur: 0.3
                shadowVerticalOffset: 2
            }
            
            Image {
                id: albumArt
                anchors.fill: parent
                source: root.artUrl
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                
                opacity: status === Image.Ready ? 1 : 0
                
                Behavior on opacity {
                    NumberAnimation {
                        duration: Material3Anim.short4
                        easing.bezierCurve: Material3Anim.standard
                    }
                }
            }
            
            // Placeholder
            Text {
                anchors.centerIn: parent
                text: "󰝚"
                font.family: "Material Design Icons"
                font.pixelSize: 32
                color: pywal ? Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.3) : Qt.rgba(1, 1, 1, 0.3)
                visible: albumArt.status !== Image.Ready
            }
        }
        
        // Track Info
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 4
            
            Item { Layout.fillHeight: true }
            
            Text {
                Layout.fillWidth: true
                text: root.trackTitle || "No Media"
                font.family: "Inter"
                font.pixelSize: 15
                font.weight: Font.Bold
                color: root.textColor
                elide: Text.ElideRight
                maximumLineCount: 1
                
                // Text shadow for readability
                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: Qt.rgba(0, 0, 0, 0.5)
                    shadowBlur: 0.2
                }
            }
            
            Text {
                Layout.fillWidth: true
                text: root.trackArtist
                font.family: "Inter"
                font.pixelSize: 13
                color: root.textDim
                elide: Text.ElideRight
                maximumLineCount: 1
                visible: text !== ""
                
                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: Qt.rgba(0, 0, 0, 0.5)
                    shadowBlur: 0.2
                }
            }
            
            Item { Layout.fillHeight: true }
        }
        
        // Controls
        RowLayout {
            spacing: 2
            
            // Previous
            ControlButton {
                icon: "󰒮"
                onClicked: {
                    if (root.activePlayer) root.activePlayer.previous()
                }
            }
            
            // Play/Pause - Main button
            Rectangle {
                id: playBtn
                width: 48
                height: 48
                radius: 24
                color: root.accentColor
                
                scale: playMouse.pressed ? 0.92 : (playMouse.containsMouse ? 1.05 : 1.0)
                
                Behavior on scale {
                    NumberAnimation {
                        duration: Material3Anim.short2
                        easing.bezierCurve: Material3Anim.standard
                    }
                }
                
                // Glow effect
                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: root.accentColor
                    shadowBlur: 0.4
                    shadowOpacity: 0.5
                }
                
                Text {
                    anchors.centerIn: parent
                    text: root.isPlaying ? "󰏤" : "󰐊"
                    font.family: "Material Design Icons"
                    font.pixelSize: 24
                    color: pywal ? pywal.background : Qt.rgba(0, 0, 0, 0.9)
                }
                
                MouseArea {
                    id: playMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: {
                        if (root.activePlayer) root.activePlayer.togglePlaying()
                    }
                }
            }
            
            // Next
            ControlButton {
                icon: "󰒭"
                onClicked: {
                    if (root.activePlayer) root.activePlayer.next()
                }
            }
        }
    }
    
    component ControlButton: Rectangle {
        property string icon
        signal clicked()
        
        width: 40
        height: 40
        radius: 20
        color: btnMouse.containsMouse 
            ? Qt.rgba(1, 1, 1, 0.15) 
            : Qt.rgba(1, 1, 1, 0.05)
        
        scale: btnMouse.pressed ? 0.9 : 1.0
        
        Behavior on color {
            ColorAnimation {
                duration: Material3Anim.short3
                easing.bezierCurve: Material3Anim.standard
            }
        }
        
        Behavior on scale {
            NumberAnimation {
                duration: Material3Anim.short2
                easing.bezierCurve: Material3Anim.standard
            }
        }
        
        Text {
            anchors.centerIn: parent
            text: parent.icon
            font.family: "Material Design Icons"
            font.pixelSize: 22
            color: root.textColor
        }
        
        MouseArea {
            id: btnMouse
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked: parent.clicked()
        }
    }
}
