import QtQuick 6.10
import QtQuick.Layouts 6.10
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import "../../../services" as QsServices

// Modern minimal notification popup window
PanelWindow {
    id: root
    
    readonly property var pywal: QsServices.Pywal
    readonly property var notifs: QsServices.Notifs
    
    // Get popups that should be shown (max 5 at a time, newest first)
    readonly property var activePopups: notifs.activeNotifications.slice(0, 5)
    
    screen: Quickshell.screens[0]
    
    anchors {
        top: true
        right: true
    }
    
    margins {
        top: 8      // Much closer to bar
        right: 12   // Slightly less margin
    }
    
    visible: activePopups.length > 0
    color: "transparent"
    
    implicitWidth: 340   // Reduced from 380
    implicitHeight: notifColumn.implicitHeight
    
    // Smooth height transition
    Behavior on implicitHeight {
        NumberAnimation { 
            duration: 250
            easing.type: Easing.OutCubic
        }
    }
    
    Column {
        id: notifColumn
        width: parent.width
        spacing: 6  // Reduced from 12
        
        Repeater {
            model: root.activePopups
            
            // Modern notification card
            Item {
                id: notifCard
                
                required property var modelData
                required property int index
                
                width: 340  // Match new width
                height: cardBg.visible ? cardBg.height : 0
                
                // Individual visibility for smooth removal
                property bool isVisible: true
                
                // Only animate if not already animated (prevents re-animation bug)
                Component.onCompleted: {
                    if (!modelData.hasAnimated) {
                        modelData.hasAnimated = true
                        expandAnim.start()
                        slideAnim.start()
                    }
                }
                
                // Smooth removal animation
                Behavior on height {
                    enabled: !notifCard.isVisible
                    NumberAnimation { 
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }
                
                Behavior on opacity {
                    enabled: !notifCard.isVisible
                    NumberAnimation { duration: 200 }
                }
                
                opacity: isVisible ? 1 : 0
                
                Rectangle {
                    id: cardBg
                    width: parent.width
                    height: contentLayout.implicitHeight + 20
                    radius: 10
                    
                    // Transform origin at top-right corner for expand effect
                    transformOrigin: Item.TopRight
                    
                    // Glassmorphic background
                    color: Qt.rgba(
                        pywal?.background.r ?? 0.1,
                        pywal?.background.g ?? 0.1,
                        pywal?.background.b ?? 0.1,
                        0.92
                    )
                    
                    // Subtle border
                    border.width: 1
                    border.color: Qt.rgba(
                        pywal?.foreground.r ?? 1,
                        pywal?.foreground.g ?? 1,
                        pywal?.foreground.b ?? 1,
                        0.12
                    )
                    
                    // Urgent notification accent
                    Rectangle {
                        width: 3
                        height: parent.height - 8
                        anchors.left: parent.left
                        anchors.leftMargin: 4
                        anchors.verticalCenter: parent.verticalCenter
                        radius: 1.5
                        color: pywal?.color1 ?? "#f38ba8"
                        visible: modelData.urgency === 2
                    }
                    
                    // Expand from corner animation - smooth
                    scale: 1
                    NumberAnimation {
                        id: expandAnim
                        target: cardBg
                        property: "scale"
                        from: 0.85
                        to: 1.0
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                    
                    // Slide in from right animation
                    transform: Translate {
                        id: slideTransform
                        x: 0
                    }
                    
                    NumberAnimation {
                        id: slideAnim
                        target: slideTransform
                        property: "x"
                        from: 40
                        to: 0
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                    
                    // Auto-dismiss timer (7 seconds)
                    Timer {
                        interval: 7000
                        running: notifCard.isVisible
                        onTriggered: {
                            notifCard.isVisible = false
                            Qt.callLater(() => modelData.close())
                        }
                    }
                    
                    // Hover interaction
                    MouseArea {
                        id: cardMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        
                        // Subtle hover highlight
                        Rectangle {
                            anchors.fill: parent
                            radius: parent.parent.radius
                            color: Qt.rgba(1, 1, 1, 0.05)
                            opacity: cardMouseArea.containsMouse ? 1 : 0
                            
                            Behavior on opacity {
                                NumberAnimation { duration: 150 }
                            }
                        }
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
                        
                        // Header row
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            
                            // App icon
                            Item {
                                Layout.preferredWidth: 24
                                Layout.preferredHeight: 24
                                visible: modelData.appIcon && modelData.appIcon.length > 0
                                
                                Image {
                                    anchors.fill: parent
                                    source: modelData.appIcon || ""
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
                                    
                                    layer.enabled: true
                                    layer.effect: MultiEffect {
                                        brightness: 0.1
                                        saturation: 0.8
                                    }
                                }
                            }
                            
                            // App name
                            Text {
                                text: modelData.appName || "Notification"
                                font.pixelSize: 11
                                font.weight: Font.Medium
                                font.family: "Inter"
                                color: pywal?.foreground ?? "#ffffff"
                                opacity: 0.6
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                            
                            // Timestamp
                            Text {
                                text: modelData.timeString || "now"
                                font.pixelSize: 10
                                font.family: "Inter"
                                color: pywal?.foreground ?? "#ffffff"
                                opacity: 0.5
                            }
                            
                            // Close button
                            Rectangle {
                                Layout.preferredWidth: 28
                                Layout.preferredHeight: 28
                                radius: 14
                                color: closeMouseArea.containsMouse ? 
                                       Qt.rgba(1, 0.3, 0.3, 0.2) : "transparent"
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "×"
                                    font.pixelSize: 18
                                    font.weight: Font.Light
                                    color: pywal?.foreground ?? "#ffffff"
                                    opacity: closeMouseArea.containsMouse ? 1 : 0.5
                                }
                                
                                MouseArea {
                                    id: closeMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        mouse.accepted = true
                                        notifCard.isVisible = false
                                        Qt.callLater(() => modelData.close())
                                    }
                                }
                                
                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }
                            }
                        }
                        
                        // Summary (title)
                        Text {
                            Layout.fillWidth: true
                            text: modelData.summary || ""
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                            font.family: "Inter"
                            color: pywal?.foreground ?? "#ffffff"
                            wrapMode: Text.Wrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                            lineHeight: 1.2
                        }
                        
                        // Body
                        Text {
                            Layout.fillWidth: true
                            text: modelData.body || ""
                            font.pixelSize: 12
                            font.family: "Inter"
                            color: pywal?.foreground ?? "#ffffff"
                            opacity: 0.85
                            wrapMode: Text.Wrap
                            maximumLineCount: 3
                            elide: Text.ElideRight
                            lineHeight: 1.3
                            visible: modelData.body && modelData.body.length > 0
                        }
                        
                        // Image
                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 90
                            visible: modelData.image && modelData.image.length > 0
                            
                            Rectangle {
                                anchors.fill: parent
                                radius: 6
                                clip: true
                                color: Qt.rgba(0, 0, 0, 0.3)
                                
                                Image {
                                    anchors.fill: parent
                                    source: modelData.image || ""
                                    fillMode: Image.PreserveAspectCrop
                                    smooth: true
                                }
                            }
                        }
                        
                        // Action buttons
                        Flow {
                            Layout.fillWidth: true
                            spacing: 6
                            visible: modelData.actions && modelData.actions.length > 0
                            
                            Repeater {
                                model: modelData.actions || []
                                
                                Rectangle {
                                    width: actionText.width + 16
                                    height: 28
                                    radius: 6
                                    color: actionMouse.containsMouse ?
                                           Qt.rgba(pywal?.color4.r ?? 0.6, 
                                                  pywal?.color4.g ?? 0.9,
                                                  pywal?.color4.b ?? 0.6, 0.3) :
                                           Qt.rgba(1, 1, 1, 0.08)
                                    
                                    Text {
                                        id: actionText
                                        anchors.centerIn: parent
                                        text: modelData.text || modelData.identifier
                                        font.pixelSize: 11
                                        font.weight: Font.Medium
                                        font.family: "Inter"
                                        color: pywal?.foreground ?? "#ffffff"
                                    }
                                    
                                    MouseArea {
                                        id: actionMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            modelData.invoke()
                                            notifCard.isVisible = false
                                            Qt.callLater(() => notifCard.modelData.close())
                                        }
                                    }
                                    
                                    Behavior on color {
                                        ColorAnimation { duration: 150 }
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
