import QtQuick 6.10
import QtQuick.Layouts 6.10
import QtQuick.Effects
import Quickshell.Bluetooth
import Quickshell.Io
import "../../../services" as QsServices

// Inline Bluetooth Panel - hosted inside bar window
FocusScope {
    id: popupPanel
    
    property bool shouldShow: false
    signal closeRequested()
    
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var pywal: QsServices.Pywal
    readonly property var devices: [...Bluetooth.devices.values].sort((a, b) => {
        if (a.connected !== b.connected) return b.connected - a.connected
        if (a.bonded !== b.bonded) return b.bonded - a.bonded
        return a.name.localeCompare(b.name)
    })
    
    // Solid colors like Control Center
    readonly property color cSurface: pywal.background
    readonly property color cSurfaceContainer: Qt.lighter(pywal.background, 1.15)
    readonly property color cPrimary: pywal.primary
    readonly property color cText: pywal.foreground
    readonly property color cSubText: Qt.rgba(cText.r, cText.g, cText.b, 0.6)
    readonly property color cBorder: Qt.rgba(cText.r, cText.g, cText.b, 0.08)
    readonly property color cHover: Qt.rgba(cText.r, cText.g, cText.b, 0.06)
    
    // Settings launcher
    Process {
        id: settingsProcess
        command: ["blueman-manager"]
        onStarted: popupPanel.closeRequested()
    }
    
    implicitWidth: 320
    implicitHeight: contentColumn.implicitHeight + 32
    focus: true
    
    Keys.onEscapePressed: closeRequested()
        
        // Background with shadow
        Rectangle {
            id: backgroundRect
            anchors.fill: parent
            color: cSurface
            radius: 16
            border.color: cBorder
            border.width: 1
            
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: Qt.rgba(0, 0, 0, 0.35)
                shadowBlur: 1.0
                shadowVerticalOffset: 6
            }
            
            ColumnLayout {
                id: contentColumn
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12
                
                // Header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    
                    Rectangle {
                        width: 36
                        height: 36
                        radius: 12
                        color: Qt.rgba(cPrimary.r, cPrimary.g, cPrimary.b, 0.15)
                        
                        Text {
                            anchors.centerIn: parent
                            text: "󰂯"
                            font.family: "Material Design Icons"
                            font.pixelSize: 18
                            color: cPrimary
                        }
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        
                        Text {
                            text: "Bluetooth"
                            font.family: "Inter"
                            font.pixelSize: 15
                            font.weight: Font.Bold
                            color: cText
                        }
                        
                        Text {
                            property var connected: devices.filter(d => d.connected)
                            text: connected.length > 0 ? connected[0].name : "No device connected"
                            font.family: "Inter"
                            font.pixelSize: 11
                            color: cSubText
                        }
                    }
                    
                    // Toggle
                    Rectangle {
                        width: 44
                        height: 24
                        radius: 12
                        color: adapter?.enabled ? cPrimary : Qt.rgba(cText.r, cText.g, cText.b, 0.15)
                        
                        Behavior on color { ColorAnimation { duration: 150 } }
                        
                        Rectangle {
                            width: 18
                            height: 18
                            radius: 9
                            anchors.verticalCenter: parent.verticalCenter
                            x: adapter?.enabled ? parent.width - width - 3 : 3
                            color: "#ffffff"
                            
                            Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: if (adapter) adapter.enabled = !adapter.enabled
                        }
                    }
                }
                
                // Scan button
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    radius: 10
                    color: scanArea.containsMouse ? cHover : cSurfaceContainer
                    
                    Behavior on color { ColorAnimation { duration: 100 } }
                    
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
                            font.pixelSize: 12
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
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(deviceList.contentHeight + 8, 260)
                    radius: 12
                    color: cSurfaceContainer
                    clip: true
                    
                    ListView {
                        id: deviceList
                        anchors.fill: parent
                        anchors.margins: 4
                        spacing: 2
                        model: devices
                        clip: true
                        
                        delegate: Rectangle {
                            id: deviceItem
                            width: deviceList.width
                            height: 52
                            radius: 10
                            color: itemArea.containsMouse ? cHover : "transparent"
                            
                            required property var modelData
                            property bool isConnected: modelData.connected
                            
                            Behavior on color { ColorAnimation { duration: 80 } }
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 10
                                
                                // Icon
                                Text {
                                    text: {
                                        const icon = deviceItem.modelData.icon || ""
                                        if (icon.includes("audio")) return "󰋋"
                                        if (icon.includes("phone")) return "󰄜"
                                        if (icon.includes("computer")) return "󰌢"
                                        if (icon.includes("mouse")) return "󰍽"
                                        if (icon.includes("keyboard")) return "󰌌"
                                        return "󰂯"
                                    }
                                    font.family: "Material Design Icons"
                                    font.pixelSize: 18
                                    color: isConnected ? cPrimary : cText
                                }
                                
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    
                                    Text {
                                        text: deviceItem.modelData.name
                                        font.family: "Inter"
                                        font.pixelSize: 12
                                        font.weight: Font.Medium
                                        color: cText
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                    
                                    Text {
                                        text: {
                                            if (deviceItem.modelData.state === BluetoothDeviceState.Connecting) return "Connecting..."
                                            if (isConnected) return "Connected"
                                            if (deviceItem.modelData.bonded) return "Paired"
                                            return "Available"
                                        }
                                        font.family: "Inter"
                                        font.pixelSize: 10
                                        color: isConnected ? cPrimary : cSubText
                                    }
                                }
                                
                                // Action
                                Rectangle {
                                    width: 28
                                    height: 28
                                    radius: 14
                                    color: actionArea.containsMouse ? Qt.rgba(cPrimary.r, cPrimary.g, cPrimary.b, 0.15) : "transparent"
                                    border.width: 1
                                    border.color: isConnected ? cPrimary : Qt.rgba(cText.r, cText.g, cText.b, 0.15)
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: isConnected ? "󰌊" : "󰌘"
                                        font.family: "Material Design Icons"
                                        font.pixelSize: 14
                                        color: isConnected ? cPrimary : cSubText
                                    }
                                    
                                    MouseArea {
                                        id: actionArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (isConnected) {
                                                deviceItem.modelData.connected = false
                                            } else {
                                                deviceItem.modelData.connected = true
                                            }
                                        }
                                    }
                                }
                            }
                            
                            MouseArea {
                                id: itemArea
                                anchors.fill: parent
                                hoverEnabled: true
                                z: -1
                            }
                        }
                    }
                    
                    // Empty state
                    ColumnLayout {
                        anchors.centerIn: parent
                        visible: devices.length === 0
                        spacing: 6
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "󰂲"
                            font.family: "Material Design Icons"
                            font.pixelSize: 32
                            color: Qt.rgba(cText.r, cText.g, cText.b, 0.2)
                        }
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: adapter?.enabled ? "No devices found" : "Bluetooth disabled"
                            font.family: "Inter"
                            font.pixelSize: 12
                            color: cSubText
                        }
                    }
                }
                
                // Settings button
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    radius: 10
                    color: settingsArea.containsMouse ? cHover : "transparent"
                    
                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        
                        Text {
                            text: "󰒓"
                            font.family: "Material Design Icons"
                            font.pixelSize: 14
                            color: cSubText
                        }
                        
                        Text {
                            text: "Bluetooth Settings"
                            font.family: "Inter"
                            font.pixelSize: 12
                            color: cSubText
                        }
                    }
                    
                    MouseArea {
                        id: settingsArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: settingsProcess.running = true
                    }
                }
            }
        }
}