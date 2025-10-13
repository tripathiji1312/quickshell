import QtQuick 6.10
import QtQuick.Layouts 6.10
import Quickshell
import Quickshell.Wayland
import "../../../services" as QsServices

// Notification popup window that appears in top-right corner
PanelWindow {
    id: root
    
    readonly property var pywal: QsServices.Pywal
    readonly property var notifs: QsServices.Notifs
    
    // Get popups that should be shown
    readonly property var activePopups: notifs.activeNotifications.slice(0, 5) // Show max 5
    
    screen: Quickshell.screens[0]
    
    anchors {
        top: true
        right: true
    }
    
    margins {
        top: 50
        right: 10
    }
    
    visible: activePopups.length > 0
    
    onActivePopupsChanged: {
        console.log("🔔 Notification popups:", activePopups.length, "visible:", visible)
    }
    
    Component.onCompleted: {
        console.log("🔔 NotificationPopups window initialized")
    }
    color: "transparent"
    
    implicitWidth: 400
    implicitHeight: Math.max(notifColumn.implicitHeight, 100) // Minimum height for visibility
    
    // Debug background
    Rectangle {
        anchors.fill: parent
        color: "red"
        opacity: 0.3
        visible: root.activePopups.length > 0
    }
    
    Column {
        id: notifColumn
        anchors.fill: parent
        spacing: 8
        
        Repeater {
            model: root.activePopups
            
            Rectangle {
                id: notifCard
                
                required property var modelData
                required property int index
                
                width: 400
                height: contentLayout.height + 20
                radius: 12
                color: modelData.urgency === 2 ?
                       Qt.rgba(pywal?.color1.r ?? 1, pywal?.color1.g ?? 0.5, pywal?.color1.b ?? 0.5, 0.95) :
                       Qt.rgba(pywal?.background.r ?? 0.1, pywal?.background.g ?? 0.1, pywal?.background.b ?? 0.1, 0.95)
                
                border.width: 1
                border.color: Qt.rgba(pywal?.foreground.r ?? 1, pywal?.foreground.g ?? 1, pywal?.foreground.b ?? 1, 0.2)
                
                // Slide in from right animation
                x: showAnim.running ? 420 : 0
                opacity: showAnim.running ? 0 : 1
                
                SequentialAnimation {
                    id: showAnim
                    running: true
                    
                    PauseAnimation { duration: index * 100 }
                    
                    ParallelAnimation {
                        NumberAnimation { target: notifCard; property: "x"; from: 420; to: 0; duration: 300; easing.type: Easing.OutBack }
                        NumberAnimation { target: notifCard; property: "opacity"; from: 0; to: 1; duration: 300 }
                    }
                }
                
                // Auto-hide after 5 seconds
                Timer {
                    interval: 5000
                    running: true
                    onTriggered: modelData.close()
                }
                
                // Mouse interaction
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        // Open Control Center to notifications
                        // For now, just close this notification
                        modelData.close()
                    }
                    
                    Rectangle {
                        anchors.fill: parent
                        radius: parent.parent.radius
                        color: Qt.rgba(1, 1, 1, 0.1)
                        opacity: parent.containsMouse ? 1 : 0
                        
                        Behavior on opacity {
                            NumberAnimation { duration: 150 }
                        }
                    }
                }
                
                ColumnLayout {
                    id: contentLayout
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 15
                    spacing: 8
                    
                    // Header row
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        // App icon
                        Rectangle {
                            width: 32
                            height: 32
                            radius: 8
                            color: Qt.rgba(1, 1, 1, 0.1)
                            visible: modelData.appIcon && modelData.appIcon.length > 0
                            
                            Image {
                                anchors.centerIn: parent
                                width: 24
                                height: 24
                                source: modelData.appIcon || ""
                                fillMode: Image.PreserveAspectFit
                            }
                        }
                        
                        // App name
                        Text {
                            text: modelData.appName || "Notification"
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: pywal?.foreground ?? "#ffffff"
                            opacity: 0.8
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Close button
                        Rectangle {
                            width: 24
                            height: 24
                            radius: 12
                            color: closeMouseArea.containsMouse ? Qt.rgba(1, 0, 0, 0.3) : "transparent"
                            
                            Text {
                                anchors.centerIn: parent
                                text: "✕"
                                font.pixelSize: 14
                                color: pywal?.foreground ?? "#ffffff"
                            }
                            
                            MouseArea {
                                id: closeMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    mouse.accepted = true
                                    modelData.close()
                                }
                            }
                        }
                    }
                    
                    // Summary (title)
                    Text {
                        Layout.fillWidth: true
                        text: modelData.summary || ""
                        font.pixelSize: 15
                        font.weight: Font.Bold
                        color: pywal?.foreground ?? "#ffffff"
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }
                    
                    // Body
                    Text {
                        Layout.fillWidth: true
                        text: modelData.body || ""
                        font.pixelSize: 13
                        color: pywal?.foreground ?? "#ffffff"
                        opacity: 0.9
                        wrapMode: Text.Wrap
                        maximumLineCount: 3
                        elide: Text.ElideRight
                        visible: modelData.body && modelData.body.length > 0
                    }
                    
                    // Image
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 100
                        radius: 8
                        clip: true
                        visible: modelData.image && modelData.image.length > 0
                        color: "transparent"
                        
                        Image {
                            anchors.fill: parent
                            source: modelData.image || ""
                            fillMode: Image.PreserveAspectCrop
                        }
                    }
                }
            }
        }
    }
}
