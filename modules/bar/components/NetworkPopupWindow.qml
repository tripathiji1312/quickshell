import QtQuick 6.10
import QtQuick.Layouts 6.10
import QtQuick.Controls 6.10 as QQC
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import "../../../services" as QsServices

// Premium Native-Feel Network Popup
PanelWindow {
    id: popupWindow
    
    property bool shouldShow: false
    property bool isHovered: false
    readonly property var pywal: QsServices.Pywal
    readonly property var network: QsServices.Network
    readonly property var sortedNetworks: [...network.networks].sort((a, b) => {
        if (a.active !== b.active) return b.active - a.active
        return b.strength - a.strength
    })
    
    // Design Tokens
    readonly property color cSurface: Qt.rgba(pywal.background.r, pywal.background.g, pywal.background.b, 0.95)
    readonly property color cPrimary: pywal.color5 ?? "#89b4fa"
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
    visible: shouldShow || passwordDialog.isOpen || container.opacity > 0
    
    WlrLayershell.keyboardFocus: shouldShow ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    
    // Main Container
    FocusScope {
        id: container
        anchors.fill: parent
        scale: 0.9
        opacity: 0
        transformOrigin: Item.TopRight
        focus: true
        
        Keys.onEscapePressed: {
            if (!passwordDialog.isOpen) {
                popupWindow.shouldShow = false
            }
        }
        
        onActiveFocusChanged: {
            if (!activeFocus && popupWindow.shouldShow && !passwordDialog.isOpen) {
                // Close on focus loss (click outside)
                popupWindow.shouldShow = false
            }
        }
        
        // Entrance/Exit Animations
        states: State {
            name: "visible"
            when: popupWindow.shouldShow || passwordDialog.isOpen
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
                            text: "󰖩"
                            font.family: "Material Design Icons"
                            font.pixelSize: 18
                            color: cPrimary
                        }
                    }
                    
                    Text {
                        text: "WiFi Networks"
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
                        color: network.wifiEnabled ? cPrimary : Qt.rgba(cText.r, cText.g, cText.b, 0.1)
                        
                        Behavior on color { ColorAnimation { duration: 200 } }
                        
                        Rectangle {
                            width: 20
                            height: 20
                            radius: 10
                            anchors.verticalCenter: parent.verticalCenter
                            x: network.wifiEnabled ? parent.width - width - 2 : 2
                            color: "white"
                            
                            Behavior on x { SpringAnimation { spring: 4; damping: 0.4 } }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: network.toggleWifi()
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
                            text: network.scanning ? "󰑐" : "󰑓"
                            font.family: "Material Design Icons"
                            font.pixelSize: 16
                            color: network.scanning ? cPrimary : cText
                            
                            RotationAnimation on rotation {
                                running: network.scanning
                                from: 0; to: 360; duration: 1000; loops: Animation.Infinite
                            }
                        }
                        
                        Text {
                            text: network.scanning ? "Scanning..." : "Scan networks"
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
                        enabled: network.wifiEnabled
                        onClicked: network.rescanWifi()
                    }
                }
                
                // Network List
                ListView {
                    id: networkList
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(contentHeight, 320)
                    spacing: 4
                    clip: true
                    model: sortedNetworks
                    
                    delegate: Rectangle {
                        id: networkItem
                        width: networkList.width
                        height: 56
                        radius: 12
                        color: itemArea.containsMouse ? cHover : "transparent"
                        
                        Behavior on color { ColorAnimation { duration: 100 } }
                        
                        required property var modelData
                        property bool isActive: modelData.active
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 12
                            
                            // Signal Icon
                            Text {
                                text: {
                                    const strength = networkItem.modelData.strength
                                    if (strength >= 75) return "󰤨"
                                    if (strength >= 50) return "󰤥"
                                    if (strength >= 25) return "󰤢"
                                    return "󰤟"
                                }
                                font.family: "Material Design Icons"
                                font.pixelSize: 20
                                color: isActive ? cPrimary : (networkItem.modelData.strength >= 50 ? cText : cSubText)
                            }
                            
                            // Info
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 6
                                    
                                    Text {
                                        Layout.fillWidth: true
                                        text: networkItem.modelData.ssid
                                        font.family: "Inter"
                                        font.pixelSize: 13
                                        font.weight: Font.Medium
                                        color: cText
                                        elide: Text.ElideRight
                                    }
                                    
                                    Text {
                                        visible: networkItem.modelData.isSecure
                                        text: "󰌾"
                                        font.family: "Material Design Icons"
                                        font.pixelSize: 12
                                        color: cSubText
                                    }
                                }
                                
                                Text {
                                    text: isActive ? "Connected" : `${networkItem.modelData.frequency} MHz • ${networkItem.modelData.strength}%`
                                    font.family: "Inter"
                                    font.pixelSize: 11
                                    color: isActive ? cPrimary : cSubText
                                }
                            }
                            
                            // Action Button
                            Rectangle {
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                radius: 16
                                color: actionArea.containsMouse ? Qt.rgba(cText.r, cText.g, cText.b, 0.1) : "transparent"
                                border.color: isActive ? cPrimary : Qt.rgba(cText.r, cText.g, cText.b, 0.2)
                                border.width: 1
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: isActive ? "󰌊" : "󰌘"
                                    font.family: "Material Design Icons"
                                    font.pixelSize: 16
                                    color: isActive ? cPrimary : cSubText
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
                
                // Empty State
                Item {
                    visible: sortedNetworks.length === 0
                    Layout.fillWidth: true
                    Layout.preferredHeight: 120
                    
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "󰖪"
                            font.family: "Material Design Icons"
                            font.pixelSize: 36
                            color: Qt.rgba(cText.r, cText.g, cText.b, 0.2)
                        }
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: network.wifiEnabled ? "No networks found" : "WiFi is disabled"
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
                            text: "Network Settings"
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
                        onClicked: Quickshell.process.exec("nm-connection-editor")
                    }
                }
            }
        }
    }
    
    // Password Dialog Overlay
    Item {
        id: passwordDialog
        anchors.fill: parent
        visible: opacity > 0
        z: 100
        
        property string networkSSID: ""
        property bool isOpen: false
        
        opacity: 0
        
        function open() {
            isOpen = true
            passwordInput.forceActiveFocus()
        }
        
        function close() {
            isOpen = false
            passwordInput.text = ""
        }
        
        states: State {
            name: "open"
            when: passwordDialog.isOpen
            PropertyChanges { target: passwordDialog; opacity: 1 }
            PropertyChanges { target: dialogCard; scale: 1.0 }
        }
        
        transitions: Transition {
            from: "*"
            to: "open"
            ParallelAnimation {
                NumberAnimation { target: passwordDialog; property: "opacity"; duration: 200 }
                SpringAnimation { target: dialogCard; property: "scale"; spring: 3; damping: 0.25; mass: 0.8 }
            }
        }
        
        Transition {
            from: "open"
            to: "*"
            ParallelAnimation {
                NumberAnimation { target: passwordDialog; property: "opacity"; duration: 150 }
                NumberAnimation { target: dialogCard; property: "scale"; to: 0.9; duration: 150 }
            }
        }
        
        // Backdrop
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.6)
            radius: 16
            
            MouseArea {
                anchors.fill: parent
                onClicked: passwordDialog.close()
            }
        }
        
        // Dialog Card
        Rectangle {
            id: dialogCard
            anchors.centerIn: parent
            width: 320
            height: passwordColumn.implicitHeight + 40
            radius: 16
            color: cSurface
            scale: 0.9
            border.color: cBorder
            border.width: 1
            
            ColumnLayout {
                id: passwordColumn
                anchors.fill: parent
                anchors.margins: 24
                spacing: 16
                
                // Header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    
                    Rectangle {
                        width: 40
                        height: 40
                        radius: 20
                        color: Qt.rgba(cPrimary.r, cPrimary.g, cPrimary.b, 0.1)
                        
                        Text {
                            anchors.centerIn: parent
                            text: "󰖩"
                            font.family: "Material Design Icons"
                            font.pixelSize: 20
                            color: cPrimary
                        }
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        
                        Text {
                            text: "Enter Password"
                            font.family: "Inter"
                            font.pixelSize: 15
                            font.weight: Font.Bold
                            color: cText
                        }
                        
                        Text {
                            Layout.fillWidth: true
                            text: passwordDialog.networkSSID
                            font.family: "Inter"
                            font.pixelSize: 12
                            color: cSubText
                            elide: Text.ElideRight
                        }
                    }
                }
                
                // Input
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    radius: 10
                    color: Qt.rgba(cText.r, cText.g, cText.b, 0.05)
                    border.color: passwordInput.activeFocus ? cPrimary : "transparent"
                    border.width: 1
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 8
                        spacing: 8
                        
                        Text {
                            text: "󰌾"
                            font.family: "Material Design Icons"
                            font.pixelSize: 16
                            color: cSubText
                        }
                        
                        QQC.TextField {
                            id: passwordInput
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            placeholderText: "Password"
                            echoMode: showPasswordToggle.checked ? QQC.TextField.Normal : QQC.TextField.Password
                            color: cText
                            background: Item {}
                            font.family: "Inter"
                            font.pixelSize: 14
                            
                            onAccepted: {
                                if (text.length > 0) {
                                    network.connectToNetwork(passwordDialog.networkSSID, text)
                                    passwordDialog.close()
                                }
                            }
                        }
                        
                        // Show/Hide Toggle
                        Rectangle {
                            width: 28
                            height: 28
                            radius: 14
                            color: toggleArea.containsMouse ? Qt.rgba(cText.r, cText.g, cText.b, 0.1) : "transparent"
                            
                            Text {
                                id: showPasswordToggle
                                anchors.centerIn: parent
                                text: parent.checked ? "󰛐" : "󰛑"
                                font.family: "Material Design Icons"
                                font.pixelSize: 16
                                color: cSubText
                                property bool checked: false
                            }
                            
                            MouseArea {
                                id: toggleArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    showPasswordToggle.checked = !showPasswordToggle.checked
                                }
                            }
                        }
                    }
                }
                
                // Buttons
                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 8
                    spacing: 12
                    
                    Item { Layout.fillWidth: true }
                    
                    // Cancel
                    Rectangle {
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 36
                        radius: 18
                        color: cancelArea.containsMouse ? Qt.rgba(cText.r, cText.g, cText.b, 0.1) : "transparent"
                        border.color: Qt.rgba(cText.r, cText.g, cText.b, 0.2)
                        border.width: 1
                        
                        Text {
                            anchors.centerIn: parent
                            text: "Cancel"
                            font.family: "Inter"
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: cText
                        }
                        
                        MouseArea {
                            id: cancelArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: passwordDialog.close()
                        }
                    }
                    
                    // Connect
                    Rectangle {
                        Layout.preferredWidth: 90
                        Layout.preferredHeight: 36
                        radius: 18
                        color: passwordInput.text.length > 0 ? cPrimary : Qt.rgba(cPrimary.r, cPrimary.g, cPrimary.b, 0.3)
                        
                        Text {
                            anchors.centerIn: parent
                            text: "Connect"
                            font.family: "Inter"
                            font.pixelSize: 13
                            font.weight: Font.Bold
                            color: passwordInput.text.length > 0 ? cSurface : Qt.rgba(cSurface.r, cSurface.g, cSurface.b, 0.5)
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
