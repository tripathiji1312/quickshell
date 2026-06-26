import QtQuick 6.10
import QtQuick.Layouts 6.10
import Quickshell.Bluetooth
import Quickshell.Io
import "../../../services" as QsServices

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

    readonly property color cSurface: pywal.surface
    readonly property color cSurfaceContainer: pywal.surfaceContainer
    readonly property color cSurfaceContainerHigh: pywal.surfaceContainerHigh
    readonly property color cPrimary: pywal.primary
    readonly property color cOnSurface: pywal.foreground
    readonly property color cOnSurfaceVariant: pywal.onSurfaceMuted

    Process {
        id: settingsProcess
        command: ["blueman-manager"]
        onStarted: popupPanel.closeRequested()
    }

    implicitWidth: 320
    implicitHeight: contentColumn.implicitHeight + 32
    focus: true

    Keys.onEscapePressed: closeRequested()

    Rectangle {
        anchors.fill: parent
        radius: 24
        color: cSurface

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
                        color: cOnSurface
                    }

                    Text {
                        property var connected: devices.filter(d => d.connected)
                        text: connected.length > 0 ? connected[0].name : "No device connected"
                        font.family: "Inter"
                        font.pixelSize: 11
                        color: cOnSurfaceVariant
                    }
                }

                // M3 Toggle
                Rectangle {
                    width: 44; height: 24; radius: 12
                    color: adapter?.enabled ? cPrimary : Qt.rgba(cOnSurface.r, cOnSurface.g, cOnSurface.b, 0.15)
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Rectangle {
                        width: 18; height: 18; radius: 9
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
                radius: 12
                color: scanArea.pressed ? Qt.rgba(cOnSurface.r, cOnSurface.g, cOnSurface.b, 0.12) : scanArea.containsMouse ? Qt.rgba(cOnSurface.r, cOnSurface.g, cOnSurface.b, 0.08) : cSurfaceContainer
                Behavior on color { ColorAnimation { duration: 150 } }
                scale: scanArea.pressed ? 0.97 : 1.0
                Behavior on scale { NumberAnimation { duration: 100; easing.bezierCurve: Material3Anim.springGentle } }

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        text: adapter?.discovering ? "󰑐" : "󰑓"
                        font.family: "Material Design Icons"
                        font.pixelSize: 16
                        color: adapter?.discovering ? cPrimary : cOnSurface

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
                        color: cOnSurface
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
                radius: 16
                color: cSurfaceContainerHigh
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
                        radius: 12
                        color: itemArea.pressed ? Qt.rgba(cOnSurface.r, cOnSurface.g, cOnSurface.b, 0.12) : itemArea.containsMouse ? Qt.rgba(cOnSurface.r, cOnSurface.g, cOnSurface.b, 0.08) : "transparent"
                        Behavior on color { ColorAnimation { duration: 150 } }

                        required property var modelData
                        property bool isConnected: modelData.connected

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 10

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
                                color: isConnected ? cPrimary : cOnSurface
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: deviceItem.modelData.name
                                    font.family: "Inter"
                                    font.pixelSize: 12
                                    font.weight: Font.Medium
                                    color: cOnSurface
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
                                    color: isConnected ? cPrimary : cOnSurfaceVariant
                                }
                            }

                            Rectangle {
                                width: 28; height: 28; radius: 14
                                color: actionArea.pressed ? Qt.rgba(cPrimary.r, cPrimary.g, cPrimary.b, 0.15) : "transparent"
                                Behavior on color { ColorAnimation { duration: 100 } }
                                scale: actionArea.pressed ? 0.9 : 1.0
                                Behavior on scale { NumberAnimation { duration: 100; easing.bezierCurve: Material3Anim.springGentle } }

                                Text {
                                    anchors.centerIn: parent
                                    text: isConnected ? "󰌊" : "󰌘"
                                    font.family: "Material Design Icons"
                                    font.pixelSize: 14
                                    color: isConnected ? cPrimary : cOnSurfaceVariant
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
                        color: Qt.rgba(cOnSurface.r, cOnSurface.g, cOnSurface.b, 0.2)
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: adapter?.enabled ? "No devices found" : "Bluetooth disabled"
                        font.family: "Inter"
                        font.pixelSize: 12
                        color: cOnSurfaceVariant
                    }
                }
            }

            // Settings button
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                radius: 12
                color: settingsArea.pressed ? Qt.rgba(cOnSurface.r, cOnSurface.g, cOnSurface.b, 0.12) : settingsArea.containsMouse ? Qt.rgba(cOnSurface.r, cOnSurface.g, cOnSurface.b, 0.08) : "transparent"
                Behavior on color { ColorAnimation { duration: 150 } }
                scale: settingsArea.pressed ? 0.97 : 1.0
                Behavior on scale { NumberAnimation { duration: 100; easing.bezierCurve: Material3Anim.springGentle } }

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        text: "󰒓"
                        font.family: "Material Design Icons"
                        font.pixelSize: 14
                        color: cOnSurfaceVariant
                    }

                    Text {
                        text: "Bluetooth Settings"
                        font.family: "Inter"
                        font.pixelSize: 12
                        color: cOnSurfaceVariant
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
