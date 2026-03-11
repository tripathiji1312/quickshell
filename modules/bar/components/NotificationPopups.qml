import QtQuick 6.10
import QtQuick.Layouts 6.10
import QtQuick.Effects
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland
import "../../../services" as QsServices
import "../../../config" as QsConfig

// Material 3 Expressive notification popup window - Enhanced with Gestures
PanelWindow {
    id: root
    
    readonly property var pywal: QsServices.Pywal
    readonly property var notifs: QsServices.Notifs
    readonly property var logger: QsServices.Logger
    readonly property var config: QsConfig.Config
    
    // Aesthetic subtle color scheme
    readonly property color m3Surface: Qt.rgba(
        (pywal?.background ?? Qt.rgba(0.12, 0.12, 0.14, 1)).r,
        (pywal?.background ?? Qt.rgba(0.12, 0.12, 0.14, 1)).g,
        (pywal?.background ?? Qt.rgba(0.12, 0.12, 0.14, 1)).b,
        0.95
    )
    readonly property color m3SurfaceContainer: Qt.lighter(pywal?.background ?? "#1e1e24", 1.08)
    readonly property color m3SurfaceContainerHigh: Qt.lighter(pywal?.background ?? "#1e1e24", 1.18)
    readonly property color m3Primary: pywal?.primary ?? "#a6e3a1"
    readonly property color m3OnSurface: pywal?.foreground ?? "#e8e8e8"
    readonly property color m3OnSurfaceVariant: Qt.rgba(m3OnSurface.r, m3OnSurface.g, m3OnSurface.b, 0.55)
    readonly property color m3Error: pywal?.color1 ?? "#f38ba8"
    readonly property color m3Warning: pywal?.color3 ?? "#f9e2af"
    readonly property color m3Border: Qt.rgba(m3OnSurface.r, m3OnSurface.g, m3OnSurface.b, 0.04)
    readonly property color m3Accent: Qt.rgba(m3Primary.r, m3Primary.g, m3Primary.b, 0.12)
    
    // Swipe threshold (percentage of width to trigger dismiss)
    readonly property real swipeThreshold: 0.35

    function _urgencyColor(u) {
        if (u === NotificationUrgency.Critical) return root.m3Error
        if (u === NotificationUrgency.Low) return root.m3OnSurfaceVariant
        return root.m3Primary
    }

    function _urgencyBg(u) {
        const c = _urgencyColor(u)
        if (u === NotificationUrgency.Critical) return Qt.rgba(c.r, c.g, c.b, 0.10)
        if (u === NotificationUrgency.Low) return Qt.rgba(c.r, c.g, c.b, 0.06)
        return Qt.rgba(c.r, c.g, c.b, 0.09)
    }
    
    // Get popups that should be shown (configurable max, newest first)
    readonly property var activePopups: (notifs.notifications || []).filter(n => !!n && !n.closed).slice(0, config.notifications.maxVisible)
    
    screen: Quickshell.screens[0]
    
    anchors {
        top: true
        right: true
    }
    
    margins {
        top: config.notifications.margin
        right: config.notifications.margin
    }
    
    visible: activePopups.length > 0
    color: "transparent"
    
    implicitWidth: config.notifications.popupWidth
    implicitHeight: notifColumn.implicitHeight
    
    // Smooth height transition
    Behavior on implicitHeight {
        NumberAnimation { 
            duration: 150
            easing.type: Easing.OutQuad
        }
    }
    
    Column {
        id: notifColumn
        width: parent.width
        spacing: config.notifications.spacing
        
        // Quick smooth reordering - no bounce to prevent laggy feel
        move: Transition {
            NumberAnimation {
                properties: "y"
                duration: 120
                easing.type: Easing.OutQuad
            }
        }
        
        Repeater {
            model: root.activePopups
            
            // Enhanced notification card with gestures
            Item {
                id: notifCard
                
                required property var modelData
                required property int index
                
                width: config.notifications.popupWidth
                height: cardWrapper.height
                clip: true
                
                property bool isVisible: true
                property bool isHovered: false
                property bool isDragging: false
                property bool isExpanded: false
                property real dragX: 0
                property real animProgress: 0

                // Timeout progress (1.0 -> 0.0). Kept separate from geometry so the
                // timer can't instantly finish during initial layout.
                property real timeoutProgress: 1.0
                
                // Animation properties for M3 expressive bounce
                property real entranceScale: 0.7
                property real entranceX: 120
                property real entranceOpacity: 0
                
                // Entrance animation
                Component.onCompleted: {
                    if (!modelData.hasAnimated) {
                        modelData.hasAnimated = true
                        entranceAnim.start()
                    } else {
                        animProgress = 1.0
                        entranceScale = 1.0
                        entranceX = 0
                        entranceOpacity = 1.0
                    }
                }
                
                // Fast M3 entrance with subtle bounce
                SequentialAnimation {
                    id: entranceAnim
                    
                    // Minimal stagger
                    PauseAnimation { duration: notifCard.index * 20 }
                    
                    ParallelAnimation {
                        // Opacity - instant
                        NumberAnimation {
                            target: notifCard
                            property: "entranceOpacity"
                            from: 0.0
                            to: 1.0
                            duration: 80
                            easing.type: Easing.OutQuad
                        }
                        
                        // Scale with quick bounce
                        NumberAnimation {
                            target: notifCard
                            property: "entranceScale"
                            from: 0.8
                            to: 1.0
                            duration: 180
                            easing.type: Easing.OutBack
                            easing.overshoot: 1.5
                        }
                        
                        // Slide in fast
                        NumberAnimation {
                            target: notifCard
                            property: "entranceX"
                            from: 80
                            to: 0
                            duration: 180
                            easing.type: Easing.OutBack
                            easing.overshoot: 1.2
                        }
                        
                        // Progress tracker
                        NumberAnimation {
                            target: notifCard
                            property: "animProgress"
                            from: 0.0
                            to: 1.0
                            duration: 180
                            easing.type: Easing.OutQuad
                        }
                    }
                }
                
                // Exit animation (swipe right)
                SequentialAnimation {
                    id: exitAnimRight
                    
                    NumberAnimation {
                        target: notifCard
                        property: "dragX"
                        to: config.notifications.popupWidth + 50
                        duration: 120
                        easing.type: Easing.InQuad
                    }
                    
                    NumberAnimation {
                        target: notifCard
                        property: "height"
                        to: 0
                        duration: 80
                        easing.type: Easing.InQuad
                    }
                    
                    ScriptAction { script: modelData.close() }
                }
                
                // Exit animation (swipe left)
                SequentialAnimation {
                    id: exitAnimLeft
                    
                    NumberAnimation {
                        target: notifCard
                        property: "dragX"
                        to: -(config.notifications.popupWidth + 50)
                        duration: 120
                        easing.type: Easing.InQuad
                    }
                    
                    NumberAnimation {
                        target: notifCard
                        property: "height"
                        to: 0
                        duration: 80
                        easing.type: Easing.InQuad
                    }
                    
                    ScriptAction { script: modelData.close() }
                }
                
                // Snap back animation - quick, minimal bounce
                NumberAnimation {
                    id: snapBackAnim
                    target: notifCard
                    property: "dragX"
                    to: 0
                    duration: 150
                    easing.type: Easing.OutQuad
                }
                
                // Standard dismiss (quick fade + shrink)
                SequentialAnimation {
                    id: dismissAnim
                    
                    ParallelAnimation {
                        NumberAnimation {
                            target: notifCard
                            property: "animProgress"
                            to: 0.0
                            duration: 100
                            easing.type: Easing.InQuad
                        }
                        NumberAnimation {
                            target: notifCard
                            property: "opacity"
                            to: 0
                            duration: 100
                        }
                    }
                    
                    NumberAnimation {
                        target: notifCard
                        property: "height"
                        to: 0
                        duration: 80
                        easing.type: Easing.InQuad
                    }
                    
                    ScriptAction { script: modelData.close() }
                }
                
                function dismiss() {
                    isVisible = false
                    dismissAnim.start()
                }
                
                function swipeDismiss(direction) {
                    isVisible = false
                    if (direction > 0) {
                        exitAnimRight.start()
                    } else {
                        exitAnimLeft.start()
                    }
                }
                
                // Card wrapper for swipe gesture
                Item {
                    id: cardWrapper
                    width: parent.width
                    height: cardBg.height
                    x: notifCard.dragX
                    
                    // Material 3 Expressive entrance transforms
                    scale: notifCard.entranceScale
                    opacity: notifCard.entranceOpacity
                    transform: Translate {
                        x: notifCard.entranceX
                    }
                    
                    // Smooth transform origin for natural scaling
                    transformOrigin: Item.Right
                    
                    // Subtle swipe indicator (shows when dragging)
                    Rectangle {
                        id: swipeIndicator
                        anchors.fill: cardBg
                        radius: cardBg.radius
                        visible: Math.abs(notifCard.dragX) > 30
                        opacity: Math.min(0.8, Math.abs(notifCard.dragX) / (config.notifications.popupWidth * root.swipeThreshold * 1.5))
                        
                        color: notifCard.dragX > 0 ? 
                               Qt.rgba(root.m3Error.r, root.m3Error.g, root.m3Error.b, 0.08) :
                               Qt.rgba(root.m3Primary.r, root.m3Primary.g, root.m3Primary.b, 0.08)
                        
                        // Minimal swipe icon
                        Text {
                            anchors.centerIn: parent
                            text: notifCard.dragX > 0 ? "󰅖" : "󰄬"
                            font.family: "Material Design Icons"
                            font.pixelSize: 24
                            color: notifCard.dragX > 0 ? root.m3Error : root.m3Primary
                            opacity: 0.7
                        }
                    }
                    
                        Rectangle {
                            id: cardBg
                        width: parent.width
                        height: contentLayout.implicitHeight + 28
                        radius: 20
                        
                        // Notification card surface
                        color: root.m3Surface
                            border.width: 1
                            border.color: {
                                if (notifCard.isHovered)
                                    return Qt.rgba(root.m3Primary.r, root.m3Primary.g, root.m3Primary.b, 0.15)
                                if (modelData.urgency === NotificationUrgency.Critical)
                                    return Qt.rgba(root.m3Error.r, root.m3Error.g, root.m3Error.b, 0.18)
                                if (modelData.urgency === NotificationUrgency.Low)
                                    return Qt.rgba(root.m3OnSurface.r, root.m3OnSurface.g, root.m3OnSurface.b, 0.06)
                                return root.m3Border
                            }
                        
                        Behavior on border.color {
                            ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                        }
                        
                        // Subtle layered shadow for depth
                        layer.enabled: true
                        layer.effect: MultiEffect {
                            shadowEnabled: true
                            shadowColor: Qt.rgba(0, 0, 0, 0.18 * animProgress)
                            shadowBlur: 0.6
                            shadowVerticalOffset: 4 * animProgress
                            shadowHorizontalOffset: 0
                        }
                        
                        // Inner glow / soft top edge
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 1
                            radius: parent.radius - 1
                            color: "transparent"
                            border.width: 1
                            border.color: Qt.rgba(1, 1, 1, 0.03)
                        }
                        
                        // Subtle urgency indicator - elegant pill
                        Rectangle {
                            width: 3
                            height: 24
                            anchors.left: parent.left
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            radius: 1.5
                            visible: true
                            opacity: modelData.urgency === NotificationUrgency.Low ? 0.55 : 0.85

                            color: root._urgencyColor(modelData.urgency)
                            
                            // Gentle pulse for critical only
                            SequentialAnimation on opacity {
                                running: modelData.urgency === NotificationUrgency.Critical
                                loops: Animation.Infinite
                                NumberAnimation { to: 0.4; duration: 1200; easing.type: Easing.InOutQuad }
                                NumberAnimation { to: 0.8; duration: 1200; easing.type: Easing.InOutQuad }
                            }
                        }
                        
                        // Minimal progress indicator - bottom edge line
                        Rectangle {
                            id: progressBar
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 20
                            anchors.rightMargin: 20
                            anchors.bottomMargin: 8
                            height: 2
                            radius: 1
                            color: Qt.rgba(root.m3OnSurface.r, root.m3OnSurface.g, root.m3OnSurface.b, 0.06)
                            clip: true
                            visible: notifCard.isVisible && !notifCard.isHovered
                            opacity: 0.8
                            
                            Rectangle {
                                id: progressFill
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                width: progressBar.width * notifCard.timeoutProgress
                                radius: parent.radius
                                color: {
                                    const c = root._urgencyColor(modelData.urgency)
                                    return Qt.rgba(c.r, c.g, c.b, 0.5)
                                }
                                
                                NumberAnimation {
                                    id: progressAnim
                                    target: notifCard
                                    property: "timeoutProgress"
                                    from: 1.0
                                    to: 0
                                    duration: config.notifications.timeoutMs
                                    running: notifCard.isVisible
                                    onFinished: if (notifCard.isVisible) notifCard.dismiss()
                                }
                            }
                        }

                        // Keep the timeout animation paused while hovered/dragging.
                        Connections {
                            target: notifCard

                            function onIsHoveredChanged() {
                                if (progressAnim.running)
                                    progressAnim.paused = notifCard.isHovered || notifCard.isDragging
                            }

                            function onIsDraggingChanged() {
                                if (progressAnim.running)
                                    progressAnim.paused = notifCard.isHovered || notifCard.isDragging
                            }
                        }
                        
                        // Subtle hover state
                        Rectangle {
                            id: hoverLayer
                            anchors.fill: parent
                            radius: parent.radius
                            color: root.m3OnSurface
                            opacity: notifCard.isHovered && !notifCard.isDragging ? 0.03 : 0
                            
                            Behavior on opacity {
                                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                            }
                        }

                        // Low/critical tint (keeps normal clean but distinct)
                        Rectangle {
                            anchors.fill: parent
                            radius: parent.radius
                            color: root._urgencyBg(modelData.urgency)
                            opacity: modelData.urgency === NotificationUrgency.Normal ? 0.0 : 1.0
                            visible: opacity > 0
                            z: -1
                        }
                        
                        // Main interaction area
                        MouseArea {
                            id: gestureArea
                            anchors.fill: parent
                            hoverEnabled: true
                            
                            property real startX: 0
                            property real startY: 0
                            property bool gestureStarted: false
                            
                            // Accumulated scroll for two-finger swipe
                            property real scrollAccumulator: 0
                            property bool isScrollSwiping: false
                            
                            onEntered: {
                                notifCard.isHovered = true
                            }
                            
                            onExited: {
                                if (!pressed && !isScrollSwiping) {
                                    notifCard.isHovered = false
                                }
                            }
                            
                            // Two-finger horizontal scroll to swipe dismiss
                            onWheel: wheel => {
                                // Check for horizontal scroll (trackpad two-finger swipe)
                                if (Math.abs(wheel.angleDelta.x) > Math.abs(wheel.angleDelta.y)) {
                                    wheel.accepted = true
                                    
                                    // Accumulate scroll delta
                                    scrollAccumulator += wheel.angleDelta.x * 0.5
                                    
                                    // Update visual position
                                    notifCard.dragX = scrollAccumulator
                                    isScrollSwiping = true
                                    notifCard.isDragging = true
                                    
                                    // Reset scroll timeout
                                    scrollResetTimer.restart()
                                    
                                    // Check if threshold reached for instant dismiss
                                    const threshold = config.notifications.popupWidth * root.swipeThreshold
                                    if (Math.abs(scrollAccumulator) > threshold) {
                                        scrollResetTimer.stop()
                                        isScrollSwiping = false
                                        notifCard.swipeDismiss(scrollAccumulator)
                                        scrollAccumulator = 0
                                    }
                                }
                            }
                            
                            // Timer to snap back if scroll stops before threshold
                            Timer {
                                id: scrollResetTimer
                                interval: 300
                                onTriggered: {
                                    gestureArea.isScrollSwiping = false
                                    notifCard.isDragging = false
                                    
                                    const threshold = config.notifications.popupWidth * root.swipeThreshold
                                    if (Math.abs(gestureArea.scrollAccumulator) > threshold) {
                                        notifCard.swipeDismiss(gestureArea.scrollAccumulator)
                                    } else {
                                        snapBackAnim.start()
                                    }
                                    gestureArea.scrollAccumulator = 0
                                }
                            }
                            
                            onPressed: mouse => {
                                startX = mouse.x
                                startY = mouse.y
                                gestureStarted = false
                                notifCard.isDragging = false
                                scrollAccumulator = 0
                            }
                            
                            onPositionChanged: mouse => {
                                if (!pressed) return
                                
                                const deltaX = mouse.x - startX
                                const deltaY = mouse.y - startY
                                
                                // Start drag if horizontal movement is significant
                                if (!gestureStarted && Math.abs(deltaX) > 10) {
                                    gestureStarted = true
                                    notifCard.isDragging = true
                                }
                                
                                if (notifCard.isDragging) {
                                    // Update drag position with resistance at edges
                                    notifCard.dragX = deltaX * 0.8
                                }
                            }
                            
                            onReleased: mouse => {
                                notifCard.isDragging = false
                                
                                if (!containsMouse) {
                                    notifCard.isHovered = false
                                }
                                
                                const threshold = config.notifications.popupWidth * root.swipeThreshold
                                
                                if (Math.abs(notifCard.dragX) > threshold) {
                                    // Swipe dismiss
                                    notifCard.swipeDismiss(notifCard.dragX)
                                } else {
                                    // Snap back
                                    snapBackAnim.start()
                                }
                            }
                            
                            // Middle click to dismiss
                            acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                            
                            onClicked: mouse => {
                                if (mouse.button === Qt.MiddleButton) {
                                    notifCard.dismiss()
                                } else if (!gestureStarted) {
                                    // Single click on action if only one action
                                    if (modelData.actions && modelData.actions.length === 1) {
                                        modelData.actions[0].invoke()
                                        notifCard.dismiss()
                                    }
                                }
                            }
                        }
                    
                        ColumnLayout {
                            id: contentLayout
                            anchors {
                                left: parent.left
                                right: parent.right
                                top: parent.top
                                margins: 16
                                leftMargin: modelData.urgency >= 1 ? 20 : 16
                            }
                            spacing: 8
                            
                            // Header row
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12
                                
                                // App icon - circular with subtle background
                                Rectangle {
                                    Layout.preferredWidth: 38
                                    Layout.preferredHeight: 38
                                    radius: 19
                                    visible: modelData.appIcon && modelData.appIcon.length > 0
                                    color: root.m3Accent
                                    
                                    Image {
                                        anchors.centerIn: parent
                                        width: 20
                                        height: 20
                                        source: {
                                            if (!modelData.appIcon) return ""
                                            if (modelData.appIcon.startsWith("/") || modelData.appIcon.startsWith("file://")) {
                                                return modelData.appIcon
                                            }
                                            return "image://icon/" + modelData.appIcon
                                        }
                                        fillMode: Image.PreserveAspectFit
                                        smooth: true
                                        cache: true
                                        asynchronous: true
                                        
                                        onStatusChanged: {
                                            if (status === Image.Error) {
                                                parent.visible = false
                                            }
                                        }
                                    }
                                }
                                
                                // Default icon if no app icon
                                Rectangle {
                                    Layout.preferredWidth: 38
                                    Layout.preferredHeight: 38
                                    radius: 19
                                    visible: !modelData.appIcon || modelData.appIcon.length === 0
                                    color: root.m3Accent
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰂞"
                                        font.family: "Material Design Icons"
                                        font.pixelSize: 16
                                        color: root.m3Primary
                                        opacity: 0.9
                                    }
                                }
                                
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1
                                    
                                    // App name - refined typography
                                    Text {
                                        text: modelData.appName || "Notification"
                                        font.pixelSize: 12
                                        font.weight: Font.Medium
                                        font.family: "Inter"
                                        font.letterSpacing: 0.3
                                        color: root.m3OnSurfaceVariant
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }
                                    
                                    // Timestamp - subtle
                                    Text {
                                        text: modelData.timeString || "now"
                                        font.pixelSize: 10
                                        font.family: "Inter"
                                        font.letterSpacing: 0.2
                                        color: Qt.rgba(root.m3OnSurface.r, root.m3OnSurface.g, root.m3OnSurface.b, 0.35)
                                    }
                                }
                                
                                // Close button - minimal circle
                                Rectangle {
                                    Layout.preferredWidth: 28
                                    Layout.preferredHeight: 28
                                    radius: 14
                                    color: closeMouseArea.pressed ? 
                                           Qt.rgba(root.m3Error.r, root.m3Error.g, root.m3Error.b, 0.15) :
                                           closeMouseArea.containsMouse ?
                                           Qt.rgba(root.m3OnSurface.r, root.m3OnSurface.g, root.m3OnSurface.b, 0.06) :
                                           "transparent"
                                    
                                    Behavior on color {
                                        ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
                                    }
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰅖"
                                        font.family: "Material Design Icons"
                                        font.pixelSize: 14
                                        color: closeMouseArea.containsMouse ? 
                                               root.m3Error : 
                                               Qt.rgba(root.m3OnSurface.r, root.m3OnSurface.g, root.m3OnSurface.b, 0.4)
                                        
                                        Behavior on color {
                                            ColorAnimation { duration: 150 }
                                        }
                                    }
                                    
                                    MouseArea {
                                        id: closeMouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: mouse => {
                                            mouse.accepted = true
                                            notifCard.dismiss()
                                        }
                                    }
                                }
                            }
                        
                            // Summary - clean headline
                            Text {
                                Layout.fillWidth: true
                                Layout.topMargin: 2
                                text: modelData.summary || ""
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                                font.family: "Inter"
                                font.letterSpacing: -0.1
                                color: root.m3OnSurface
                                wrapMode: Text.Wrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                                lineHeight: 1.25
                                visible: text.length > 0
                            }
                            
                            // Body - subtle secondary text
                            Text {
                                Layout.fillWidth: true
                                text: modelData.body || ""
                                font.pixelSize: 12
                                font.family: "Inter"
                                font.letterSpacing: 0.1
                                color: root.m3OnSurfaceVariant
                                wrapMode: Text.Wrap
                                maximumLineCount: notifCard.isExpanded ? 10 : 3
                                elide: Text.ElideRight
                                lineHeight: 1.35
                                visible: text.length > 0
                                
                                Behavior on maximumLineCount {
                                    NumberAnimation { duration: 200 }
                                }
                            }
                            
                            // Image preview - rounded with subtle border
                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 90
                                Layout.topMargin: 4
                                visible: modelData.image && modelData.image.length > 0
                                
                                Rectangle {
                                    anchors.fill: parent
                                    radius: 14
                                    clip: true
                                    color: root.m3SurfaceContainer
                                    border.width: 1
                                    border.color: root.m3Border
                                    
                                    Image {
                                        anchors.fill: parent
                                        anchors.margins: 1
                                        source: {
                                            if (!modelData.image) return ""
                                            if (modelData.image.startsWith("/") || modelData.image.startsWith("file://")) {
                                                return modelData.image
                                            }
                                            return "image://icon/" + modelData.image
                                        }
                                        fillMode: Image.PreserveAspectCrop
                                        smooth: true
                                        cache: true
                                        asynchronous: true
                                        
                                        // Rounded mask
                                        layer.enabled: true
                                        layer.effect: MultiEffect {
                                            maskEnabled: true
                                            maskThresholdMin: 0.5
                                            maskSpreadAtMin: 1.0
                                            maskSource: ShaderEffectSource {
                                                sourceItem: Rectangle {
                                                    width: 1
                                                    height: 1
                                                    radius: 13
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // Action buttons - pill shaped, minimal
                            Flow {
                                Layout.fillWidth: true
                                Layout.topMargin: 6
                                spacing: 6
                                visible: modelData.actions && modelData.actions.length > 0
                                
                                Repeater {
                                    model: notifCard.modelData.actions || []
                                    
                                    Rectangle {
                                        required property var modelData
                                        required property int index
                                        
                                        width: actionText.width + 20
                                        height: 30
                                        radius: 15
                                        
                                        // Subtle pill styling
                                        color: actionMouse.pressed ?
                                               Qt.rgba(root.m3Primary.r, root.m3Primary.g, root.m3Primary.b, 0.25) :
                                               actionMouse.containsMouse ?
                                               Qt.rgba(root.m3Primary.r, root.m3Primary.g, root.m3Primary.b, 0.15) :
                                               Qt.rgba(root.m3Primary.r, root.m3Primary.g, root.m3Primary.b, 0.08)
                                        
                                        Behavior on color {
                                            ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
                                        }
                                        
                                        Text {
                                            id: actionText
                                            anchors.centerIn: parent
                                            text: parent.modelData.text || parent.modelData.identifier
                                            font.pixelSize: 11
                                            font.weight: Font.Medium
                                            font.family: "Inter"
                                            font.letterSpacing: 0.3
                                            color: root.m3Primary
                                            opacity: actionMouse.pressed ? 0.8 : 1.0
                                        }
                                        
                                        MouseArea {
                                            id: actionMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                parent.modelData.invoke()
                                                notifCard.dismiss()
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // Swipe hint - minimal, only for first notification
                            Text {
                                id: swipeHint
                                Layout.fillWidth: true
                                Layout.topMargin: 2
                                text: "swipe to dismiss"
                                font.pixelSize: 9
                                font.family: "Inter"
                                font.letterSpacing: 0.5
                                color: root.m3OnSurfaceVariant
                                opacity: 0.35
                                horizontalAlignment: Text.AlignHCenter
                                visible: notifCard.index === 0 && notifCard.animProgress > 0.9 && hintVisible
                                
                                property bool hintVisible: true
                                
                                // Fade out after 2 seconds
                                Timer {
                                    interval: 3000
                                    running: swipeHint.visible
                                    onTriggered: swipeHint.hintVisible = false
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
