import QtQuick 6.10
import QtQuick.Layouts 6.10
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import "../../../services" as QsServices

// Material 3 Expressive notification popup window
PanelWindow {
    id: root
    
    readonly property var pywal: QsServices.Pywal
    readonly property var notifs: QsServices.Notifs
    
    // Modern color scheme - fully opaque
    readonly property color m3Surface: Qt.rgba(
        pywal?.background.r ?? 0.11,
        pywal?.background.g ?? 0.11,
        pywal?.background.b ?? 0.12,
        1.0
    )
    readonly property color m3Primary: pywal?.color4 ?? "#a6e3a1"
    readonly property color m3OnSurface: pywal?.foreground ?? "#e6e6e6"
    readonly property color m3Error: pywal?.color1 ?? "#f38ba8"
    
    // Get popups that should be shown (max 5 at a time, newest first)
    readonly property var activePopups: notifs.activeNotifications.slice(0, 5)
    
    screen: Quickshell.screens[0]
    
    anchors {
        top: true
        right: true
    }
    
    margins {
        top: 12
        right: 16
    }
    
    visible: activePopups.length > 0
    color: "transparent"
    
    implicitWidth: 340
    implicitHeight: notifColumn.implicitHeight
    
    // Smooth fast transition
    Behavior on implicitHeight {
        NumberAnimation { 
            duration: 250
            easing.type: Easing.OutCubic
        }
    }
    
    Column {
        id: notifColumn
        width: parent.width
        spacing: 8
        
        // Smooth fast motion
        move: Transition {
            NumberAnimation {
                properties: "y"
                duration: 250
                easing.type: Easing.OutCubic
            }
        }
        
        Repeater {
            model: root.activePopups
            
            // Material 3 notification card
            Item {
                id: notifCard
                
                required property var modelData
                required property int index
                
                width: 340
                height: cardBg.visible ? cardBg.height : 0
                
                property bool isVisible: true
                property real animProgress: 0
                
                // Fast smooth entrance
                Component.onCompleted: {
                    if (!modelData.hasAnimated) {
                        modelData.hasAnimated = true
                        entranceAnim.start()
                    } else {
                        animProgress = 1.0
                    }
                }
                
                ParallelAnimation {
                    id: entranceAnim
                    
                    NumberAnimation {
                        target: notifCard
                        property: "animProgress"
                        from: 0.0
                        to: 1.0
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                }
                
                // Fast exit
                ParallelAnimation {
                    id: exitAnim
                    
                    NumberAnimation {
                        target: notifCard
                        property: "animProgress"
                        to: 0.0
                        duration: 200
                        easing.type: Easing.InCubic
                    }
                    
                    NumberAnimation {
                        target: notifCard
                        property: "opacity"
                        to: 0
                        duration: 200
                    }
                    
                    onFinished: modelData.close()
                }
                
                function dismiss() {
                    isVisible = false
                    exitAnim.start()
                }
                
                // Modern card container - simple slide + fade
                Item {
                    id: cardContainer
                    width: parent.width
                    height: cardBg.height
                    
                    // Simple smooth slide from right
                    scale: 0.95 + (animProgress * 0.05)
                    transform: Translate {
                        x: (1.0 - animProgress) * 50
                    }
                    
                    Rectangle {
                        id: cardBg
                        width: parent.width
                        height: contentLayout.implicitHeight + 20
                        radius: 12
                        
                        // Opaque modern surface
                        color: root.m3Surface
                        
                        // Subtle elevation shadow
                        layer.enabled: true
                        layer.effect: MultiEffect {
                            shadowEnabled: true
                            shadowColor: Qt.rgba(0, 0, 0, 0.3 * animProgress)
                            shadowBlur: 0.6
                            shadowVerticalOffset: 4 * animProgress
                            shadowHorizontalOffset: 0
                        }
                        
                        // Urgent indicator - Material 3 style
                        Rectangle {
                            width: 4
                            height: parent.height
                            anchors.left: parent.left
                            radius: 2
                            visible: modelData.urgency === 2
                            
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: root.m3Error }
                                GradientStop { position: 1.0; color: Qt.darker(root.m3Error, 1.3) }
                            }
                        }
                        
                        // Auto-dismiss timer
                        Timer {
                            interval: 7000
                            running: notifCard.isVisible
                            onTriggered: notifCard.dismiss()
                        }
                        
                        // Material 3 ripple effect on hover
                        Rectangle {
                            id: hoverLayer
                            anchors.fill: parent
                            radius: parent.radius
                            color: Qt.rgba(root.m3Primary.r, root.m3Primary.g, root.m3Primary.b, 0.08)
                            opacity: cardMouseArea.containsMouse ? 1 : 0
                            
                            Behavior on opacity {
                                NumberAnimation { 
                                    duration: 200
                                    easing.type: Easing.Bezier
                                    easing.bezierCurve: [0.4, 0.0, 0.2, 1.0]  // Standard
                                }
                            }
                        }
                        
                        MouseArea {
                            id: cardMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                        }
                    
                        ColumnLayout {
                            id: contentLayout
                            anchors {
                                left: parent.left
                                right: parent.right
                                top: parent.top
                                margins: 14
                            }
                            spacing: 6
                            
                            // Compact header
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 10
                                
                                // App icon - compact
                                Rectangle {
                                    Layout.preferredWidth: 32
                                    Layout.preferredHeight: 32
                                    radius: 16
                                    visible: modelData.appIcon && modelData.appIcon.length > 0
                                    color: Qt.rgba(root.m3Primary.r, root.m3Primary.g, root.m3Primary.b, 0.15)
                                    
                                    Image {
                                        anchors.centerIn: parent
                                        width: 20
                                        height: 20
                                        source: modelData.appIcon || ""
                                        fillMode: Image.PreserveAspectFit
                                        smooth: true
                                    }
                                }
                                
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1
                                    
                                    // App name - compact
                                    Text {
                                        text: modelData.appName || "Notification"
                                        font.pixelSize: 12
                                        font.weight: Font.Medium
                                        font.family: "Inter"
                                        color: root.m3OnSurface
                                        opacity: 0.87
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }
                                    
                                    // Timestamp - small
                                    Text {
                                        text: modelData.timeString || "now"
                                        font.pixelSize: 10
                                        font.family: "Inter"
                                        color: root.m3OnSurface
                                        opacity: 0.5
                                    }
                                }
                                
                                // Compact close button
                                Rectangle {
                                    Layout.preferredWidth: 32
                                    Layout.preferredHeight: 32
                                    radius: 16
                                    color: closeMouseArea.pressed ? 
                                           Qt.rgba(root.m3Error.r, root.m3Error.g, root.m3Error.b, 0.2) :
                                           closeMouseArea.containsMouse ?
                                           Qt.rgba(root.m3OnSurface.r, root.m3OnSurface.g, root.m3OnSurface.b, 0.08) :
                                           "transparent"
                                    
                                    // Close icon
                                    Text {
                                        anchors.centerIn: parent
                                        text: "×"
                                        font.pixelSize: 20
                                        font.weight: Font.Light
                                        color: root.m3OnSurface
                                        opacity: closeMouseArea.containsMouse ? 1 : 0.6
                                    }
                                    
                                    // Ripple effect
                                    Rectangle {
                                        id: closeRipple
                                        anchors.centerIn: parent
                                        width: parent.width
                                        height: parent.height
                                        radius: parent.radius
                                        color: Qt.rgba(root.m3OnSurface.r, root.m3OnSurface.g, root.m3OnSurface.b, 0.12)
                                        scale: 0
                                        opacity: 0
                                        
                                        SequentialAnimation {
                                            id: rippleAnim
                                            ParallelAnimation {
                                                NumberAnimation { target: closeRipple; property: "scale"; to: 1; duration: 300 }
                                                NumberAnimation { target: closeRipple; property: "opacity"; to: 1; duration: 100 }
                                            }
                                            NumberAnimation { target: closeRipple; property: "opacity"; to: 0; duration: 200 }
                                            ScriptAction { script: { closeRipple.scale = 0 } }
                                        }
                                    }
                                    
                                    MouseArea {
                                        id: closeMouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onPressed: rippleAnim.start()
                                        onClicked: {
                                            mouse.accepted = true
                                            notifCard.dismiss()
                                        }
                                    }
                                    
                                    Behavior on color {
                                        ColorAnimation { 
                                            duration: 200
                                            easing.type: Easing.Bezier
                                            easing.bezierCurve: [0.4, 0.0, 0.2, 1.0]
                                        }
                                    }
                                }
                            }
                        
                            // Summary - compact
                            Text {
                                Layout.fillWidth: true
                                text: modelData.summary || ""
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                                font.family: "Inter"
                                color: root.m3OnSurface
                                wrapMode: Text.Wrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                                lineHeight: 1.3
                            }
                            
                            // Body - compact
                            Text {
                                Layout.fillWidth: true
                                text: modelData.body || ""
                                font.pixelSize: 12
                                font.family: "Inter"
                                color: root.m3OnSurface
                                opacity: 0.75
                                wrapMode: Text.Wrap
                                maximumLineCount: 3
                                elide: Text.ElideRight
                                lineHeight: 1.4
                                visible: modelData.body && modelData.body.length > 0
                            }
                            
                            // Image - compact
                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 90
                                visible: modelData.image && modelData.image.length > 0
                                
                                Rectangle {
                                    anchors.fill: parent
                                    radius: 8
                                    clip: true
                                    color: Qt.rgba(0, 0, 0, 0.2)
                                    
                                    Image {
                                        anchors.fill: parent
                                        source: modelData.image || ""
                                        fillMode: Image.PreserveAspectCrop
                                        smooth: true
                                    }
                                }
                            }
                            
                            // Action buttons - compact
                            Flow {
                                Layout.fillWidth: true
                                spacing: 6
                                visible: modelData.actions && modelData.actions.length > 0
                                
                                Repeater {
                                    model: modelData.actions || []
                                    
                                    Rectangle {
                                        width: actionText.width + 20
                                        height: 32
                                        radius: 16
                                        color: actionMouse.pressed ?
                                               Qt.rgba(root.m3Primary.r, root.m3Primary.g, root.m3Primary.b, 0.18) :
                                               actionMouse.containsMouse ?
                                               Qt.rgba(root.m3Primary.r, root.m3Primary.g, root.m3Primary.b, 0.12) :
                                               Qt.rgba(root.m3Primary.r, root.m3Primary.g, root.m3Primary.b, 0.08)
                                        
                                        Text {
                                            id: actionText
                                            anchors.centerIn: parent
                                            text: modelData.text || modelData.identifier
                                            font.pixelSize: 12
                                            font.weight: Font.Medium
                                            font.family: "Inter"
                                            color: root.m3Primary
                                        }
                                        
                                        MouseArea {
                                            id: actionMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                modelData.invoke()
                                                notifCard.dismiss()
                                            }
                                        }
                                        
                                        Behavior on color {
                                            ColorAnimation { 
                                                duration: 150
                                                easing.type: Easing.OutCubic
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
