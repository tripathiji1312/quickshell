import QtQuick 6.10
import QtQuick.Layouts 6.10
import QtQuick.Controls 6.10 as QQC
import Quickshell.Io
import "../../../services" as QsServices

FocusScope {
    id: popupPanel

    property bool shouldShow: false
    signal closeRequested()
    readonly property var pywal: QsServices.Pywal
    readonly property var network: QsServices.Network
    readonly property var sortedNetworks: [...network.networks].sort((a, b) => {
        if (a.active !== b.active) return b.active - a.active
        return b.strength - a.strength
    })

    readonly property color cSurface: pywal.surface
    readonly property color cSurfaceContainer: pywal.surfaceContainer
    readonly property color cSurfaceContainerHigh: pywal.surfaceContainerHigh
    readonly property color cPrimary: pywal.primary
    readonly property color cOnSurface: pywal.foreground
    readonly property color cOnSurfaceVariant: pywal.onSurfaceMuted

    Process {
        id: settingsProcess
        command: ["nm-connection-editor"]
        onStarted: popupPanel.closeRequested()
    }

    implicitWidth: 340
    implicitHeight: contentColumn.implicitHeight + 32
    focus: true

    Keys.onEscapePressed: {
        if (!passwordDialog.isOpen) closeRequested()
    }

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
                        text: "󰖩"
                        font.family: "Material Design Icons"
                        font.pixelSize: 18
                        color: cPrimary
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: "WiFi Networks"
                        font.family: "Inter"
                        font.pixelSize: 15
                        font.weight: Font.Bold
                        color: cOnSurface
                    }

                    Text {
                        text: network.active ? network.active.ssid : "Not connected"
                        font.family: "Inter"
                        font.pixelSize: 11
                        color: cOnSurfaceVariant
                    }
                }

                // M3 Toggle
                Rectangle {
                    width: 44; height: 24; radius: 12
                    color: network.wifiEnabled ? cPrimary : Qt.rgba(cOnSurface.r, cOnSurface.g, cOnSurface.b, 0.15)
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Rectangle {
                        width: 18; height: 18; radius: 9
                        anchors.verticalCenter: parent.verticalCenter
                        x: network.wifiEnabled ? parent.width - width - 3 : 3
                        color: "#ffffff"
                        Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: network.toggleWifi()
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
                        text: network.scanning ? "󰑐" : "󰑓"
                        font.family: "Material Design Icons"
                        font.pixelSize: 16
                        color: network.scanning ? cPrimary : cOnSurface

                        RotationAnimation on rotation {
                            running: network.scanning
                            from: 0; to: 360; duration: 1000; loops: Animation.Infinite
                        }
                    }

                    Text {
                        text: network.scanning ? "Scanning..." : "Scan networks"
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
                    enabled: network.wifiEnabled
                    onClicked: network.rescanWifi()
                }
            }

            // Network List
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(networkList.contentHeight + 8, 280)
                radius: 16
                color: cSurfaceContainerHigh
                clip: true

                ListView {
                    id: networkList
                    anchors.fill: parent
                    anchors.margins: 4
                    spacing: 2
                    model: sortedNetworks
                    clip: true

                    delegate: Rectangle {
                        id: networkItem
                        width: networkList.width
                        height: 52
                        radius: 12
                        color: itemArea.pressed ? Qt.rgba(cOnSurface.r, cOnSurface.g, cOnSurface.b, 0.12) : itemArea.containsMouse ? Qt.rgba(cOnSurface.r, cOnSurface.g, cOnSurface.b, 0.08) : "transparent"
                        Behavior on color { ColorAnimation { duration: 150 } }

                        required property var modelData
                        property bool isActive: modelData.active

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 10

                            Text {
                                text: {
                                    const s = networkItem.modelData.strength
                                    if (s >= 75) return "󰤨"
                                    if (s >= 50) return "󰤥"
                                    if (s >= 25) return "󰤢"
                                    return "󰤟"
                                }
                                font.family: "Material Design Icons"
                                font.pixelSize: 18
                                color: isActive ? cPrimary : cOnSurface
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                RowLayout {
                                    spacing: 4
                                    Text {
                                        text: networkItem.modelData.ssid
                                        font.family: "Inter"
                                        font.pixelSize: 12
                                        font.weight: Font.Medium
                                        color: cOnSurface
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                    Text {
                                        visible: networkItem.modelData.isSecure
                                        text: "󰌾"
                                        font.family: "Material Design Icons"
                                        font.pixelSize: 10
                                        color: cOnSurfaceVariant
                                    }
                                }

                                Text {
                                    text: isActive ? "Connected" : `${networkItem.modelData.strength}%`
                                    font.family: "Inter"
                                    font.pixelSize: 10
                                    color: isActive ? cPrimary : cOnSurfaceVariant
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
                                    text: isActive ? "󰌊" : "󰌘"
                                    font.family: "Material Design Icons"
                                    font.pixelSize: 14
                                    color: isActive ? cPrimary : cOnSurfaceVariant
                                }

                                MouseArea {
                                    id: actionArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (isActive) {
                                            network.disconnectFromNetwork()
                                        } else {
                                            const isSaved = network.savedNetworks.includes(networkItem.modelData.ssid)
                                            if (isSaved) {
                                                network.connectToNetwork(networkItem.modelData.ssid, "")
                                            } else if (networkItem.modelData.isSecure) {
                                                passwordDialog.networkSSID = networkItem.modelData.ssid
                                                passwordDialog.open()
                                            } else {
                                                network.connectToNetwork(networkItem.modelData.ssid, "")
                                            }
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
                    visible: sortedNetworks.length === 0
                    spacing: 6

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "󰖪"
                        font.family: "Material Design Icons"
                        font.pixelSize: 32
                        color: Qt.rgba(cOnSurface.r, cOnSurface.g, cOnSurface.b, 0.2)
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: network.wifiEnabled ? "No networks found" : "WiFi disabled"
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
                        text: "Network Settings"
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

    // Password Dialog
    Item {
        id: passwordDialog
        anchors.fill: parent
        visible: opacity > 0
        z: 100

        property string networkSSID: ""
        property bool isOpen: false

        opacity: 0

        function open() { isOpen = true; passwordInput.forceActiveFocus() }
        function close() { isOpen = false; passwordInput.text = "" }

        states: State {
            name: "open"; when: passwordDialog.isOpen
            PropertyChanges { target: passwordDialog; opacity: 1 }
            PropertyChanges { target: dialogCard; scale: 1.0 }
        }

        transitions: [
            Transition { to: "open"
                ParallelAnimation {
                    NumberAnimation { target: passwordDialog; property: "opacity"; duration: 150 }
                    NumberAnimation { target: dialogCard; property: "scale"; duration: 200; easing.type: Easing.OutBack }
                }
            },
            Transition { from: "open"
                ParallelAnimation {
                    NumberAnimation { target: passwordDialog; property: "opacity"; duration: 100 }
                    NumberAnimation { target: dialogCard; property: "scale"; to: 0.9; duration: 100 }
                }
            }
        ]

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.5)
            radius: 24
            MouseArea { anchors.fill: parent; onClicked: passwordDialog.close() }
        }

        Rectangle {
            id: dialogCard
            anchors.centerIn: parent
            width: 300
            height: dialogColumn.implicitHeight + 40
            radius: 24
            color: cSurface
            scale: 0.9

            ColumnLayout {
                id: dialogColumn
                anchors.fill: parent
                anchors.margins: 20
                spacing: 14

                Text {
                    text: "Enter Password"
                    font.family: "Inter"
                    font.pixelSize: 14
                    font.weight: Font.Bold
                    color: cOnSurface
                }

                Text {
                    text: passwordDialog.networkSSID
                    font.family: "Inter"
                    font.pixelSize: 11
                    color: cOnSurfaceVariant
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    radius: 12
                    color: cSurfaceContainer
                    border.color: passwordInput.activeFocus ? cPrimary : "transparent"
                    border.width: 1

                    QQC.TextField {
                        id: passwordInput
                        anchors.fill: parent
                        anchors.margins: 10
                        placeholderText: "Password"
                        echoMode: QQC.TextField.Password
                        color: cOnSurface
                        background: Item {}
                        font.family: "Inter"
                        font.pixelSize: 13

                        onAccepted: {
                            if (text.length > 0) {
                                network.connectToNetwork(passwordDialog.networkSSID, text)
                                passwordDialog.close()
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        width: 70; height: 32; radius: 16
                        color: cancelBtn.pressed ? Qt.rgba(cOnSurface.r, cOnSurface.g, cOnSurface.b, 0.12) : cancelBtn.containsMouse ? Qt.rgba(cOnSurface.r, cOnSurface.g, cOnSurface.b, 0.08) : "transparent"
                        Behavior on color { ColorAnimation { duration: 150 } }
                        scale: cancelBtn.pressed ? 0.95 : 1.0
                        Behavior on scale { NumberAnimation { duration: 100; easing.bezierCurve: Material3Anim.springGentle } }

                        Text {
                            anchors.centerIn: parent
                            text: "Cancel"
                            font.family: "Inter"
                            font.pixelSize: 12
                            color: cOnSurface
                        }

                        MouseArea {
                            id: cancelBtn
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: passwordDialog.close()
                        }
                    }

                    Rectangle {
                        width: 80; height: 32; radius: 16
                        color: passwordInput.text.length > 0 ? cPrimary : Qt.rgba(cPrimary.r, cPrimary.g, cPrimary.b, 0.4)

                        Text {
                            anchors.centerIn: parent
                            text: "Connect"
                            font.family: "Inter"
                            font.pixelSize: 12
                            font.weight: Font.Medium
                            color: "#ffffff"
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: passwordInput.text.length > 0
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                network.connectToNetwork(passwordDialog.networkSSID, passwordInput.text)
                                passwordDialog.close()
                            }
                        }
                    }
                }
            }
        }
    }
}
