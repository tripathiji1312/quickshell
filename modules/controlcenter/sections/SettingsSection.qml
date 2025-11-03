import QtQuick 6.10
import QtQuick.Layouts 6.10
import QtQuick.Controls 6.10
import Quickshell
import Quickshell.Io
import "../../../services" as QsServices

Item {
    id: root
    
    readonly property var pywal: QsServices.Pywal
    readonly property var audio: QsServices.Audio
    readonly property var volumeMonitor: QsServices.VolumeMonitor
    readonly property var brightness: QsServices.Brightness
    readonly property var network: QsServices.Network
    readonly property var idleInhibitor: QsServices.IdleInhibitor
    
    // DND state (simple toggle for now)
    property bool dndEnabled: false
    
    ScrollView {
        anchors.fill: parent
        anchors.margins: 16
        clip: true
        
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        
        ColumnLayout {
            width: parent.parent.width - 32
            spacing: 16
            
            // Power buttons section
            GridLayout {
                Layout.fillWidth: true
                columns: 4
                rowSpacing: 8
                columnSpacing: 8
                
                // Lock button
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    radius: 12
                    color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.05)
                    
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "󰌾"
                            font.family: "Material Design Icons"
                            font.pixelSize: 28
                            color: pywal.color3
                        }
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Lock"
                            font.family: "Inter"
                            font.pixelSize: 11
                            color: pywal.foreground
                        }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            // Lock screen command
                            console.log("Lock screen")
                        }
                        
                        onPressed: parent.color = Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.1)
                        onReleased: parent.color = Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.05)
                    }
                }
                
                // Logout button
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    radius: 12
                    color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.05)
                    
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "󰗼"
                            font.family: "Material Design Icons"
                            font.pixelSize: 28
                            color: pywal.color2
                        }
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Logout"
                            font.family: "Inter"
                            font.pixelSize: 11
                            color: pywal.foreground
                        }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            console.log("Logout")
                        }
                        
                        onPressed: parent.color = Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.1)
                        onReleased: parent.color = Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.05)
                    }
                }
                
                // Sleep button
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    radius: 12
                    color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.05)
                    
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "󰒲"
                            font.family: "Material Design Icons"
                            font.pixelSize: 28
                            color: pywal.foreground
                        }
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Sleep"
                            font.family: "Inter"
                            font.pixelSize: 11
                            color: pywal.foreground
                        }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            console.log("Sleep")
                        }
                        
                        onPressed: parent.color = Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.1)
                        onReleased: parent.color = Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.05)
                    }
                }
                
                // Power off button
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    radius: 12
                    color: Qt.rgba(pywal.color1.r, pywal.color1.g, pywal.color1.b, 0.1)
                    
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "󰐥"
                            font.family: "Material Design Icons"
                            font.pixelSize: 28
                            color: pywal.color1
                        }
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Power"
                            font.family: "Inter"
                            font.pixelSize: 11
                            color: pywal.foreground
                        }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            console.log("Power off")
                        }
                        
                        onPressed: parent.color = Qt.rgba(pywal.color1.r, pywal.color1.g, pywal.color1.b, 0.15)
                        onReleased: parent.color = Qt.rgba(pywal.color1.r, pywal.color1.g, pywal.color1.b, 0.1)
                    }
                }
            }
            
            // Separator
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.1)
            }
            
            // Quick toggles
            Text {
                text: "Quick Settings"
                font.family: "Inter"
                font.pixelSize: 13
                font.weight: Font.DemiBold
                color: pywal.foreground
            }
            
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: 8
                columnSpacing: 8
                
                // DND Toggle
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    radius: 10
                    color: dndEnabled ? 
                           Qt.rgba(pywal.color1.r, pywal.color1.g, pywal.color1.b, 0.15) : 
                           Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.05)
                    
                    Behavior on color {
                        ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 10
                        
                        Text {
                            text: "󰂛"
                            font.family: "Material Design Icons"
                            font.pixelSize: 24
                            color: dndEnabled ? pywal.color1 : pywal.foreground
                            
                            Behavior on color {
                                ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                            }
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            
                            Text {
                                text: "Do Not Disturb"
                                font.family: "Inter"
                                font.pixelSize: 12
                                font.weight: Font.Medium
                                color: pywal.foreground
                            }
                            
                            Text {
                                text: dndEnabled ? "On" : "Off"
                                font.family: "Inter"
                                font.pixelSize: 10
                                color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.6)
                            }
                        }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: dndEnabled = !dndEnabled
                    }
                }
                
                // Idle Inhibitor Toggle
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    radius: 10
                    color: idleInhibitor.inhibited ? 
                           Qt.rgba(pywal.color2.r, pywal.color2.g, pywal.color2.b, 0.15) : 
                           Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.05)
                    
                    Behavior on color {
                        ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 10
                        
                        Text {
                            text: idleInhibitor.inhibited ? "󰅶" : "󰾪"
                            font.family: "Material Design Icons"
                            font.pixelSize: 24
                            color: idleInhibitor.inhibited ? pywal.color2 : pywal.foreground
                            
                            Behavior on color {
                                ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                            }
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            
                            Text {
                                text: "Keep Awake"
                                font.family: "Inter"
                                font.pixelSize: 12
                                font.weight: Font.Medium
                                color: pywal.foreground
                            }
                            
                            Text {
                                text: idleInhibitor.inhibited ? "On" : "Off"
                                font.family: "Inter"
                                font.pixelSize: 10
                                color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.6)
                            }
                        }
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: idleInhibitor.inhibited = !idleInhibitor.inhibited
                    }
                }
            }
            
            // Separator
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.1)
            }
            
            // Network Controls
            Text {
                text: "Network"
                font.family: "Inter"
                font.pixelSize: 13
                font.weight: Font.DemiBold
                color: pywal.foreground
            }
            
            // WiFi Control
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 70
                radius: 10
                color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.05)
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12
                    
                    Rectangle {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        radius: 20
                        color: network.connected ? Qt.rgba(pywal.color2.r, pywal.color2.g, pywal.color2.b, 0.2) : "transparent"
                        
                        Text {
                            anchors.centerIn: parent
                            text: network.connected ? "󰖩" : "󰖪"
                            font.family: "Material Design Icons"
                            font.pixelSize: 22
                            color: network.connected ? pywal.color2 : pywal.foreground
                        }
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        
                        Text {
                            text: network.connected ? network.ssid : "WiFi Disconnected"
                            font.family: "Inter"
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: pywal.foreground
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        
                        Text {
                            text: network.connected ? "Connected" : "Click to connect"
                            font.family: "Inter"
                            font.pixelSize: 10
                            color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.6)
                        }
                    }
                    
                    Text {
                        text: "󰅂"
                        font.family: "Material Design Icons"
                        font.pixelSize: 18
                        color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.5)
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        // TODO: Open WiFi selection dialog
                        console.log("Open WiFi settings")
                    }
                    
                    onPressed: parent.color = Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.1)
                    onReleased: parent.color = Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.05)
                }
            }
            
            // Bluetooth Control
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                radius: 10
                color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.05)
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12
                    
                    Rectangle {
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        radius: 18
                        color: network.bluetoothConnected ? Qt.rgba(pywal.color2.r, pywal.color2.g, pywal.color2.b, 0.2) : "transparent"
                        
                        Text {
                            anchors.centerIn: parent
                            text: network.bluetoothConnected ? "󰂯" : "󰂲"
                            font.family: "Material Design Icons"
                            font.pixelSize: 20
                            color: network.bluetoothConnected ? pywal.color2 : pywal.foreground
                        }
                    }
                    
                    // Device name and status to the right of icon
                    Text {
                        Layout.fillWidth: true
                        text: network.bluetoothConnected ? 
                              (network.bluetoothDeviceName || "Connected") :
                              "Bluetooth Disconnected"
                        font.family: "Inter"
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        color: pywal.foreground
                        elide: Text.ElideRight
                    }
                    
                    Text {
                        text: "󰅂"
                        font.family: "Material Design Icons"
                        font.pixelSize: 18
                        color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.5)
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        // TODO: Open Bluetooth selection dialog
                        console.log("Open Bluetooth settings")
                    }
                    
                    onPressed: parent.color = Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.1)
                    onReleased: parent.color = Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.05)
                }
            }
            
            // Volume Control
            Text {
                text: "Volume"
                font.family: "Inter"
                font.pixelSize: 13
                font.weight: Font.DemiBold
                color: pywal.foreground
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 12
                
                // Output volume
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    
                    Text {
                        text: volumeMonitor.muted ? "󰖁" : "󰕾"
                        font.family: "Material Design Icons"
                        font.pixelSize: 24
                        color: pywal.foreground
                    }
                    
                    Slider {
                        Layout.fillWidth: true
                        from: 0
                        to: 150
                        value: volumeMonitor.percentage
                        
                        onMoved: {
                            // Update using pamixer and write to file
                            audio.setVolume(value / 100)
                            // Also update the file immediately for OSD
                            volumeUpdateProc.running = true
                        }
                        
                        Process {
                            id: volumeUpdateProc
                            command: ["sh", "-c", `pamixer --set-volume ${parent.value.toFixed(0)} && echo ${parent.value.toFixed(0)} > /tmp/volume_osd`]
                        }
                        
                        background: Rectangle {
                            x: parent.leftPadding
                            y: parent.topPadding + parent.availableHeight / 2 - height / 2
                            width: parent.availableWidth
                            height: 6
                            radius: 3
                            color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.1)
                            
                            Rectangle {
                                width: parent.parent.visualPosition * parent.width
                                height: parent.height
                                color: pywal.color2
                                radius: 3
                            }
                        }
                        
                        handle: Rectangle {
                            x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
                            y: parent.topPadding + parent.availableHeight / 2 - height / 2
                            width: 18
                            height: 18
                            radius: 9
                            color: pywal.foreground
                            border.color: pywal.color2
                            border.width: 2
                        }
                    }
                    
                    Text {
                        text: volumeMonitor.percentage + "%"
                        font.family: "Inter"
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: pywal.foreground
                        Layout.preferredWidth: 45
                    }
                }
            }
            
            // Brightness Control
            Text {
                text: "Brightness"
                font.family: "Inter"
                font.pixelSize: 13
                font.weight: Font.DemiBold
                color: pywal.foreground
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                
                Text {
                    text: "󰃠"
                    font.family: "Material Design Icons"
                    font.pixelSize: 24
                    color: pywal.foreground
                }
                
                Slider {
                    Layout.fillWidth: true
                    from: 0
                    to: 100
                    value: brightness.percentage
                    
                    onMoved: brightness.setBrightness(value / 100)
                    
                    background: Rectangle {
                        x: parent.leftPadding
                        y: parent.topPadding + parent.availableHeight / 2 - height / 2
                        width: parent.availableWidth
                        height: 6
                        radius: 3
                        color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.1)
                        
                        Rectangle {
                            width: parent.parent.visualPosition * parent.width
                            height: parent.height
                            color: pywal.color3
                            radius: 3
                        }
                    }
                    
                    handle: Rectangle {
                        x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
                        y: parent.topPadding + parent.availableHeight / 2 - height / 2
                        width: 18
                        height: 18
                        radius: 9
                        color: pywal.foreground
                        border.color: pywal.color3
                        border.width: 2
                    }
                }
                
                Text {
                    text: brightness.percentage + "%"
                    font.family: "Inter"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: pywal.foreground
                    Layout.preferredWidth: 45
                }
            }
        }
    }
}
