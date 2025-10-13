import QtQuick 6.10
import QtQuick.Layouts 6.10
import QtQuick.Controls 6.10
import "../../../services" as QsServices

Item {
    id: root
    
    readonly property var notifs: QsServices.Notifs
    readonly property var pywal: QsServices.Pywal
    
    // Wait for pywal to load before showing content
    readonly property bool pywalLoaded: pywal && pywal.foreground !== undefined
    
    // Safe color accessors with fallbacks
    readonly property color textColor: pywalLoaded ? pywal.foreground : "#ffffff"
    readonly property color accentColor: pywalLoaded ? pywal.color4 : "#a6e3a1"
    readonly property color urgentColor: pywalLoaded ? pywal.color1 : "#f38ba8"
    readonly property color surfaceColor: pywalLoaded ? pywal.background : "#1e1e2e"
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16
        
        // Header with title and actions
        RowLayout {
            Layout.fillWidth: true
            spacing: 12
            
            Text {
                text: "Notifications"
                font.pixelSize: 20
                font.weight: Font.Bold
                color: root.textColor
                Layout.fillWidth: true
            }
            
            // DND Toggle
            Rectangle {
                width: 36
                height: 36
                radius: 18
                color: notifs.dnd ? root.accentColor : Qt.rgba(1, 1, 1, 0.1)
                
                Text {
                    anchors.centerIn: parent
                    text: notifs.dnd ? "󰂛" : "󰂚"
                    font.family: "Material Design Icons"
                    font.pixelSize: 18
                    color: notifs.dnd ? "#000000" : root.textColor
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: notifs.toggleDnd()
                }
                
                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
            }
            
            // Clear All Button
            Rectangle {
                width: 36
                height: 36
                radius: 18
                color: Qt.rgba(1, 1, 1, 0.1)
                visible: (notifs.recentNotifications?.length ?? 0) > 0
                
                Text {
                    anchors.centerIn: parent
                    text: "󰎟"
                    font.family: "Material Design Icons"
                    font.pixelSize: 18
                    color: root.textColor
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: notifs.clearAll()
                }
            }
        }
        
        // Notifications List
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Qt.rgba(0, 0, 0, 0.2)
            radius: 12
            
            ListView {
                id: notificationsList
                
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8
                clip: true
                
                model: notifs.recentNotifications ?? []
                
                // Empty state
                Text {
                    anchors.centerIn: parent
                    visible: notificationsList.count === 0
                    text: notifs.dnd ? "Do Not Disturb is enabled\n󰂛" : "No notifications\n󰂚"
                    font.pixelSize: 16
                    color: Qt.rgba(root.textColor.r, 
                                   root.textColor.g, 
                                   root.textColor.b, 0.5)
                    horizontalAlignment: Text.AlignHCenter
                    lineHeight: 1.4
                }
                
                delegate: Rectangle {
                    id: notifItem
                    
                    required property var modelData
                    
                    width: notificationsList.width
                    height: contentColumn.height + 16
                    radius: 10
                    color: modelData.urgency === 2 ? 
                           Qt.rgba(root.urgentColor.r,
                                  root.urgentColor.g,
                                  root.urgentColor.b, 0.2) :
                           Qt.rgba(1, 1, 1, 0.05)
                    
                    // Slightly dimmed if closed
                    opacity: modelData.closed ? 0.6 : 1.0
                    
                    // Hover effect
                    Rectangle {
                        anchors.fill: parent
                        radius: parent.radius
                        color: Qt.rgba(1, 1, 1, 0.05)
                        opacity: notifMouseArea.containsMouse ? 1 : 0
                        
                        Behavior on opacity {
                            NumberAnimation { duration: 150 }
                        }
                    }
                    
                    MouseArea {
                        id: notifMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                    }
                    
                    ColumnLayout {
                        id: contentColumn
                        
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 12
                        spacing: 8
                        
                        // Header: App icon, name, time, close button
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            
                            // App Icon
                            Rectangle {
                                width: 24
                                height: 24
                                radius: 6
                                color: Qt.rgba(1, 1, 1, 0.1)
                                visible: modelData.appIcon.length > 0
                                
                                Image {
                                    anchors.centerIn: parent
                                    width: 16
                                    height: 16
                                    source: modelData.appIcon
                                    fillMode: Image.PreserveAspectFit
                                }
                            }
                            
                            // App Name
                            Text {
                                text: modelData.appName || "Application"
                                font.pixelSize: 12
                                font.weight: Font.Medium
                                color: root.textColor
                                opacity: 0.7
                            }
                            
                            Item { Layout.fillWidth: true }
                            
                            // Timestamp
                            Text {
                                text: modelData.timeString
                                font.pixelSize: 11
                                color: root.textColor
                                opacity: 0.5
                            }
                            
                            // Close button
                            Rectangle {
                                width: 24
                                height: 24
                                radius: 12
                                color: closeMouseArea.containsMouse ? 
                                       Qt.rgba(1, 1, 1, 0.2) : "transparent"
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: "󰅖"
                                    font.family: "Material Design Icons"
                                    font.pixelSize: 14
                                    color: root.textColor
                                }
                                
                                MouseArea {
                                    id: closeMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: modelData.close()
                                }
                                
                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }
                            }
                        }
                        
                        // Summary
                        Text {
                            Layout.fillWidth: true
                            text: modelData.summary
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                            color: root.textColor
                            wrapMode: Text.Wrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                        }
                        
                        // Body
                        Text {
                            Layout.fillWidth: true
                            text: modelData.body
                            font.pixelSize: 12
                            color: root.textColor
                            opacity: 0.8
                            wrapMode: Text.Wrap
                            maximumLineCount: 3
                            elide: Text.ElideRight
                            visible: modelData.body.length > 0
                        }
                        
                        // Image
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 120
                            radius: 8
                            clip: true
                            visible: modelData.image.length > 0
                            color: "transparent"
                            
                            Image {
                                anchors.fill: parent
                                source: modelData.image
                                fillMode: Image.PreserveAspectCrop
                            }
                        }
                        
                        // Actions
                        Flow {
                            Layout.fillWidth: true
                            spacing: 8
                            visible: modelData.actions && modelData.actions.length > 0
                            
                            Repeater {
                                model: modelData.actions || []
                                
                                Rectangle {
                                    width: actionText.width + 16
                                    height: 28
                                    radius: 6
                                    color: actionMouseArea.containsMouse ?
                                           root.accentColor :
                                           Qt.rgba(1, 1, 1, 0.1)
                                    
                                    Text {
                                        id: actionText
                                        anchors.centerIn: parent
                                        text: modelData.text || modelData.identifier
                                        font.pixelSize: 11
                                        font.weight: Font.Medium
                                        color: actionMouseArea.containsMouse ?
                                               "#000000" : root.textColor
                                    }
                                    
                                    MouseArea {
                                        id: actionMouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            notifItem.modelData.invokeAction(modelData.identifier);
                                            notifItem.modelData.close();
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
        
        // DND Status Text
        Text {
            Layout.fillWidth: true
            text: notifs.dnd ? "󰂛 Do Not Disturb enabled - notifications are silenced" : ""
            font.pixelSize: 12
            color: root.accentColor
            horizontalAlignment: Text.AlignHCenter
            visible: notifs.dnd
            opacity: 0.8
        }
    }
}
