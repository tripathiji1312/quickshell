import QtQuick 6.10
import QtQuick.Layouts 6.10
import QtQuick.Controls 6.10
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../../services" as QsServices
import "../../components/effects" as Effects

// Material 3 Expressive System Dashboard
PanelWindow {
    id: root
    
    property bool shouldShow: false
    
    // Use centralized UI state
    readonly property var uiState: QsServices.UIState
    readonly property var logger: QsServices.Logger
    
    // Sync with UIState
    onShouldShowChanged: {
        logger.debug("ControlCenter", "shouldShow changed to: " + shouldShow)
        uiState.controlCenterOpen = shouldShow
    }
    
    Connections {
        target: uiState
        function onControlCenterOpenChanged() {
            if (uiState.controlCenterOpen !== root.shouldShow) {
                root.shouldShow = uiState.controlCenterOpen
            }
        }
    }
    
    readonly property var pywal: QsServices.Pywal
    readonly property var network: QsServices.Network
    readonly property var audio: QsServices.Audio
    readonly property var brightness: QsServices.Brightness
    readonly property var systemUsage: QsServices.SystemUsage
    readonly property var time: QsServices.Time
    readonly property var notifs: QsServices.Notifs
    readonly property var players: QsServices.Players
    readonly property var idleInhibitor: QsServices.IdleInhibitor
    readonly property var settings: QsServices.Settings
    readonly property var powerProfiles: QsServices.PowerProfiles
    readonly property var screenshot: QsServices.Screenshot
    
    // Material 3 colors
    readonly property color m3Surface: Qt.rgba(pywal.background.r, pywal.background.g, pywal.background.b, 1.0)
    readonly property color m3SurfaceContainer: Qt.rgba(
        pywal.background.r * 1.08,
        pywal.background.g * 1.08,
        pywal.background.b * 1.08,
        1.0
    )
    readonly property color m3Primary: pywal.color4 ?? "#a6e3a1"
    readonly property color m3OnSurface: pywal.foreground
    readonly property color m3OnSurfaceVariant: Qt.rgba(
        pywal.foreground.r * 0.7,
        pywal.foreground.g * 0.7,
        pywal.foreground.b * 0.7,
        1.0
    )
    
    screen: Quickshell.screens[0]
    
    anchors {
        top: true
        right: true
    }
    
    margins {
        right: 4
        top: 4
    }
    
    implicitWidth: 700
    implicitHeight: 1000
    color: "transparent"
    visible: shouldShow || dashboardContainer.opacity > 0
    
    // PanelWindow doesn't support Keys directly - will add to content item
    
    onVisibleChanged: {
        logger.debug("ControlCenter", "visible changed to: " + visible)
    }
    
    Component.onCompleted: {
        logger.info("ControlCenter", "Component loaded successfully")
        console.log("🎛️ [ControlCenter] Window created, shouldShow:", shouldShow)
    }
    
    // Don't use FileView for toggle - causes warnings
    // Keybind toggle handler via file - DISABLED (use direct binding instead)
    // FileView {
    //     path: "/tmp/quickshell-cc-toggle"
    //     watchChanges: true
    //     onFileChanged: {
    //         logger.debug("ControlCenter", "Toggle keybind triggered")
    //         root.shouldShow = !root.shouldShow
    //     }
    // }
    
    // Dashboard Panel
    Item {
        id: dashboardContainer
        
        anchors.fill: parent
        
        transformOrigin: Item.TopRight
        scale: 0.85
        opacity: 0
        
        // Enable keyboard support - must be actively focused
        focus: true
        activeFocusOnTab: true
        
        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Escape) {
                logger.debug("ControlCenter", "Escape pressed - closing")
                root.shouldShow = false
                event.accepted = true
            }
        }
        
        onVisibleChanged: {
            if (visible) {
                forceActiveFocus()
                logger.debug("ControlCenter", "Dashboard container got focus")
            }
        }
        
        // Click outside dashboard to close - placed at root level
        MouseArea {
            anchors.fill: parent
            z: -1  // Behind the dashboard
            onClicked: {
                logger.debug("ControlCenter", "Background clicked - closing")
                root.shouldShow = false
            }
            enabled: root.shouldShow
        }
        
        // Material 3 Expressive entrance animation
        SequentialAnimation {
            running: root.shouldShow
            ParallelAnimation {
                NumberAnimation {
                    target: dashboardContainer
                    property: "scale"
                    from: 0.7
                    to: 1.08
                    duration: Effects.Material3Anim.medium3
                    easing.type: Easing.Bezier
                    easing.bezierCurve: Effects.Material3Anim.emphasizedDecelerate
                }
                NumberAnimation {
                    target: dashboardContainer
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: Effects.Material3Anim.medium2
                    easing.type: Easing.Bezier
                    easing.bezierCurve: Effects.Material3Anim.emphasizedDecelerate
                }
            }
            NumberAnimation {
                target: dashboardContainer
                property: "scale"
                to: 1.0
                duration: Effects.Material3Anim.medium1
                easing.type: Easing.OutBack
                easing.overshoot: 1.7
            }
        }
        
        // Material 3 Expressive exit animation
        ParallelAnimation {
            running: !root.shouldShow && dashboardContainer.opacity > 0
            NumberAnimation {
                target: dashboardContainer
                property: "scale"
                to: 0.85
                duration: Effects.Material3Anim.medium1
                easing.type: Easing.Bezier
                easing.bezierCurve: Effects.Material3Anim.emphasizedAccelerate
            }
            NumberAnimation {
                target: dashboardContainer
                property: "opacity"
                to: 0
                duration: Effects.Material3Anim.medium1
                easing.type: Easing.Bezier
                easing.bezierCurve: Effects.Material3Anim.emphasizedAccelerate
            }
        }
        
        // Elevated shadow
        Rectangle {
            anchors.fill: dashboard
            anchors.margins: -10
            radius: dashboard.radius + 5
            color: "transparent"
            
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: Qt.rgba(0, 0, 0, 0.45)
                shadowBlur: 1.2
                shadowVerticalOffset: 14
            }
        }
    
        Rectangle {
            id: dashboard
            anchors.fill: parent
            color: root.m3Surface
            radius: 24
            z: 1  // In front of background MouseArea
            
            border.color: Qt.rgba(root.m3Primary.r, root.m3Primary.g, root.m3Primary.b, 0.3)
            border.width: 1
            
            // Prevent clicks from propagating to background
            MouseArea {
                anchors.fill: parent
                onClicked: (mouse) => {
                    // Accept the event to stop propagation
                    mouse.accepted = true
                }
                onPressed: (mouse) => {
                    mouse.accepted = true
                }
            }
            
            // Main content with ScrollView
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16  // Reduced from 20
                spacing: 12  // Reduced from 16
                
                // Header with time and close button
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16
                    
                    ColumnLayout {
                        spacing: 2
                        
                        Text {
                            text: Qt.formatTime(time.date, "hh:mm")
                            font.family: "Inter"
                            font.pixelSize: 36  // Reduced from 42
                            font.weight: Font.Bold
                            color: root.m3OnSurface
                        }
                        
                        Text {
                            text: Qt.formatDate(time.date, "dddd, MMMM d")
                            font.family: "Inter"
                            font.pixelSize: 12  // Reduced from 14
                            font.weight: Font.Medium
                            color: root.m3OnSurfaceVariant
                        }
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    // Close button
                    Rectangle {
                        Layout.preferredWidth: 40  // Reduced from 44
                        Layout.preferredHeight: 40
                        radius: 20
                        color: hoverArea.containsMouse ? 
                               Qt.rgba(root.m3Primary.r, root.m3Primary.g, root.m3Primary.b, 0.15) : 
                               "transparent"
                        clip: true
                        
                        Behavior on color {
                            ColorAnimation {
                                duration: Effects.Material3Anim.short4
                                easing.type: Easing.OutCubic
                            }
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: "󰅖"
                            font.family: "Material Design Icons"
                            font.pixelSize: 24
                            color: root.m3OnSurface
                        }
                        
                        // Material 3 ripple effect
                        Effects.RippleEffect {
                            id: closeRipple
                            anchors.fill: parent
                            rippleColor: Qt.rgba(root.m3Primary.r, root.m3Primary.g, root.m3Primary.b, 0.3)
                            centered: true
                        }
                        
                        MouseArea {
                            id: hoverArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                closeRipple.triggerCentered()
                                root.shouldShow = false
                            }
                        }
                    }
                }
                
                // Quick toggles row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    
                    // WiFi toggle with connection status and network speed
                    QuickToggle {
                        Layout.fillWidth: true
                        icon: network.connected ? "󰖩" : "󰖪"
                        label: network.ssid || "WiFi"
                        sublabel: {
                            if (!network.connected) return "Disconnected"
                            const downMBps = (systemUsage.downloadSpeed / 1024 / 1024).toFixed(1)
                            const upMBps = (systemUsage.uploadSpeed / 1024 / 1024).toFixed(1)
                            return `↓ ${downMBps} MB/s  ↑ ${upMBps} MB/s`
                        }
                        active: network.wifiEnabled
                        primaryColor: pywal.color5
                        onClicked: network.toggleWifi()
                    }
                    
                    // Bluetooth toggle with device name
                    QuickToggle {
                        Layout.fillWidth: true
                        icon: network.bluetoothConnected ? "󰂯" : "󰂲"
                        label: "Bluetooth"
                        sublabel: network.bluetoothDeviceName || "Not Connected"
                        active: network.bluetoothConnected
                        primaryColor: pywal.color6
                        onClicked: {
                            // Toggle bluetooth via bluetoothctl
                            if (network.bluetoothConnected) {
                                Qt.callLater(() => {
                                    const proc = Qt.createQmlObject('import Quickshell.Io; Process { command: ["bluetoothctl", "disconnect"]; running: true }', root)
                                })
                            }
                        }
                    }
                    
                    // DND toggle
                    QuickToggle {
                        Layout.fillWidth: true
                        icon: notifs.dnd ? "󰂛" : "󰂚"
                        label: "DND"
                        sublabel: notifs.dnd ? "On" : "Off"
                        active: notifs.dnd
                        primaryColor: pywal.color1
                        onClicked: {
                            notifs.toggleDnd()
                            console.log("🔕 DND toggled:", notifs.dnd)
                        }
                    }
                    
                    // Idle Inhibitor toggle
                    QuickToggle {
                        Layout.fillWidth: true
                        icon: idleInhibitor.inhibited ? "󰅶" : "󰾪"
                        label: "Caffeine"
                        sublabel: idleInhibitor.inhibited ? "On" : "Off"
                        active: idleInhibitor.inhibited
                        primaryColor: pywal.color3
                        onClicked: {
                            idleInhibitor.inhibited = !idleInhibitor.inhibited
                            console.log("☕ Caffeine toggled:", idleInhibitor.inhibited)
                        }
                    }
                }
                
                // Second row of quick toggles
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    
                    // Power Profile toggle (cycles through profiles)
                    QuickToggle {
                        Layout.fillWidth: true
                        icon: powerProfiles.getProfileIcon(powerProfiles.activeProfile)
                        label: "Power"
                        sublabel: powerProfiles.getProfileLabel(powerProfiles.activeProfile)
                        active: powerProfiles.activeProfile === "performance"
                        primaryColor: {
                            switch(powerProfiles.activeProfile) {
                                case "performance": return pywal.color1  // Red
                                case "balanced": return pywal.color2  // Green
                                case "power-saver": return pywal.color4  // Blue
                                default: return pywal.color5
                            }
                        }
                        visible: powerProfiles.isAvailable
                        onClicked: {
                            // Cycle: balanced -> performance -> power-saver -> balanced
                            if (powerProfiles.activeProfile === "balanced") {
                                powerProfiles.setProfile("performance")
                            } else if (powerProfiles.activeProfile === "performance") {
                                powerProfiles.setProfile("power-saver")
                            } else {
                                powerProfiles.setProfile("balanced")
                            }
                        }
                    }
                    
                    // Screenshot toggle
                    QuickToggle {
                        Layout.fillWidth: true
                        icon: "󰄀"
                        label: "Screenshot"
                        sublabel: "Click to capture"
                        active: false
                        primaryColor: pywal.color6
                        onClicked: {
                            screenshot.takeScreenshot("region")
                        }
                    }
                    
                    // Focus Mode toggle
                    QuickToggle {
                        Layout.fillWidth: true
                        icon: settings.focusModeEnabled ? "󱫟" : "󱫠"
                        label: "Focus"
                        sublabel: settings.focusModeEnabled ? `${settings.focusModeMinutesLeft}m left` : "Off"
                        active: settings.focusModeEnabled
                        primaryColor: pywal.color13
                        onClicked: {
                            settings.focusModeEnabled = !settings.focusModeEnabled
                            if (settings.focusModeEnabled) {
                                settings.focusModeMinutesLeft = 25  // Default Pomodoro
                                notifs.dnd = true
                            } else {
                                notifs.dnd = false
                            }
                        }
                    }
                    
                    // Screen Recording toggle
                    QuickToggle {
                        Layout.fillWidth: true
                        icon: screenshot.isRecording ? "󰻃" : "󰹑"
                        label: screenshot.isRecording ? "Stop Rec" : "Record"
                        sublabel: screenshot.isRecording ? "Recording..." : "Screen record"
                        active: screenshot.isRecording
                        primaryColor: pywal.color9
                        onClicked: {
                            if (screenshot.isRecording) {
                                screenshot.stopRecording()
                            } else {
                                screenshot.startRecording()
                            }
                        }
                    }
                }
                
                // Focus Mode Timer (when active)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50  // Reduced from 60
                    radius: 16
                    color: Qt.rgba(pywal.color13.r, pywal.color13.g, pywal.color13.b, 0.15)
                    border.color: Qt.rgba(pywal.color13.r, pywal.color13.g, pywal.color13.b, 0.3)
                    border.width: 1
                    visible: settings.focusModeEnabled
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 12
                        
                        Text {
                            text: "󱫟"
                            font.family: "Material Design Icons"
                            font.pixelSize: 28
                            color: pywal.color13
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            
                            Text {
                                text: "Focus Mode Active"
                                font.family: "Inter"
                                font.pixelSize: 14
                                font.weight: Font.Bold
                                color: root.m3OnSurface
                            }
                            
                            Text {
                                text: `${settings.focusModeMinutesLeft} minutes remaining • DND enabled`
                                font.family: "Inter"
                                font.pixelSize: 12
                                color: root.m3OnSurfaceVariant
                            }
                        }
                        
                        // Add time buttons
                        RowLayout {
                            spacing: 8
                            
                            Rectangle {
                                width: 32
                                height: 32
                                radius: 16
                                color: Qt.rgba(root.m3OnSurface.r, root.m3OnSurface.g, root.m3OnSurface.b, 0.1)
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "+"
                                    font.family: "Inter"
                                    font.pixelSize: 18
                                    font.weight: Font.Bold
                                    color: root.m3OnSurface
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: settings.focusModeMinutesLeft += 5
                                }
                            }
                            
                            Rectangle {
                                width: 32
                                height: 32
                                radius: 16
                                color: Qt.rgba(root.m3OnSurface.r, root.m3OnSurface.g, root.m3OnSurface.b, 0.1)
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "−"
                                    font.family: "Inter"
                                    font.pixelSize: 18
                                    font.weight: Font.Bold
                                    color: root.m3OnSurface
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: settings.focusModeMinutesLeft = Math.max(1, settings.focusModeMinutesLeft - 5)
                                }
                            }
                        }
                    }
                    
                    // Focus mode countdown timer
                    Timer {
                        running: settings.focusModeEnabled && settings.focusModeMinutesLeft > 0
                        interval: 60000  // 1 minute
                        repeat: true
                        onTriggered: {
                            settings.focusModeMinutesLeft--
                            if (settings.focusModeMinutesLeft <= 0) {
                                settings.focusModeEnabled = false
                                notifs.dnd = false
                                
                                // Show notification
                                const notifyProc = Qt.createQmlObject('import Quickshell.Io; Process { command: ["notify-send", "-u", "normal", "Focus Mode Complete", "Great work! Time for a break."]; running: true }', root)
                            }
                        }
                    }
                }
                
                // Network Traffic Graph
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80  // Reduced from 100
                    radius: 16
                    color: root.m3SurfaceContainer
                    border.color: Qt.rgba(root.m3Primary.r, root.m3Primary.g, root.m3Primary.b, 0.15)
                    border.width: 1
                    visible: network.connected && systemUsage.networkHistory.length > 0
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 8
                        
                        // Header
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            
                            Text {
                                text: "󰓅"
                                font.family: "Material Design Icons"
                                font.pixelSize: 16
                                color: pywal.color5
                            }
                            
                            Text {
                                text: "Network Traffic (60s)"
                                font.family: "Inter"
                                font.pixelSize: 12
                                font.weight: Font.Bold
                                color: root.m3OnSurface
                            }
                            
                            Item { Layout.fillWidth: true }
                            
                            RowLayout {
                                spacing: 12
                                
                                // Download legend
                                RowLayout {
                                    spacing: 4
                                    Rectangle {
                                        width: 12
                                        height: 2
                                        color: pywal.color2
                                    }
                                    Text {
                                        text: "↓ Download"
                                        font.family: "Inter"
                                        font.pixelSize: 9
                                        color: root.m3OnSurfaceVariant
                                    }
                                }
                                
                                // Upload legend
                                RowLayout {
                                    spacing: 4
                                    Rectangle {
                                        width: 12
                                        height: 2
                                        color: pywal.color6
                                    }
                                    Text {
                                        text: "↑ Upload"
                                        font.family: "Inter"
                                        font.pixelSize: 9
                                        color: root.m3OnSurfaceVariant
                                    }
                                }
                            }
                        }
                        
                        // Graph canvas
                        Canvas {
                            id: networkCanvas
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            
                            property var dataPoints: systemUsage.networkHistory
                            property int maxPoints: 30
                            
                            onDataPointsChanged: requestPaint()
                            
                            onPaint: {
                                const ctx = getContext("2d")
                                const w = width
                                const h = height
                                
                                // Clear canvas
                                ctx.clearRect(0, 0, w, h)
                                
                                if (!dataPoints || dataPoints.length < 2) return
                                
                                // Calculate max for scaling
                                let maxVal = 1024 * 1024  // 1 MB/s minimum
                                dataPoints.forEach(point => {
                                    maxVal = Math.max(maxVal, point.download, point.upload)
                                })
                                
                                const pointSpacing = w / Math.max(1, maxPoints - 1)
                                const scale = h / maxVal
                                
                                // Draw download line (green)
                                ctx.beginPath()
                                ctx.strokeStyle = pywal.color2.toString()
                                ctx.lineWidth = 2
                                ctx.lineJoin = "round"
                                
                                dataPoints.forEach((point, i) => {
                                    const x = i * pointSpacing
                                    const y = h - (point.download * scale)
                                    
                                    if (i === 0) {
                                        ctx.moveTo(x, y)
                                    } else {
                                        ctx.lineTo(x, y)
                                    }
                                })
                                ctx.stroke()
                                
                                // Draw upload line (blue)
                                ctx.beginPath()
                                ctx.strokeStyle = pywal.color6.toString()
                                ctx.lineWidth = 2
                                ctx.lineJoin = "round"
                                
                                dataPoints.forEach((point, i) => {
                                    const x = i * pointSpacing
                                    const y = h - (point.upload * scale)
                                    
                                    if (i === 0) {
                                        ctx.moveTo(x, y)
                                    } else {
                                        ctx.lineTo(x, y)
                                    }
                                })
                                ctx.stroke()
                            }
                            
                            Connections {
                                target: systemUsage
                                function onNetworkHistoryChanged() {
                                    networkCanvas.requestPaint()
                                }
                            }
                        }
                    }
                }
                
                // Volume and Brightness sliders
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    
                    // Volume slider card
                    SliderCard {
                        Layout.fillWidth: true
                        icon: audio.muted ? "󰖁" : "󰕾"
                        label: "Volume"
                        value: (audio.volume ?? 0)
                        primaryColor: pywal.color4
                        onSliderMoved: newValue => {
                            audio.setVolume(newValue)
                        }
                        onIconClicked: {
                            audio.toggleMute()
                        }
                    }
                    
                    // Brightness slider card
                    SliderCard {
                        Layout.fillWidth: true
                        icon: "󰃠"
                        label: "Brightness"
                        value: (brightness.level ?? 0)
                        primaryColor: pywal.color3
                        onSliderMoved: newValue => {
                            brightness.setBrightness(newValue)
                        }
                    }
                }
                
                // System resources row - COMPACT (FIXED HEIGHT)
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    Layout.maximumHeight: 50
                    spacing: 8
                    
                    // CPU card
                    SystemCard {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        Layout.maximumHeight: 50
                        icon: "󰘚"
                        label: "CPU"
                        value: Math.round((systemUsage.cpuPerc ?? 0) * 100)
                        unit: "%"
                        progress: systemUsage.cpuPerc ?? 0
                        primaryColor: pywal.color1
                    }
                    
                    // Memory card
                    SystemCard {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        Layout.maximumHeight: 50
                        icon: "󰍛"
                        label: "RAM"
                        value: Math.round((systemUsage.memPerc ?? 0) * 100)
                        unit: "%"
                        progress: systemUsage.memPerc ?? 0
                        primaryColor: pywal.color2
                    }
                    
                    // Storage card
                    SystemCard {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        Layout.maximumHeight: 50
                        icon: "󰋊"
                        label: "Disk"
                        value: Math.round((systemUsage.diskPerc ?? 0) * 100)
                        unit: "%"
                        progress: systemUsage.diskPerc ?? 0
                        primaryColor: pywal.color3
                    }
                    
                    // GPU card (only visible if GPU detected)
                    SystemCard {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        Layout.maximumHeight: 50
                        icon: "󰢮"
                        label: "GPU"
                        value: Math.round(systemUsage.gpuUsage ?? 0)
                        unit: "%"
                        progress: (systemUsage.gpuUsage ?? 0) / 100
                        primaryColor: pywal.color4
                        visible: systemUsage.hasGpu
                    }
                }
                
                // Top CPU Processes section
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: contentCol.implicitHeight + 24
                    radius: 16
                    color: root.m3SurfaceContainer
                    border.color: Qt.rgba(root.m3Primary.r, root.m3Primary.g, root.m3Primary.b, 0.15)
                    border.width: 1
                    visible: systemUsage.topProcesses.length > 0
                    
                    ColumnLayout {
                        id: contentCol
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 8
                        
                        // Header
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            
                            Text {
                                text: "󰓅"
                                font.family: "Material Design Icons"
                                font.pixelSize: 18
                                color: pywal.color1
                            }
                            
                            Text {
                                text: "Top Processes"
                                font.family: "Inter"
                                font.pixelSize: 13
                                font.weight: Font.Bold
                                color: root.m3OnSurface
                            }
                            
                            Item { Layout.fillWidth: true }
                        }
                        
                        // Process list
                        Repeater {
                            model: systemUsage.topProcesses
                            
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 32
                                radius: 8
                                color: processHover.containsMouse ? 
                                       Qt.rgba(root.m3OnSurface.r, root.m3OnSurface.g, root.m3OnSurface.b, 0.05) : 
                                       "transparent"
                                
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 8
                                    spacing: 12
                                    
                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.name
                                        font.family: "JetBrains Mono"
                                        font.pixelSize: 11
                                        color: root.m3OnSurface
                                        elide: Text.ElideRight
                                    }
                                    
                                    Rectangle {
                                        Layout.preferredWidth: 50
                                        Layout.preferredHeight: 18
                                        radius: 9
                                        color: Qt.rgba(pywal.color1.r, pywal.color1.g, pywal.color1.b, 0.2)
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.cpu.toFixed(1) + "%"
                                            font.family: "Inter"
                                            font.pixelSize: 10
                                            font.weight: Font.Medium
                                            color: pywal.color1
                                        }
                                    }
                                    
                                    // Kill button
                                    Rectangle {
                                        Layout.preferredWidth: 24
                                        Layout.preferredHeight: 24
                                        radius: 12
                                        color: killHover.containsMouse ? 
                                               Qt.rgba(pywal.color1.r, pywal.color1.g, pywal.color1.b, 0.2) : 
                                               "transparent"
                                        visible: processHover.containsMouse
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: "󰅖"
                                            font.family: "Material Design Icons"
                                            font.pixelSize: 14
                                            color: pywal.color1
                                        }
                                        
                                        MouseArea {
                                            id: killHover
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                console.log("🔪 [ProcessExplorer] Killing process:", modelData.pid, modelData.name)
                                                killProc.exec(["kill", modelData.pid.toString()])
                                            }
                                        }
                                    }
                                }
                                
                                MouseArea {
                                    id: processHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                }
                            }
                        }
                    }
                    
                    // Kill process handler
                    Process {
                        id: killProc
                        
                        onExited: {
                            systemUsage.updateTopProcesses()
                        }
                    }
                }
                
                // Media player section - Material 3 Expressive with Album Art Blur
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 120
                    Layout.maximumHeight: 120
                    radius: 16
                    color: "transparent"
                    visible: players.active !== null
                    clip: true
                    
                    // Blurred album art backdrop
                    Image {
                        id: backdropImage
                        anchors.fill: parent
                        source: players.active?.trackArtUrl ?? ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        visible: false
                        
                        Behavior on source {
                            SequentialAnimation {
                                NumberAnimation { target: backdropImage; property: "opacity"; to: 0; duration: 150 }
                                PropertyAction { target: backdropImage; property: "source" }
                                NumberAnimation { target: backdropImage; property: "opacity"; to: 1; duration: 150 }
                            }
                        }
                    }
                    
                    // Blur effect layer
                    MultiEffect {
                        anchors.fill: parent
                        source: backdropImage
                        blur: 1.0
                        blurEnabled: true
                        blurMax: 64
                        saturation: 0.4
                        brightness: -0.3
                    }
                    
                    // Semi-transparent overlay for contrast
                    Rectangle {
                        anchors.fill: parent
                        color: Qt.rgba(root.m3Surface.r, root.m3Surface.g, root.m3Surface.b, 0.75)
                    }
                    
                    // Player switcher (visible when multiple players)
                    Rectangle {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.margins: 8
                        width: playerNameText.implicitWidth + 16
                        height: 28
                        radius: 14
                        color: Qt.rgba(root.m3Primary.r, root.m3Primary.g, root.m3Primary.b, 0.15)
                        visible: players.list.length > 1
                        
                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 6
                            
                            Text {
                                text: "󰐹"
                                font.family: "Material Design Icons"
                                font.pixelSize: 14
                                color: root.m3Primary
                            }
                            
                            Text {
                                id: playerNameText
                                text: players.getIdentity(players.active)
                                font.family: "Inter"
                                font.pixelSize: 11
                                font.weight: Font.Medium
                                color: root.m3OnSurface
                            }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                // Cycle to next player
                                const currentIndex = players.list.indexOf(players.active)
                                const nextIndex = (currentIndex + 1) % players.list.length
                                players.active = players.list[nextIndex]
                            }
                        }
                    }
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 16
                        
                        // Album art with glow
                        Item {
                            Layout.preferredWidth: 110
                            Layout.preferredHeight: 110
                            
                            // Glow effect
                            Rectangle {
                                anchors.centerIn: albumArt
                                width: albumArt.width + 8
                                height: albumArt.height + 8
                                radius: 16
                                color: "transparent"
                                border.color: Qt.rgba(root.m3Primary.r, root.m3Primary.g, root.m3Primary.b, 0.4)
                                border.width: 2
                                
                                layer.enabled: true
                                layer.effect: MultiEffect {
                                    shadowEnabled: true
                                    shadowColor: root.m3Primary
                                    shadowBlur: 0.8
                                    shadowVerticalOffset: 0
                                    shadowHorizontalOffset: 0
                                }
                            }
                            
                            Rectangle {
                                id: albumArt
                                anchors.centerIn: parent
                                width: 110
                                height: 110
                                radius: 12
                                color: Qt.rgba(root.m3OnSurface.r, root.m3OnSurface.g, root.m3OnSurface.b, 0.15)
                                clip: true
                                
                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 0
                                    source: players.active?.trackArtUrl ?? ""
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    visible: status === Image.Ready
                                    smooth: true
                                    
                                    Behavior on source {
                                        SequentialAnimation {
                                            NumberAnimation { property: "opacity"; to: 0; duration: 150 }
                                            PropertyAction { property: "source" }
                                            NumberAnimation { property: "opacity"; to: 1; duration: 150 }
                                        }
                                    }
                                }
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "󰝚"
                                    font.family: "Material Design Icons"
                                    font.pixelSize: 48
                                    color: root.m3OnSurfaceVariant
                                    visible: !players.active?.trackArtUrl
                                }
                            }
                        }
                        
                        // Track info and controls
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 12
                            
                            // Track information
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 6
                                
                                Text {
                                    Layout.fillWidth: true
                                    text: players.active?.trackTitle ?? "No media playing"
                                    font.family: "Inter"
                                    font.pixelSize: 18
                                    font.weight: Font.Bold
                                    color: root.m3OnSurface
                                    elide: Text.ElideRight
                                    maximumLineCount: 2
                                    wrapMode: Text.Wrap
                                }
                                
                                Text {
                                    Layout.fillWidth: true
                                    text: players.active?.trackArtist ?? ""
                                    font.family: "Inter"
                                    font.pixelSize: 14
                                    color: root.m3OnSurfaceVariant
                                    elide: Text.ElideRight
                                }
                                
                                Text {
                                    Layout.fillWidth: true
                                    text: players.active?.trackAlbum ?? ""
                                    font.family: "Inter"
                                    font.pixelSize: 12
                                    color: Qt.rgba(root.m3OnSurfaceVariant.r, root.m3OnSurfaceVariant.g, root.m3OnSurfaceVariant.b, 0.7)
                                    elide: Text.ElideRight
                                    visible: text !== ""
                                }
                            }
                            
                            Item { Layout.fillHeight: true }
                            
                            // Duration and position display
                            RowLayout {
                                Layout.fillWidth: true
                                visible: players.active?.length > 0
                                spacing: 8
                                
                                Text {
                                    text: {
                                        const pos = (players.active?.position ?? 0) / 1000000  // Convert microseconds to seconds
                                        const mins = Math.floor(pos / 60)
                                        const secs = Math.floor(pos % 60)
                                        return `${mins}:${secs.toString().padStart(2, '0')}`
                                    }
                                    font.family: "Inter"
                                    font.pixelSize: 11
                                    color: root.m3OnSurfaceVariant
                                }
                                
                                Item { Layout.fillWidth: true }
                                
                                Text {
                                    text: {
                                        const len = (players.active?.length ?? 0) / 1000000  // Convert microseconds to seconds
                                        const mins = Math.floor(len / 60)
                                        const secs = Math.floor(len % 60)
                                        return `${mins}:${secs.toString().padStart(2, '0')}`
                                    }
                                    font.family: "Inter"
                                    font.pixelSize: 11
                                    color: root.m3OnSurfaceVariant
                                }
                            }
                            
                            // Enhanced progress bar with click-to-seek
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 6
                                radius: 3
                                color: Qt.rgba(root.m3OnSurface.r, root.m3OnSurface.g, root.m3OnSurface.b, 0.2)
                                visible: players.active?.length > 0
                                
                                Rectangle {
                                    id: progressFill
                                    width: parent.width * Math.max(0, Math.min(1, (players.active?.position ?? 0) / (players.active?.length ?? 1)))
                                    height: parent.height
                                    radius: parent.radius
                                    color: root.m3Primary
                                    
                                    Behavior on width {
                                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                                    }
                                    
                                    // Progress indicator handle
                                    Rectangle {
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: seekMouseArea.containsMouse || seekMouseArea.pressed ? 14 : 0
                                        height: width
                                        radius: width / 2
                                        color: root.m3Primary
                                        
                                        Behavior on width {
                                            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                                        }
                                        
                                        layer.enabled: true
                                        layer.effect: MultiEffect {
                                            shadowEnabled: true
                                            shadowColor: Qt.rgba(0, 0, 0, 0.3)
                                            shadowBlur: 0.5
                                            shadowVerticalOffset: 2
                                        }
                                    }
                                }
                                
                                MouseArea {
                                    id: seekMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    
                                    onClicked: mouse => {
                                        if (players.active && players.active.canSeek) {
                                            const seekPosition = (mouse.x / width) * (players.active.length ?? 0)
                                            players.active.position = Math.floor(seekPosition)  // Position is in microseconds
                                        }
                                    }
                                }
                            }
                            
                            // Playback controls with shuffle and loop
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12
                                
                                MediaButton {
                                    icon: players.active?.canShuffle ? (players.active?.shuffleState ? "󰒝" : "󰒞") : "󰒞"
                                    iconColor: players.active?.shuffleState ? root.m3Primary : root.m3OnSurfaceVariant
                                    enabled: players.active?.canShuffle ?? false
                                    onClicked: { 
                                        if (players.active && players.active.canShuffle) {
                                            players.active.shuffleState = !players.active.shuffleState
                                        }
                                    }
                                }
                                
                                Item { Layout.fillWidth: true }
                                
                                MediaButton {
                                    icon: "󰒮"
                                    enabled: players.active?.canGoPrevious ?? false
                                    onClicked: { if (players.active) players.active.previous() }
                                }
                                
                                MediaButton {
                                    icon: players.active?.isPlaying ? "󰏤" : "󰐊"
                                    primary: true
                                    size: 52
                                    iconSize: 26
                                    enabled: players.active?.canTogglePlaying ?? false
                                    onClicked: { if (players.active) players.active.playPause() }
                                }
                                
                                MediaButton {
                                    icon: "󰒭"
                                    enabled: players.active?.canGoNext ?? false
                                    onClicked: { if (players.active) players.active.next() }
                                }
                                
                                Item { Layout.fillWidth: true }
                                
                                MediaButton {
                                    icon: {
                                        if (!players.active?.loopState) return "󰑗"
                                        return players.active.loopState === "Track" ? "󰑘" : "󰑖"
                                    }
                                    iconColor: players.active?.loopState ? root.m3Primary : root.m3OnSurfaceVariant
                                    enabled: players.active?.canControl ?? false
                                    onClicked: {
                                        if (players.active) {
                                            // Cycle: None -> Playlist -> Track -> None
                                            if (!players.active.loopState || players.active.loopState === "None") {
                                                players.active.loopState = "Playlist"
                                            } else if (players.active.loopState === "Playlist") {
                                                players.active.loopState = "Track"
                                            } else {
                                                players.active.loopState = "None"
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Notifications section
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 120  // Reduced from 150
                    radius: 16
                    color: root.m3SurfaceContainer
                    border.color: Qt.rgba(root.m3Primary.r, root.m3Primary.g, root.m3Primary.b, 0.15)
                    border.width: 1
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 12
                        
                        RowLayout {
                            Layout.fillWidth: true
                            
                            Text {
                                text: "Notifications"
                                font.family: "Inter"
                                font.pixelSize: 16
                                font.weight: Font.Bold
                                color: root.m3OnSurface
                            }
                            
                            Item { Layout.fillWidth: true }
                            
                            Rectangle {
                                Layout.preferredWidth: 30
                                Layout.preferredHeight: 30
                                radius: 15
                                color: clearHover.containsMouse ? 
                                       Qt.rgba(root.m3Primary.r, root.m3Primary.g, root.m3Primary.b, 0.15) : 
                                       "transparent"
                                clip: true
                                
                                Behavior on color {
                                    ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                                }
                                
                                // State layer
                                Rectangle {
                                    anchors.fill: parent
                                    radius: parent.radius
                                    color: {
                                        if (clearHover.pressed) {
                                            return Qt.rgba(root.m3Primary.r, root.m3Primary.g, root.m3Primary.b, 0.12)
                                        } else if (clearHover.containsMouse) {
                                            return Qt.rgba(root.m3Primary.r, root.m3Primary.g, root.m3Primary.b, 0.08)
                                        }
                                        return "transparent"
                                    }
                                    
                                    Behavior on color {
                                        ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
                                    }
                                }
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "󰎟"
                                    font.family: "Material Design Icons"
                                    font.pixelSize: 16
                                    color: root.m3OnSurface
                                }
                                
                                // Ripple effect
                                Effects.RippleEffect {
                                    id: clearRipple
                                    anchors.fill: parent
                                    rippleColor: Qt.rgba(root.m3Primary.r, root.m3Primary.g, root.m3Primary.b, 0.3)
                                    centered: true
                                }
                                
                                MouseArea {
                                    id: clearHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        clearRipple.trigger()
                                        notifs.clearAll()
                                    }
                                }
                            }
                        }
                        
                        // Empty state message
                        Text {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            visible: notifList.count === 0
                            text: "No notifications\n󰂚"
                            font.family: "Inter"
                            font.pixelSize: 14
                            color: root.m3OnSurfaceVariant
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            lineHeight: 1.5
                        }
                        
                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.minimumHeight: 100
                            visible: notifList.count > 0
                            clip: true
                            
                            // Enhanced smooth scrolling
                            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                            ScrollBar.vertical.policy: ScrollBar.AsNeeded
                            ScrollBar.vertical.interactive: true
                            
                            contentWidth: availableWidth
                            
                            ListView {
                                id: notifList
                                width: parent.width
                                model: notifs.recentNotifications
                                spacing: 8
                                
                                // Enable smooth kinetic scrolling
                                flickableDirection: Flickable.VerticalFlick
                                boundsBehavior: Flickable.DragAndOvershootBounds
                                boundsMovement: Flickable.FollowBoundsBehavior
                                
                                // Smooth scroll behavior
                                Behavior on contentY {
                                    SmoothedAnimation { 
                                        velocity: 1200
                                        maximumEasingTime: 200
                                    }
                                }
                                
                                // Add/Remove animations
                                add: Transition {
                                    NumberAnimation { properties: "opacity"; from: 0; to: 1; duration: 300; easing.type: Easing.OutCubic }
                                    NumberAnimation { properties: "scale"; from: 0.9; to: 1; duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
                                }
                                
                                remove: Transition {
                                    NumberAnimation { properties: "opacity"; to: 0; duration: 200; easing.type: Easing.InCubic }
                                    NumberAnimation { properties: "x"; to: 100; duration: 200; easing.type: Easing.InCubic }
                                }
                                
                                displaced: Transition {
                                    NumberAnimation { properties: "y"; duration: 250; easing.type: Easing.OutCubic }
                                }
                                    
                                delegate: Rectangle {
                                    required property var modelData
                                    required property int index
                                    
                                    width: ListView.view.width
                                    height: 76  // Increased from 68 for better spacing
                                    radius: 14
                                    
                                    // Gradient background based on urgency
                                    gradient: Gradient {
                                        GradientStop { 
                                            position: 0.0
                                            color: {
                                                if (modelData.urgency === 2) {  // Critical
                                                    return Qt.rgba(pywal.color1.r, pywal.color1.g, pywal.color1.b, 0.12)
                                                } else if (modelData.urgency === 1) {  // Normal
                                                    return Qt.rgba(root.m3Primary.r, root.m3Primary.g, root.m3Primary.b, 0.08)
                                                }
                                                return Qt.rgba(root.m3OnSurface.r, root.m3OnSurface.g, root.m3OnSurface.b, 0.06)
                                            }
                                        }
                                        GradientStop { 
                                            position: 1.0
                                            color: Qt.rgba(root.m3OnSurface.r, root.m3OnSurface.g, root.m3OnSurface.b, 0.04)
                                        }
                                    }
                                    
                                    border.width: 1
                                    border.color: {
                                        if (modelData.urgency === 2) {  // Critical
                                            return Qt.rgba(pywal.color1.r, pywal.color1.g, pywal.color1.b, 0.4)
                                        } else if (modelData.urgency === 1) {  // Normal
                                            return Qt.rgba(root.m3Primary.r, root.m3Primary.g, root.m3Primary.b, 0.2)
                                        }
                                        return Qt.rgba(root.m3OnSurface.r, root.m3OnSurface.g, root.m3OnSurface.b, 0.12)
                                    }
                                    
                                    // Hover effect
                                    scale: notifHover.containsMouse ? 1.02 : 1.0
                                    
                                    Behavior on scale {
                                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                                    }
                                    
                                    Behavior on border.color {
                                        ColorAnimation { duration: 200 }
                                    }
                                    
                                    // Urgency indicator bar
                                    Rectangle {
                                        anchors.left: parent.left
                                        anchors.top: parent.top
                                        anchors.bottom: parent.bottom
                                        width: 4
                                        radius: 14
                                        visible: modelData.urgency === 2
                                        color: pywal.color1
                                        
                                        // Pulse animation for critical notifications
                                        SequentialAnimation on opacity {
                                            running: modelData.urgency === 2
                                            loops: Animation.Infinite
                                            NumberAnimation { to: 0.4; duration: 1000; easing.type: Easing.InOutCubic }
                                            NumberAnimation { to: 1.0; duration: 1000; easing.type: Easing.InOutCubic }
                                        }
                                    }
                                    
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 14
                                        spacing: 14
                                        
                                        // App icon with dynamic colors
                                        Rectangle {
                                            Layout.preferredWidth: 44
                                            Layout.preferredHeight: 44
                                            radius: 12
                                            
                                            gradient: Gradient {
                                                GradientStop { 
                                                    position: 0.0
                                                    color: {
                                                        if (modelData.urgency === 2) return Qt.rgba(pywal.color1.r, pywal.color1.g, pywal.color1.b, 0.25)
                                                        if (modelData.urgency === 1) return Qt.rgba(root.m3Primary.r, root.m3Primary.g, root.m3Primary.b, 0.25)
                                                        return Qt.rgba(pywal.color4.r, pywal.color4.g, pywal.color4.b, 0.2)
                                                    }
                                                }
                                                GradientStop { 
                                                    position: 1.0
                                                    color: {
                                                        if (modelData.urgency === 2) return Qt.rgba(pywal.color1.r, pywal.color1.g, pywal.color1.b, 0.15)
                                                        if (modelData.urgency === 1) return Qt.rgba(root.m3Primary.r, root.m3Primary.g, root.m3Primary.b, 0.15)
                                                        return Qt.rgba(pywal.color4.r, pywal.color4.g, pywal.color4.b, 0.1)
                                                    }
                                                }
                                            }
                                            
                                            // Icon with dynamic selection
                                            Text {
                                                anchors.centerIn: parent
                                                text: {
                                                    // Map app names to icons
                                                    const appName = (modelData.appName || "").toLowerCase()
                                                    if (appName.includes("spotify")) return "󰓇"
                                                    if (appName.includes("discord")) return "󰙯"
                                                    if (appName.includes("telegram")) return "󰍡"
                                                    if (appName.includes("firefox") || appName.includes("browser")) return "󰈹"
                                                    if (appName.includes("volume") || appName.includes("audio")) return "󰕾"
                                                    if (appName.includes("battery")) return "󰁹"
                                                    if (appName.includes("network") || appName.includes("wifi")) return "󰖩"
                                                    if (appName.includes("bluetooth")) return "󰂯"
                                                    if (appName.includes("mail") || appName.includes("email")) return "�"
                                                    if (appName.includes("calendar")) return "󰃭"
                                                    if (appName.includes("update")) return "󰚰"
                                                    if (appName.includes("error")) return "󰀨"
                                                    if (appName.includes("warning")) return "󰀪"
                                                    if (modelData.urgency === 2) return "󰀨"  // Error icon for critical
                                                    return "�󰂚"  // Default notification icon
                                                }
                                                font.family: "Material Design Icons"
                                                font.pixelSize: 22
                                                color: {
                                                    if (modelData.urgency === 2) return pywal.color1
                                                    if (modelData.urgency === 1) return root.m3Primary
                                                    return pywal.color4
                                                }
                                            }
                                        }
                                        
                                        // Content
                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 6
                                            
                                            // Header row with app name badge
                                            RowLayout {
                                                Layout.fillWidth: true
                                                spacing: 8
                                                
                                                // App name badge
                                                Rectangle {
                                                    Layout.preferredHeight: 18
                                                    implicitWidth: appNameText.implicitWidth + 12
                                                    radius: 9
                                                    visible: modelData.appName && modelData.appName !== ""
                                                    color: {
                                                        if (modelData.urgency === 2) return Qt.rgba(pywal.color1.r, pywal.color1.g, pywal.color1.b, 0.2)
                                                        if (modelData.urgency === 1) return Qt.rgba(root.m3Primary.r, root.m3Primary.g, root.m3Primary.b, 0.2)
                                                        return Qt.rgba(root.m3OnSurface.r, root.m3OnSurface.g, root.m3OnSurface.b, 0.15)
                                                    }
                                                    
                                                    Text {
                                                        id: appNameText
                                                        anchors.centerIn: parent
                                                        text: modelData.appName || ""
                                                        font.family: "Inter"
                                                        font.pixelSize: 9
                                                        font.weight: Font.Bold
                                                        color: {
                                                            if (modelData.urgency === 2) return pywal.color1
                                                            if (modelData.urgency === 1) return root.m3Primary
                                                            return root.m3OnSurface
                                                        }
                                                        elide: Text.ElideRight
                                                    }
                                                }
                                                
                                                Item { Layout.fillWidth: true }
                                                
                                                // Timestamp
                                                Text {
                                                    text: modelData.timeString || ""
                                                    font.family: "Inter"
                                                    font.pixelSize: 10
                                                    font.weight: Font.Medium
                                                    color: root.m3OnSurfaceVariant
                                                    opacity: 0.8
                                                }
                                            }
                                            
                                            // Summary/Title
                                            Text {
                                                Layout.fillWidth: true
                                                text: modelData.summary || "Notification"
                                                font.family: "Inter"
                                                font.pixelSize: 14
                                                font.weight: Font.Bold
                                                color: root.m3OnSurface
                                                elide: Text.ElideRight
                                            }
                                            
                                            // Body text with better styling
                                            Text {
                                                Layout.fillWidth: true
                                                text: modelData.body || ""
                                                font.family: "Inter"
                                                font.pixelSize: 11
                                                lineHeight: 1.3
                                                color: root.m3OnSurfaceVariant
                                                elide: Text.ElideRight
                                                maximumLineCount: 2
                                                wrapMode: Text.WordWrap
                                                visible: text !== ""
                                            }
                                        }
                                        
                                        // Delete button
                                        Rectangle {
                                            Layout.preferredWidth: 32
                                            Layout.preferredHeight: 32
                                            radius: 8
                                            color: deleteMouseArea.containsMouse ? 
                                                   Qt.rgba(root.m3OnSurface.r, root.m3OnSurface.g, root.m3OnSurface.b, 0.15) : 
                                                   "transparent"
                                            clip: true
                                            
                                            Behavior on color {
                                                ColorAnimation { duration: 150 }
                                            }
                                            
                                            // State layer
                                            Rectangle {
                                                anchors.fill: parent
                                                radius: parent.radius
                                                color: {
                                                    if (deleteMouseArea.pressed) {
                                                        return Qt.rgba(pywal.color1.r, pywal.color1.g, pywal.color1.b, 0.12)
                                                    } else if (deleteMouseArea.containsMouse) {
                                                        return Qt.rgba(pywal.color1.r, pywal.color1.g, pywal.color1.b, 0.08)
                                                    }
                                                    return "transparent"
                                                }
                                                
                                                Behavior on color {
                                                    ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
                                                }
                                            }
                                            
                                            Text {
                                                anchors.centerIn: parent
                                                text: "󰅖"
                                                font.family: "Material Design Icons"
                                                font.pixelSize: 16
                                                color: deleteMouseArea.containsMouse ? pywal.color1 : root.m3OnSurfaceVariant
                                                
                                                Behavior on color {
                                                    ColorAnimation { duration: 150 }
                                                }
                                            }
                                            
                                            // Ripple effect
                                            Effects.RippleEffect {
                                                id: deleteRipple
                                                anchors.fill: parent
                                                rippleColor: Qt.rgba(pywal.color1.r, pywal.color1.g, pywal.color1.b, 0.3)
                                                centered: true
                                            }
                                            
                                            MouseArea {
                                                id: deleteMouseArea
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    deleteRipple.trigger()
                                                    notifs.deleteNotification(modelData)
                                                }
                                            }
                                        }
                                    }
                                    
                                    // State layer for hover
                                    Rectangle {
                                        anchors.fill: parent
                                        radius: parent.radius
                                        color: notifHover.containsMouse ? 
                                               Qt.rgba(root.m3OnSurface.r, root.m3OnSurface.g, root.m3OnSurface.b, 0.05) : 
                                               "transparent"
                                        
                                        Behavior on color {
                                            ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                                        }
                                    }
                                    
                                    // Clickable area for opening notification
                                    MouseArea {
                                        id: notifHover
                                        anchors.fill: parent
                                        anchors.rightMargin: 40  // Don't overlap delete button
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            console.log("📬 [Notification] Clicked:", modelData.summary)
                                            // Add action handling here if needed
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
        }  // End of main ColumnLayout
    }  // End of dashboard Rectangle
    }  // End of dashboardContainer Item
    
    // Quick toggle component
    component QuickToggle: Rectangle {
        id: toggle
        
        property string icon: ""
        property string label: ""
        property string sublabel: ""
        property bool active: false
        property color primaryColor: root.m3Primary
        
        signal clicked()
        
        Layout.preferredHeight: 70  // Reduced from 90
        radius: 16
        
        color: active ? 
               Qt.rgba(primaryColor.r, primaryColor.g, primaryColor.b, 0.18) : 
               root.m3SurfaceContainer
        
        border.color: active ? 
                      Qt.rgba(primaryColor.r, primaryColor.g, primaryColor.b, 0.4) : 
                      Qt.rgba(root.m3OnSurface.r, root.m3OnSurface.g, root.m3OnSurface.b, 0.1)
        border.width: 1
        
        scale: toggleMouse.pressed ? 0.95 : (toggleMouse.containsMouse ? 1.02 : 1.0)
        
        clip: true  // Enable clipping for ripple effect
        
        Behavior on color {
            ColorAnimation { duration: 250; easing.type: Easing.OutCubic }
        }
        
        Behavior on border.color {
            ColorAnimation { duration: 250; easing.type: Easing.OutCubic }
        }
        
        Behavior on scale {
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
        }
        
        // Material 3 State Layer (hover/press feedback)
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: {
                if (toggleMouse.pressed) {
                    return Qt.rgba(toggle.primaryColor.r, toggle.primaryColor.g, toggle.primaryColor.b, 0.12)
                } else if (toggleMouse.containsMouse) {
                    return Qt.rgba(toggle.primaryColor.r, toggle.primaryColor.g, toggle.primaryColor.b, 0.08)
                }
                return "transparent"
            }
            
            Behavior on color {
                ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
            }
        }
        
        // Material 3 Ripple Effect
        Effects.RippleEffect {
            id: toggleRipple
            anchors.fill: parent
            rippleColor: Qt.rgba(toggle.primaryColor.r, toggle.primaryColor.g, toggle.primaryColor.b, 0.2)
        }
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 12
            
            // Icon
            Text {
                text: toggle.icon
                font.family: "Material Design Icons"
                font.pixelSize: 28
                color: toggle.active ? toggle.primaryColor : root.m3OnSurface
                
                Behavior on color {
                    ColorAnimation { duration: 250; easing.type: Easing.OutCubic }
                }
            }
            
            // Label and sublabel column
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 2
                
                Item { Layout.fillHeight: true }
                
                Text {
                    text: toggle.label
                    font.family: "Inter"
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    color: toggle.active ? toggle.primaryColor : root.m3OnSurface
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    
                    Behavior on color {
                        ColorAnimation { duration: 250; easing.type: Easing.OutCubic }
                    }
                }
                
                Text {
                    text: toggle.sublabel
                    font.family: "Inter"
                    font.pixelSize: 10
                    color: root.m3OnSurfaceVariant
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    visible: toggle.sublabel !== ""
                }
                
                Item { Layout.fillHeight: true }
            }
        }
        
        MouseArea {
            id: toggleMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                toggleRipple.trigger()
                toggle.clicked()
            }
        }
    }
    
    // Slider card component
    component SliderCard: Rectangle {
        id: sliderCard
        
        property string icon: ""
        property string label: ""
        property real value: 0
        property color primaryColor: root.m3Primary
        
        signal sliderMoved(real newValue)
        signal iconClicked()
        
        Layout.preferredHeight: 75  // Reduced from 90
        radius: 16
        color: root.m3SurfaceContainer
        border.color: Qt.rgba(primaryColor.r, primaryColor.g, primaryColor.b, 0.2)
        border.width: 1
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                
                Rectangle {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    radius: 16
                    color: Qt.rgba(sliderCard.primaryColor.r, sliderCard.primaryColor.g, sliderCard.primaryColor.b, 0.2)
                    clip: true
                    
                    // State layer
                    Rectangle {
                        anchors.fill: parent
                        radius: parent.radius
                        color: {
                            if (iconMouse.pressed) {
                                return Qt.rgba(sliderCard.primaryColor.r, sliderCard.primaryColor.g, sliderCard.primaryColor.b, 0.2)
                            } else if (iconMouse.containsMouse) {
                                return Qt.rgba(sliderCard.primaryColor.r, sliderCard.primaryColor.g, sliderCard.primaryColor.b, 0.12)
                            }
                            return "transparent"
                        }
                        
                        Behavior on color {
                            ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
                        }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: sliderCard.icon
                        font.family: "Material Design Icons"
                        font.pixelSize: 18
                        color: sliderCard.primaryColor
                    }
                    
                    // Ripple effect
                    Effects.RippleEffect {
                        id: iconRipple
                        anchors.fill: parent
                        rippleColor: Qt.rgba(sliderCard.primaryColor.r, sliderCard.primaryColor.g, sliderCard.primaryColor.b, 0.3)
                        centered: true
                    }
                    
                    MouseArea {
                        id: iconMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            iconRipple.trigger()
                            sliderCard.iconClicked()
                        }
                    }
                }
                
                Text {
                    text: sliderCard.label
                    font.family: "Inter"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: root.m3OnSurfaceVariant
                }
                
                Item { Layout.fillWidth: true }
                
                Text {
                    text: Math.round((sliderCard.value || 0) * 100) + "%"
                    font.family: "Inter"
                    font.pixelSize: 13
                    font.weight: Font.Bold
                    color: root.m3OnSurface
                }
            }
            
            // Custom slider
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 6
                radius: 3
                color: Qt.rgba(root.m3OnSurface.r, root.m3OnSurface.g, root.m3OnSurface.b, 0.1)
                
                Rectangle {
                    width: parent.width * sliderCard.value
                    height: parent.height
                    radius: parent.radius
                    color: sliderCard.primaryColor
                    
                    Behavior on width {
                        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: mouse => {
                        const newValue = Math.max(0, Math.min(1, mouse.x / width))
                        sliderCard.sliderMoved(newValue)
                    }
                    onPositionChanged: mouse => {
                        if (pressed) {
                            const newValue = Math.max(0, Math.min(1, mouse.x / width))
                            sliderCard.sliderMoved(newValue)
                        }
                    }
                }
            }
        }
    }
    
    // System card component
    component SystemCard: Rectangle {
        id: sysCard
        
        property string icon: ""
        property string label: ""
        property int value: 0
        property string unit: ""
        property real progress: 0
        property color primaryColor: root.m3Primary
        
        radius: 14
        color: Qt.rgba(primaryColor.r, primaryColor.g, primaryColor.b, 0.06)
        border.color: Qt.rgba(primaryColor.r, primaryColor.g, primaryColor.b, progress > 0.8 ? 0.5 : 0.2)
        border.width: 1.5
        
        // Subtle glow for high usage
        layer.enabled: progress > 0.8
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Qt.rgba(primaryColor.r, primaryColor.g, primaryColor.b, 0.3)
            shadowBlur: 0.6
            shadowScale: 1.03
        }
        
        Behavior on border.color {
            ColorAnimation { duration: 400; easing.type: Easing.OutCubic }
        }
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 8
            
            // Icon with minimal background
            Rectangle {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                radius: 7
                color: Qt.rgba(primaryColor.r, primaryColor.g, primaryColor.b, 0.12)
                
                Text {
                    anchors.centerIn: parent
                    text: sysCard.icon
                    font.family: "Material Design Icons"
                    font.pixelSize: 16
                    color: sysCard.primaryColor
                }
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                
                // Label
                Text {
                    text: sysCard.label
                    font.family: "Inter"
                    font.pixelSize: 9
                    font.weight: Font.Medium
                    color: root.m3OnSurfaceVariant
                    Layout.fillWidth: true
                }
                
                // Value with compact styling
                RowLayout {
                    spacing: 1
                    
                    Text {
                        text: sysCard.value
                        font.family: "JetBrains Mono"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: sysCard.primaryColor
                    }
                    
                    Text {
                        Layout.alignment: Qt.AlignBottom
                        text: sysCard.unit
                        font.family: "Inter"
                        font.pixelSize: 10
                        color: root.m3OnSurfaceVariant
                        bottomPadding: 1
                    }
                }
                
                // Compact progress bar
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 3
                    radius: 1.5
                    color: Qt.rgba(root.m3OnSurface.r, root.m3OnSurface.g, root.m3OnSurface.b, 0.06)
                    
                    Rectangle {
                        width: parent.width * sysCard.progress
                        height: parent.height
                        radius: parent.radius
                        color: sysCard.primaryColor
                        
                        Behavior on width {
                            NumberAnimation { duration: 500; easing.type: Easing.OutCubic }
                        }
                    }
                }
            }
        }
    }
    
    // Media button component
    component MediaButton: Rectangle {
        id: btn
        
        property string icon: ""
        property bool primary: false
        property bool enabled: true
        property color iconColor: primary ? Qt.rgba(0, 0, 0, 0.9) : root.m3OnSurface
        property int size: primary ? 52 : 44
        property int iconSize: primary ? 28 : 22
        
        signal clicked()
        
        Layout.preferredWidth: size
        Layout.preferredHeight: size
        radius: size / 2
        
        opacity: enabled ? 1.0 : 0.4
        
        color: primary ? 
               root.m3Primary : 
               (btnMouse.containsMouse ? Qt.rgba(root.m3OnSurface.r, root.m3OnSurface.g, root.m3OnSurface.b, 0.1) : "transparent")
        
        border.color: primary ? "transparent" : Qt.rgba(root.m3OnSurface.r, root.m3OnSurface.g, root.m3OnSurface.b, 0.2)
        border.width: primary ? 0 : 1
        
        clip: true  // Enable clipping for ripple
        
        scale: btnMouse.pressed ? 0.9 : (btnMouse.containsMouse ? 1.05 : 1.0)
        
        Behavior on color {
            ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
        
        Behavior on scale {
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }
        
        Behavior on opacity {
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }
        
        // Material 3 State Layer
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: {
                if (!btn.enabled) return "transparent"
                if (btnMouse.pressed) {
                    return btn.primary ? 
                           Qt.rgba(0, 0, 0, 0.12) : 
                           Qt.rgba(root.m3OnSurface.r, root.m3OnSurface.g, root.m3OnSurface.b, 0.12)
                } else if (btnMouse.containsMouse) {
                    return btn.primary ? 
                           Qt.rgba(0, 0, 0, 0.08) : 
                           Qt.rgba(root.m3OnSurface.r, root.m3OnSurface.g, root.m3OnSurface.b, 0.08)
                }
                return "transparent"
            }
            
            Behavior on color {
                ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
            }
        }
        
        // Material 3 Ripple Effect
        Effects.RippleEffect {
            id: btnRipple
            anchors.fill: parent
            rippleColor: btn.primary ? 
                         Qt.rgba(0, 0, 0, 0.2) : 
                         Qt.rgba(root.m3OnSurface.r, root.m3OnSurface.g, root.m3OnSurface.b, 0.2)
            centered: true
        }
        
        Text {
            anchors.centerIn: parent
            text: btn.icon
            font.family: "Material Design Icons"
            font.pixelSize: iconSize
            color: iconColor
            
            Behavior on color {
                ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
            }
        }
        
        MouseArea {
            id: btnMouse
            anchors.fill: parent
            hoverEnabled: enabled
            enabled: btn.enabled
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
            onClicked: {
                if (btn.enabled) {
                    btnRipple.trigger()
                    btn.clicked()
                }
            }
        }
    }
}
