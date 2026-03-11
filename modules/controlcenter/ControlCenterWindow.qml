import QtQuick 6.10
import QtQuick.Layouts 6.10
import QtQuick.Controls 6.10
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../../services" as QsServices
import "../../config" as QsConfig
import "../../components"
import "../../components/effects"
import "components"

PanelWindow {
    id: root
    
    // Services
    readonly property var logger: QsServices.Logger
    readonly property var config: QsConfig.Config
    readonly property var pywal: QsServices.Pywal
    readonly property var network: QsServices.Network
    readonly property var bluetooth: QsServices.Bluetooth
    readonly property var audio: QsServices.Audio
    readonly property var brightness: QsServices.Brightness
    readonly property var mpris: QsServices.Players
    readonly property var notifs: QsServices.Notifs
    readonly property var systemUsage: QsServices.SystemUsage
    readonly property var powerProfiles: QsServices.PowerProfiles
    readonly property var screenshot: QsServices.Screenshot
    readonly property var idleInhibitor: QsServices.IdleInhibitor
    
    // Process launchers for header buttons
    Process {
        id: settingsProcess
        command: ["nm-connection-editor"]
        onStarted: root.shouldShow = false
    }
    
    Process {
        id: lockProcess
        command: ["loginctl", "lock-session"]
        onStarted: root.shouldShow = false
    }
    
    Process {
        id: powerProcess
        command: ["wlogout"]
        onStarted: root.shouldShow = false
    }

    Process {
        id: screenshotsProcess
        command: ["xdg-open", root.screenshot.screenshotsDir]
        onStarted: root.shouldShow = false
    }
    
    // Solid UI Color Tokens - Professional dark theme
    readonly property color cSurface: pywal.surfaceContainerHighest
    readonly property color cSurfaceContainer: pywal.surfaceContainerHigh
    readonly property color cSurfaceContainerHigh: pywal.surfaceContainerHigh
    readonly property color cBorder: pywal.outlineVariant
    readonly property color cPrimary: pywal.primary
    readonly property color cSecondary: pywal.secondary
    readonly property color cOnSurface: pywal.foreground
    readonly property color cOnSurfaceVariant: pywal.onSurfaceMuted
    readonly property color cOnSurfaceDim: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.5)
    
    screen: Quickshell.screens[0]
    
    anchors {
        top: true
        right: true
    }
    
    margins {
        right: 12
        top: 12
    }
    
    implicitWidth: 420
    implicitHeight: Math.min(860, screen.height - 40)
    color: "transparent"
    visible: shouldShow || panelContent.opacity > 0
    
    property bool shouldShow: false
    
    WlrLayershell.keyboardFocus: shouldShow ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    
    // Main Panel Container
    FocusScope {
        id: panelContent
        anchors.fill: parent
        
        transformOrigin: Item.TopRight
        property real revealOffsetX: root.shouldShow ? 0 : 20
        property real revealOffsetY: root.shouldShow ? 0 : -10
        scale: root.shouldShow ? 1.0 : 0.965
        opacity: root.shouldShow ? 1.0 : 0.0
        transform: Translate { x: panelContent.revealOffsetX; y: panelContent.revealOffsetY }
        
        focus: true
        
        Keys.onEscapePressed: root.shouldShow = false
        
        // Track if mouse has entered at least once
        property bool mouseHasEntered: false
        property bool mouseInside: hoverHandler.hovered
        
        // Reset when panel opens/closes
        Connections {
            target: root
            function onShouldShowChanged() {
                if (root.shouldShow) {
                    panelContent.mouseHasEntered = false
                    closeTimer.stop()
                }
            }
        }
        
        // Timer to delay close
        Timer {
            id: closeTimer
            interval: 400
            onTriggered: {
                if (!panelContent.mouseInside && panelContent.mouseHasEntered && root.shouldShow) {
                    root.shouldShow = false
                }
            }
        }
        
        // HoverHandler works regardless of child item stacking
        HoverHandler {
            id: hoverHandler
            onHoveredChanged: {
                if (hovered) {
                    panelContent.mouseHasEntered = true
                    closeTimer.stop()
                } else if (panelContent.mouseHasEntered && root.shouldShow) {
                    closeTimer.restart()
                }
            }
        }
        
        onVisibleChanged: {
            if (visible) forceActiveFocus()
        }
        
        MouseArea {
            anchors.fill: parent
            z: -1
            onClicked: root.shouldShow = false
        }
        
        Behavior on scale {
            NumberAnimation { duration: 260; easing.bezierCurve: [0.22, 1.0, 0.36, 1.0] }
        }

        Behavior on opacity {
            NumberAnimation { duration: 180; easing.bezierCurve: Material3Anim.standard }
        }

        Behavior on revealOffsetX {
            NumberAnimation { duration: 260; easing.bezierCurve: Material3Anim.emphasizedDecelerate }
        }

        Behavior on revealOffsetY {
            NumberAnimation { duration: 260; easing.bezierCurve: Material3Anim.emphasizedDecelerate }
        }
        
        // Main Panel Background
        AuroraSurface {
            id: panel
            anchors.fill: parent
            color: root.cSurface
            radius: 24
            strokeColor: root.cBorder
            clip: true
            accentColor: root.cPrimary
            elevation: 4
            highlighted: root.shouldShow
            
            Behavior on color {
                ColorAnimation {
                    duration: Material3Anim.medium2
                    easing.bezierCurve: Material3Anim.standard
                }
            }
            
            // Block clicks from passing through
            MouseArea {
                anchors.fill: parent
                onClicked: (mouse) => { mouse.accepted = true }
            }
            
            // Content Layout
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16
                
                // Header Section
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56
                    spacing: 12
                    
                    // Time & Date
                    ColumnLayout {
                        spacing: 2
                        
                        Text {
                            id: timeText
                            text: Qt.formatTime(new Date(), "hh:mm")
                            font.family: "Inter"
                            font.pixelSize: 32
                            font.weight: Font.Bold
                            color: root.cOnSurface
                        }
                        
                        Text {
                            text: Qt.formatDate(new Date(), "dddd, MMMM d")
                            font.family: "Inter"
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: root.cOnSurfaceVariant
                        }
                        
                        Timer {
                            interval: 1000
                            running: true
                            repeat: true
                            onTriggered: timeText.text = Qt.formatTime(new Date(), "hh:mm")
                        }
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    // Header Actions
                    RowLayout {
                        spacing: 6
                        
                        HeaderButton {
                            icon: "󰒓"
                            tooltip: "Network Settings"
                            onClicked: settingsProcess.running = true
                        }
                        HeaderButton {
                            icon: "󰍜"
                            tooltip: "Lock Screen"
                            onClicked: lockProcess.running = true
                        }
                        HeaderButton {
                            icon: "󰐥"
                            tooltip: "Power Menu"
                            onClicked: powerProcess.running = true
                        }
                    }
                }
                
                // Scrollable Content
                Flickable {
                    id: contentFlick
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                    contentHeight: contentColumn.height
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    flickDeceleration: 3000
                    maximumFlickVelocity: 2000
                    
                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                        width: 4
                        
                        contentItem: Rectangle {
                            radius: 2
                            color: Qt.rgba(root.cOnSurface.r, root.cOnSurface.g, root.cOnSurface.b, 0.2)
                        }
                    }
                    
                    ColumnLayout {
                        id: contentColumn
                        width: contentFlick.width
                        spacing: 14
                        
                        // Quick Toggles
                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2
                            columnSpacing: 10
                            rowSpacing: 10
                            
                            QuickToggle {
                                Layout.fillWidth: true
                                icon: "󰖩"
                                label: "Wi-Fi"
                                subLabel: root.network.connected ? root.network.ssid : "Disconnected"
                                active: root.network.wifiEnabled
                                activeColor: root.cPrimary
                                surfaceColor: root.cSurfaceContainerHigh
                                textColor: root.cOnSurface
                                onClicked: root.network.toggleWifi()
                            }
                            
                            QuickToggle {
                                Layout.fillWidth: true
                                icon: "󰂯"
                                label: "Bluetooth"
                                subLabel: root.bluetooth.powered ? "On" : "Off"
                                active: root.bluetooth.powered
                                activeColor: root.cPrimary
                                surfaceColor: root.cSurfaceContainerHigh
                                textColor: root.cOnSurface
                                onClicked: root.bluetooth.togglePower()
                            }
                            
                            QuickToggle {
                                Layout.fillWidth: true
                                icon: "󰔎"
                                label: "Do Not Disturb"
                                subLabel: root.notifs.dnd ? "On" : "Off"
                                active: root.notifs.dnd
                                activeColor: pywal.warning
                                surfaceColor: root.cSurfaceContainerHigh
                                textColor: root.cOnSurface
                                onClicked: root.notifs.toggleDnd()
                            }
                            
                            QuickToggle {
                                Layout.fillWidth: true
                                icon: "󰅶"
                                label: "Caffeine"
                                subLabel: root.idleInhibitor.inhibited ? "Active" : "Off"
                                active: root.idleInhibitor.inhibited
                                activeColor: pywal.info
                                surfaceColor: root.cSurfaceContainerHigh
                                textColor: root.cOnSurface
                                onClicked: root.idleInhibitor.inhibited = !root.idleInhibitor.inhibited
                            }
                            
                            QuickToggle {
                                Layout.fillWidth: true
                                Layout.columnSpan: 2
                                icon: "󰹑"
                                label: "Screenshot"
                                subLabel: "Capture Screen"
                                active: false
                                activeColor: root.cSecondary
                                surfaceColor: root.cSurfaceContainerHigh
                                textColor: root.cOnSurface
                                onClicked: root.screenshot.takeScreenshot("screen")
                            }

                            QuickToggle {
                                Layout.fillWidth: true
                                icon: root.screenshot.isRecording ? "󰛿" : "󰻃"
                                label: root.screenshot.isRecording ? "Stop Recording" : "Record Screen"
                                subLabel: root.screenshot.isRecording ? "Recording in progress" : "Start wf-recorder"
                                active: root.screenshot.isRecording
                                activeColor: pywal.error
                                surfaceColor: root.cSurfaceContainerHigh
                                textColor: root.cOnSurface
                                onClicked: {
                                    if (root.screenshot.isRecording)
                                        root.screenshot.stopRecording()
                                    else
                                        root.screenshot.startRecording()
                                }
                            }

                            QuickToggle {
                                Layout.fillWidth: true
                                icon: "󰉋"
                                label: "Open Captures"
                                subLabel: "Screenshots & recordings"
                                active: false
                                activeColor: root.cSecondary
                                surfaceColor: root.cSurfaceContainerHigh
                                textColor: root.cOnSurface
                                onClicked: screenshotsProcess.running = true
                            }
                        }
                        
                        // Divider
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            color: root.cBorder
                        }
                        
                        // Sliders Section
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            
                            VolumeSlider {
                                Layout.fillWidth: true
                                audio: root.audio
                                pywal: root.pywal
                            }
                            
                            BrightnessSlider {
                                Layout.fillWidth: true
                                brightness: root.brightness
                                pywal: root.pywal
                            }
                        }
                        
                        // Divider
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            color: root.cBorder
                        }
                        
                        // System Stats
                        SystemStats {
                            Layout.fillWidth: true
                            systemUsage: root.systemUsage
                            pywal: root.pywal
                        }
                        
                        // Media Card
                        MediaCard {
                            Layout.fillWidth: true
                            mpris: root.mpris
                            pywal: root.pywal
                        }
                        
                        // Notifications
                        NotificationList {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Math.min(260, Math.max(80, root.height - 600))
                            notifs: root.notifs
                            pywal: root.pywal
                        }
                        
                        // Bottom padding
                        Item { Layout.preferredHeight: 4 }
                    }
                }
            }
        }
    }
    
    // Header Button Component
    component HeaderButton: Rectangle {
        id: headerBtn
        property string icon
        property string tooltip: ""
        signal clicked()
        
        width: 40
        height: 40
        radius: 20
        color: headerBtnMouse.containsMouse 
            ? Qt.rgba(root.cOnSurface.r, root.cOnSurface.g, root.cOnSurface.b, 0.1) 
            : root.cSurfaceContainer
        
        Behavior on color {
            ColorAnimation {
                duration: Material3Anim.short3
                easing.bezierCurve: Material3Anim.standard
            }
        }
        
        scale: headerBtnMouse.pressed ? 0.92 : 1.0
        
        Behavior on scale {
            NumberAnimation {
                duration: Material3Anim.short2
                easing.bezierCurve: Material3Anim.standard
            }
        }
        
        Text {
            anchors.centerIn: parent
            text: headerBtn.icon
            font.family: "Material Design Icons"
            font.pixelSize: 18
            color: root.cOnSurface
        }
        
        MouseArea {
            id: headerBtnMouse
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked: headerBtn.clicked()
        }
        
        ToolTip.visible: headerBtnMouse.containsMouse && headerBtn.tooltip !== ""
        ToolTip.text: headerBtn.tooltip
        ToolTip.delay: 500
    }
}
