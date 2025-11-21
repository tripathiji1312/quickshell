import QtQuick 6.10
import QtQuick.Layouts 6.10
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Bluetooth
import "../../../services" as QsServices

// Premium Native-Feel Bluetooth Popup
PanelWindow {
    id: popupWindow
    
    property bool shouldShow: false
    property bool isHovered: false
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var pywal: QsServices.Pywal
    readonly property var devices: [...Bluetooth.devices.values].sort((a, b) => {
        // Sort: connected first, then paired, then by name
        if (a.connected !== b.connected) return b.connected - a.connected
        if (a.bonded !== b.bonded) return b.bonded - a.bonded
        return a.name.localeCompare(b.name)
    })
    
    // Design Tokens
    readonly property color cSurface: Qt.rgba(pywal.background.r, pywal.background.g, pywal.background.b, 0.95)
    readonly property color cPrimary: pywal.color6 ?? "#cba6f7"
    readonly property color cText: pywal.foreground
    readonly property color cSubText: Qt.rgba(cText.r, cText.g, cText.b, 0.6)
    readonly property color cBorder: Qt.rgba(cPrimary.r, cPrimary.g, cPrimary.b, 0.15)
    readonly property color cHover: Qt.rgba(cText.r, cText.g, cText.b, 0.05)
    
    screen: Quickshell.screens[0]
    
    anchors {
        top: true
        right: true
    }
    
    margins {
        right: 8
        top: 0
    }
    
    implicitWidth: 320
    implicitHeight: contentColumn.implicitHeight + 32
    color: "transparent"
    visible: shouldShow || container.opacity > 0
    
    WlrLayershell.keyboardFocus: shouldShow ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    
    // Main Container
    FocusScope {
        id: container
        anchors.fill: parent
        scale: 0.9
        opacity: 0
        transformOrigin: Item.TopRight
        focus: true
        
        Keys.onEscapePressed: popupWindow.shouldShow = false
        
        onActiveFocusChanged: {
            if (!activeFocus && popupWindow.shouldShow) {
                // Close on focus loss (click outside)
                popupWindow.shouldShow = false
            }
        }
        
        // Entrance/Exit Animations
        states: State {
            name: "visible"
            when: popupWindow.shouldShow
            PropertyChanges { target: container; opacity: 1; scale: 1.0 }
        }
        
        transitions: Transition {
            from: "*"
            to: "visible"
            ParallelAnimation {
                NumberAnimation { property: "opacity"; duration: 200; easing.type: Easing.OutQuad }
                SpringAnimation { property: "scale"; spring: 3; damping: 0.25; epsilon: 0.005; mass: 0.8 }
            }
        }
        
        // Exit transition
        Transition {
            from: "visible"
            to: "*"
            ParallelAnimation {
                NumberAnimation { property: "opacity"; duration: 150; easing.type: Easing.InQuad }
                NumberAnimation { property: "scale"; to: 0.95; duration: 150; easing.type: Easing.InQuad }
            }
        }

        // Shadow
        Rectangle {
            anchors.fill: backgroundRect
            anchors.margins: -1
            radius: backgroundRect.radius
            color: "transparent"
            z: -1
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: Qt.rgba(0, 0, 0, 0.4)
                shadowBlur: 1.5
                shadowVerticalOffset: 4
                shadowHorizontalOffset: 0
            }
        }
        
        // Background
        Rectangle {
            id: backgroundRect
            anchors.fill: parent
            color: cSurface
            radius: 16
            border.color: cBorder
            border.width: 1
            clip: true
            
            ColumnLayout {
                id: contentColumn
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16
                
                // Header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    
                    Rectangle {
                        width: 32
                        height: 32
                        radius: 10
                        color: Qt.rgba(cPrimary.r, cPrimary.g, cPrimary.b, 0.1)
                        
                        Text {
                            anchors.centerIn: parent
                            text: "󰂯"
                            font.family: "Material Design Icons"
                            font.pixelSize: 18
                            color: cPrimary
                        }
                    }
                    
                    Text {
                        text: "Bluetooth"
                        font.family: "Inter"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: cText
                        Layout.fillWidth: true
                    }
                    
                    // Toggle Switch
                    Rectangle {
                        Layout.preferredWidth: 44
                        Layout.preferredHeight: 24
                        radius: 12
                        color: adapter?.enabled ? cPrimary : Qt.rgba(cText.r, cText.g, cText.b, 0.1)
                        
                        Behavior on color { ColorAnimation { duration: 200 } }
                        
                        Rectangle {
                            width: 20
                            height: 20
                            radius: 10
                            anchors.verticalCenter: parent.verticalCenter
                            x: adapter?.enabled ? parent.width - width - 2 : 2
                            color: "white"
                            
                            Behavior on x { SpringAnimation { spring: 4; damping: 0.4 } }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: if (adapter) adapter.enabled = !adapter.enabled
                        }
                    }
                }
                
                // Scan Button
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    radius: 10
                    color: scanArea.containsMouse ? Qt.rgba(cPrimary.r, cPrimary.g, cPrimary.b, 0.1) : Qt.rgba(cText.r, cText.g, cText.b, 0.03)
                    
                    Behavior on color { ColorAnimation { duration: 150 } }
                    
                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        
                        Text {
                            text: adapter?.discovering ? "󰑐" : "󰑓"
                            font.family: "Material Design Icons"
                            font.pixelSize: 16
                            color: adapter?.discovering ? cPrimary : cText
                            
                            RotationAnimation on rotation {
                                running: adapter?.discovering ?? false
                                from: 0; to: 360; duration: 1000; loops: Animation.Infinite
                            }
                        }
                        
                        Text {
                            text: adapter?.discovering ? "Scanning..." : "Scan for devices"
                            font.family: "Inter"
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: cText
                        }
                    }
                    
                    MouseArea {
                        id: scanArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (adapter) adapter.discovering = !adapter.discovering
                    }
                }
                
                // Device List
                ListView {
                    id: deviceList
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(contentHeight, 320)
                    spacing: 4
                    clip: true
                    model: devices
                    
                    delegate: Rectangle {
                        id: deviceItem
                        width: deviceList.width
                        height: 56
                        radius: 12
                        color: itemArea.containsMouse ? cHover : "transparent"
                        
                        Behavior on color { ColorAnimation { duration: 100 } }
                        
                        required property var modelData
                        property bool isConnected: modelData.connected
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 12
                            
                            // Icon
                            Text {
                                text: {
                                    const icon = modelData.icon || "generic"
                                    if (icon.includes("audio")) return "󰋋"
                                    if (icon.includes("phone")) return "󰄜"
                                    if (icon.includes("computer")) return "󰌢"
                                    if (icon.includes("mouse")) return "󰍽"
                                    if (icon.includes("keyboard")) return "󰌌"
                                    return "󰂯"
                                }
                                font.family: "Material Design Icons"
                                font.pixelSize: 20
                                color: isConnected ? cPrimary : cSubText
                            }
                            
                            // Info
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                
                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.name
                                    font.family: "Inter"
                                    font.pixelSize: 13
                                    font.weight: Font.Medium
                                    color: cText
                                    elide: Text.ElideRight
                                }
                                
                                Text {
                                    text: {
                                        if (modelData.state === BluetoothDeviceState.Connecting) return "Connecting..."
                                        if (isConnected) return "Connected"
                                        if (modelData.bonded) return "Paired"
                                        return "Available"
                                    }
                                    font.family: "Inter"
                                    font.pixelSize: 11
                                    color: isConnected ? cPrimary : cSubText
                                }
                            }
                            
                            // Action Button
                            Rectangle {
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                radius: 16
                                color: actionArea.containsMouse ? Qt.rgba(cText.r, cText.g, cText.b, 0.1) : "transparent"
                                border.color: isConnected ? cPrimary : Qt.rgba(cText.r, cText.g, cText.b, 0.2)
                                border.width: 1
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: isConnected ? "󰌊" : "󰌘"
                                    font.family: "Material Design Icons"
                                    font.pixelSize: 16
                                    color: isConnected ? cPrimary : cSubText
                                }
                                
                                MouseArea {
                                    id: actionArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: modelData.connected = !modelData.connected
                                }
                            }
                        }
                        
                        MouseArea {
                            id: itemArea
                            anchors.fill: parent
                            hoverEnabled: true
                            z: -1 // Let action button take priority
                        }
                    }
                }
                
                // Empty State
                Item {
                    visible: devices.length === 0
                    Layout.fillWidth: true
                    Layout.preferredHeight: 120
                    
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "󰂲"
                            font.family: "Material Design Icons"
                            font.pixelSize: 36
                            color: Qt.rgba(cText.r, cText.g, cText.b, 0.2)
                        }
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: adapter?.enabled ? "No devices found" : "Bluetooth is disabled"
                            font.family: "Inter"
                            font.pixelSize: 13
                            color: cSubText
                        }
                    }
                }
                
                // Footer / Settings Link
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: cBorder
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    radius: 8
                    color: settingsArea.containsMouse ? cHover : "transparent"
                    
                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        
                        Text {
                            text: "Bluetooth Settings"
                            font.family: "Inter"
                            font.pixelSize: 12
                            color: cSubText
                        }
                        
                        Text {
                            text: "󰅂"
                            font.family: "Material Design Icons"
                            font.pixelSize: 14
                            color: cSubText
                        }
                    }
                    
                    MouseArea {
                        id: settingsArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            // Launch system bluetooth settings
                            // Adjust command based on user's DE/tools (e.g., blueman-manager, gnome-control-center)
                            Quickshell.process.exec("blueman-manager") 
                        }
                    }
                }
            }
        }
    }
}
