import QtQuick 6.10
import QtQuick.Layouts 6.10
import Quickshell
import Quickshell.Wayland
import "../../services" as QsServices

PanelWindow {
    id: root
    
    property bool shouldShow: false
    readonly property var pywal: QsServices.Pywal
    
    // Active section: "settings", "performance", "media", "notifications"
    property string activeSection: "settings"
    
    screen: Quickshell.screens[0]
    
    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }
    
    color: "transparent"
    visible: shouldShow
    
    // Mouse area to close on click outside
    MouseArea {
        anchors.fill: parent
        onClicked: root.shouldShow = false
        enabled: root.shouldShow
    }
    
    // Control Center Panel - expands from top right corner
    Rectangle {
        id: panel
        
        width: 480
        height: 600
        
        // Position at top right with gap
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 6
        anchors.rightMargin: 6
        
        // Transform origin for scale animation
        transformOrigin: Item.TopRight
        
        // Scale animation - expands from corner
        scale: root.shouldShow ? 1.0 : 0.0
        
        Behavior on scale {
            NumberAnimation { 
                duration: 350
                easing.type: Easing.OutBack
                easing.overshoot: 1.2
            }
        }
        
        // Opacity fade
        opacity: root.shouldShow ? 0.98 : 0
        
        Behavior on opacity {
            NumberAnimation { 
                duration: 250
                easing.type: Easing.OutCubic
            }
        }
        
        color: pywal.background
        opacity: 0.98
        radius: 16
        
        border.color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.15)
        border.width: 1
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 0
            spacing: 0
            
            // Header with section tabs
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 56
                color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.05)
                radius: 16
                
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: parent.height / 2
                    color: parent.color
                }
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 4
                    
                    // Settings tab
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 10
                        color: root.activeSection === "settings" ? 
                               Qt.rgba(pywal.color2.r, pywal.color2.g, pywal.color2.b, 0.15) : 
                               "transparent"
                        
                        Behavior on color {
                            ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                        }
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 2
                            
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "󰒓"
                                font.family: "Material Design Icons"
                                font.pixelSize: 20
                                color: root.activeSection === "settings" ? pywal.color2 : pywal.foreground
                                
                                Behavior on color {
                                    ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                                }
                            }
                            
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Settings"
                                font.family: "Inter"
                                font.pixelSize: 10
                                font.weight: Font.Medium
                                color: root.activeSection === "settings" ? pywal.color2 : Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.7)
                                
                                Behavior on color {
                                    ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                                }
                            }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.activeSection = "settings"
                        }
                    }
                    
                    // Performance tab
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 10
                        color: root.activeSection === "performance" ? 
                               Qt.rgba(pywal.color3.r, pywal.color3.g, pywal.color3.b, 0.15) : 
                               "transparent"
                        
                        Behavior on color {
                            ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                        }
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 2
                            
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "󰓅"
                                font.family: "Material Design Icons"
                                font.pixelSize: 20
                                color: root.activeSection === "performance" ? pywal.color3 : pywal.foreground
                                
                                Behavior on color {
                                    ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                                }
                            }
                            
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Performance"
                                font.family: "Inter"
                                font.pixelSize: 10
                                font.weight: Font.Medium
                                color: root.activeSection === "performance" ? pywal.color3 : Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.7)
                                
                                Behavior on color {
                                    ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                                }
                            }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.activeSection = "performance"
                        }
                    }
                    
                    // Media tab
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 10
                        color: root.activeSection === "media" ? 
                               Qt.rgba(pywal.color1.r, pywal.color1.g, pywal.color1.b, 0.15) : 
                               "transparent"
                        
                        Behavior on color {
                            ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                        }
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 2
                            
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "󰝚"
                                font.family: "Material Design Icons"
                                font.pixelSize: 20
                                color: root.activeSection === "media" ? pywal.color1 : pywal.foreground
                                
                                Behavior on color {
                                    ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                                }
                            }
                            
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Media"
                                font.family: "Inter"
                                font.pixelSize: 10
                                font.weight: Font.Medium
                                color: root.activeSection === "media" ? pywal.color1 : Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.7)
                                
                                Behavior on color {
                                    ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                                }
                            }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.activeSection = "media"
                        }
                    }
                    
                    // Notifications tab
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 10
                        color: root.activeSection === "notifications" ? 
                               Qt.rgba(pywal.color4.r, pywal.color4.g, pywal.color4.b, 0.15) : 
                               "transparent"
                        
                        Behavior on color {
                            ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                        }
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 2
                            
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "󰂚"
                                font.family: "Material Design Icons"
                                font.pixelSize: 20
                                color: root.activeSection === "notifications" ? pywal.color4 : pywal.foreground
                                
                                Behavior on color {
                                    ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                                }
                            }
                            
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Notifications"
                                font.family: "Inter"
                                font.pixelSize: 10
                                font.weight: Font.Medium
                                color: root.activeSection === "notifications" ? pywal.color4 : Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.7)
                                
                                Behavior on color {
                                    ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                                }
                            }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.activeSection = "notifications"
                        }
                    }
                }
            }
            
            // Content area - sections will be loaded here with slide transitions
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                
                // Settings section
                Loader {
                    anchors.fill: parent
                    active: root.activeSection === "settings"
                    visible: opacity > 0
                    source: "sections/SettingsSection.qml"
                    
                    // Slide from left animation
                    x: {
                        if (root.activeSection === "settings") return 0
                        if (root.activeSection === "performance") return -width
                        if (root.activeSection === "media") return -width
                        return 0
                    }
                    
                    opacity: root.activeSection === "settings" ? 1 : 0
                    
                    Behavior on x {
                        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                    }
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                    }
                }
                
                // Performance section
                Loader {
                    anchors.fill: parent
                    active: root.activeSection === "performance"
                    visible: opacity > 0
                    source: "sections/PerformanceSection.qml"
                    
                    // Slide animation
                    x: {
                        if (root.activeSection === "performance") return 0
                        if (root.activeSection === "settings") return width
                        if (root.activeSection === "media") return -width
                        return width
                    }
                    
                    opacity: root.activeSection === "performance" ? 1 : 0
                    
                    Behavior on x {
                        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                    }
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                    }
                }
                
                // Media section
                Loader {
                    anchors.fill: parent
                    active: root.activeSection === "media"
                    visible: opacity > 0
                    source: "sections/MediaSection.qml"
                    
                    // Slide from right animation
                    x: {
                        if (root.activeSection === "media") return 0
                        if (root.activeSection === "settings") return width
                        if (root.activeSection === "performance") return width
                        if (root.activeSection === "notifications") return -width
                        return width
                    }
                    
                    opacity: root.activeSection === "media" ? 1 : 0
                    
                    Behavior on x {
                        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                    }
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                    }
                }
                
                // Notifications section
                Loader {
                    anchors.fill: parent
                    active: root.activeSection === "notifications"
                    visible: opacity > 0
                    source: "sections/NotificationsSection.qml"
                    
                    // Slide from right animation
                    x: {
                        if (root.activeSection === "notifications") return 0
                        return width
                    }
                    
                    opacity: root.activeSection === "notifications" ? 1 : 0
                    
                    Behavior on x {
                        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                    }
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                    }
                }
            }
        }
    }
}
