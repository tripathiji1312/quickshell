import QtQuick 6.10
import QtQuick.Layouts 6.10
import QtQuick.Controls 6.10
import Quickshell

Rectangle {
    id: root
    
    required property var notifs
    property var pywal
    
    Layout.fillWidth: true
    Layout.fillHeight: true
    
    radius: 24
    color: Qt.rgba(1, 1, 1, 0.05)
    border.color: Qt.rgba(1, 1, 1, 0.1)
    border.width: 1
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 12
        
        // Header
        RowLayout {
            Layout.fillWidth: true
            
            Text {
                text: "Notifications"
                font.family: "Inter"
                font.pixelSize: 16
                font.weight: Font.Bold
                color: "#e6e6e6"
            }
            
            Item { Layout.fillWidth: true }
            
            // Clear All
            Text {
                text: "Clear All"
                font.family: "Inter"
                font.pixelSize: 12
                color: Qt.rgba(1, 1, 1, 0.5)
                visible: notifs.count > 0
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: notifs.clearAll()
                }
            }
        }
        
        // List
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 8
            
            model: notifs.recentNotifications
            
            delegate: Rectangle {
                width: ListView.view.width
                height: 70
                radius: 16
                color: Qt.rgba(1, 1, 1, 0.08)
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12
                    
                    // Icon
                    Rectangle {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        radius: 12
                        color: Qt.rgba(1, 1, 1, 0.1)
                        
                        Image {
                            anchors.centerIn: parent
                            width: 24
                            height: 24
                            source: modelData.appIcon ? (modelData.appIcon.startsWith("/") ? modelData.appIcon : "image://icon/" + modelData.appIcon) : ""
                            visible: status === Image.Ready
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: "󰂚"
                            font.family: "Material Design Icons"
                            font.pixelSize: 20
                            color: "#e6e6e6"
                            visible: !parent.children[0].visible
                        }
                    }
                    
                    // Text
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        
                        Text {
                            text: modelData.summary
                            font.family: "Inter"
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                            color: "#e6e6e6"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        
                        Text {
                            text: modelData.body
                            font.family: "Inter"
                            font.pixelSize: 12
                            color: Qt.rgba(1, 1, 1, 0.7)
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }
                    
                    // Close
                    Text {
                        text: "×"
                        font.pixelSize: 20
                        color: Qt.rgba(1, 1, 1, 0.5)
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: modelData.close()
                        }
                    }
                }
            }
            
            // Empty State
            Text {
                anchors.centerIn: parent
                text: "No Notifications"
                font.family: "Inter"
                font.pixelSize: 14
                color: Qt.rgba(1, 1, 1, 0.3)
                visible: notifs.count === 0
            }
        }
    }
}
