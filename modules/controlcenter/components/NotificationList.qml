import QtQuick 6.10
import QtQuick.Layouts 6.10
import QtQuick.Controls 6.10
import Quickshell
import "../../../components/effects"

Rectangle {
    id: root
    
    required property var notifs
    property var pywal
    
    // Solid color tokens from pywal
    readonly property color surfaceColor: pywal ? pywal.surfaceContainerLow : "#111111"
    readonly property color surfaceVariant: pywal ? pywal.surfaceContainerHigh : "#1a1a1a"
    readonly property color textColor: pywal ? pywal.foreground : "#dddddd"
    readonly property color textVariant: pywal ? Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.72) : "#999999"
    readonly property color accentColor: pywal ? pywal.primary : "#88cc88"
    readonly property color borderColor: pywal ? Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.08) : "#222222"
    
    Layout.fillWidth: true
    Layout.fillHeight: true
    
    radius: 20
    color: surfaceColor
    border.color: borderColor
    border.width: 1
    
    Behavior on color {
        ColorAnimation {
            duration: Material3Anim.medium2
            easing.bezierCurve: Material3Anim.standard
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12
        
        // Header
        RowLayout {
            Layout.fillWidth: true
            
            Text {
                text: "Notifications"
                font.family: "Inter"
                font.pixelSize: 16
                font.weight: Font.Bold
                color: root.textColor
            }
            
            Item { Layout.fillWidth: true }
            
            // Clear All Button
            Rectangle {
                id: clearAllBtn
                visible: (notifs.recentNotifications?.length ?? 0) > 0
                width: clearAllText.implicitWidth + 16
                height: 28
                radius: 14
                color: clearAllMouse.containsMouse 
                    ? Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.12)
                    : root.surfaceVariant
                
                Behavior on color {
                    ColorAnimation {
                        duration: Material3Anim.short3
                        easing.bezierCurve: Material3Anim.standard
                    }
                }
                
                Text {
                    id: clearAllText
                    anchors.centerIn: parent
                    text: "Clear All"
                    font.family: "Inter"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: root.textVariant
                }
                
                MouseArea {
                    id: clearAllMouse
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: notifs.clearAll()
                }
            }
        }
        
        // List
        ListView {
            id: notifListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 8
            
            model: notifs.recentNotifications ?? []
            
            // Smooth add/remove animations
            add: Transition {
                NumberAnimation { 
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: Material3Anim.medium2
                    easing.bezierCurve: Material3Anim.emphasizedDecelerate
                }
                NumberAnimation {
                    property: "scale"
                    from: 0.95
                    to: 1.0
                    duration: Material3Anim.medium2
                    easing.bezierCurve: Material3Anim.emphasizedDecelerate
                }
            }
            
            remove: Transition {
                NumberAnimation {
                    property: "opacity"
                    to: 0
                    duration: Material3Anim.short4
                    easing.bezierCurve: Material3Anim.emphasizedAccelerate
                }
            }
            
            delegate: Rectangle {
                id: notifDelegate
                required property var modelData
                required property int index
                
                width: notifListView.width
                height: notifContent.implicitHeight + 20
                radius: 14
                color: notifMouse.containsMouse 
                    ? Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.08)
                    : root.surfaceVariant
                
                Behavior on color {
                    ColorAnimation {
                        duration: Material3Anim.short3
                        easing.bezierCurve: Material3Anim.standard
                    }
                }
                
                // Press scale
                scale: notifMouse.pressed ? 0.98 : 1.0
                Behavior on scale {
                    NumberAnimation {
                        duration: Material3Anim.short2
                        easing.bezierCurve: Material3Anim.standard
                    }
                }
                
                MouseArea {
                    id: notifMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (modelData.actions && modelData.actions.length > 0) {
                            modelData.actions[0].invoke()
                        }
                    }
                }
                
                RowLayout {
                    id: notifContent
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 12
                    
                    // Icon
                    Rectangle {
                        Layout.preferredWidth: 42
                        Layout.preferredHeight: 42
                        Layout.alignment: Qt.AlignTop
                        radius: 12
                        color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.15)
                        
                        Image {
                            anchors.centerIn: parent
                            width: 24
                            height: 24
                            source: notifDelegate.modelData.appIcon 
                                ? (notifDelegate.modelData.appIcon.startsWith("/") 
                                    ? notifDelegate.modelData.appIcon 
                                    : "image://icon/" + notifDelegate.modelData.appIcon) 
                                : ""
                            visible: status === Image.Ready
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: "󰂚"
                            font.family: "Material Design Icons"
                            font.pixelSize: 20
                            color: root.accentColor
                            visible: !parent.children[0].visible
                        }
                    }
                    
                    // Text Content
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        
                        Text {
                            text: notifDelegate.modelData.summary ?? "Notification"
                            font.family: "Inter"
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                            color: root.textColor
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        
                        Text {
                            text: notifDelegate.modelData.body ?? ""
                            font.family: "Inter"
                            font.pixelSize: 12
                            color: root.textVariant
                            elide: Text.ElideRight
                            maximumLineCount: 2
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                            visible: text !== ""
                        }
                        
                        Text {
                            text: notifDelegate.modelData.appName ?? ""
                            font.family: "Inter"
                            font.pixelSize: 11
                            color: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.5)
                            Layout.fillWidth: true
                            visible: text !== ""
                        }
                    }
                    
                    // Close button
                    Rectangle {
                        id: closeBtn
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28
                        Layout.alignment: Qt.AlignTop
                        radius: 14
                        color: closeMouse.containsMouse 
                            ? Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.15)
                            : "transparent"
                        
                        Behavior on color {
                            ColorAnimation {
                                duration: Material3Anim.short2
                                easing.bezierCurve: Material3Anim.standard
                            }
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: "󰅖"
                            font.family: "Material Design Icons"
                            font.pixelSize: 16
                            color: closeMouse.containsMouse 
                                ? root.textColor 
                                : root.textVariant
                            
                            Behavior on color {
                                ColorAnimation {
                                    duration: Material3Anim.short2
                                    easing.bezierCurve: Material3Anim.standard
                                }
                            }
                        }
                        
                        MouseArea {
                            id: closeMouse
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: notifDelegate.modelData.close()
                        }
                    }
                }
            }
            
            // Empty State
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 8
                visible: (notifs.recentNotifications?.length ?? 0) === 0
                opacity: visible ? 1 : 0
                
                Behavior on opacity {
                    NumberAnimation {
                        duration: Material3Anim.medium2
                        easing.bezierCurve: Material3Anim.standard
                    }
                }
                
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "󰂚"
                    font.family: "Material Design Icons"
                    font.pixelSize: 48
                    color: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.2)
                }
                
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "No Notifications"
                    font.family: "Inter"
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    color: Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.4)
                }
            }
        }
    }
}
