import QtQuick 6.10
import QtQuick.Layouts 6.10
import QtQuick.Controls 6.10
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import "../../services" as QsServices
import "../../config" as QsConfig
import "components"

PanelWindow {
    id: root
    
    // Services
    readonly property var logger: QsServices.Logger
    readonly property var config: QsConfig.Config
    readonly property var pywal: QsServices.Pywal
    readonly property var network: QsServices.Network
    readonly property var bluetooth: QsServices.Bluetooth
    readonly property var audio: QsServices.Audio
    readonly property var brightness: QsServices.Brightness
    readonly property var mpris: QsServices.Players
    readonly property var notifs: QsServices.Notifs
    readonly property var systemUsage: QsServices.SystemUsage
    readonly property var powerProfiles: QsServices.PowerProfiles

    readonly property var screenshot: QsServices.Screenshot
    readonly property var idleInhibitor: QsServices.IdleInhibitor
    
    // UI Tokens
    readonly property color cSurface: Qt.rgba(pywal.background.r, pywal.background.g, pywal.background.b, 0.95)
    readonly property color cBorder: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.15)
    readonly property color cPrimary: pywal.color4 ?? "#a6e3a1"
    
    // Material 3 colors (mapped)
    readonly property color m3Surface: cSurface
    readonly property color m3OnSurface: pywal.foreground
    readonly property color m3OnSurfaceVariant: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.7)
    
    screen: Quickshell.screens[0]
    
    anchors {
        top: true
        right: true
    }
    
    margins {
        right: 8
        top: 8
    }
    
    implicitWidth: 480
    implicitHeight: 900
    color: "transparent"
    visible: shouldShow || dashboardContainer.opacity > 0
    
    property bool shouldShow: false
    
    WlrLayershell.keyboardFocus: shouldShow ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    
    // Dashboard Panel
    FocusScope {
        id: dashboardContainer
        anchors.fill: parent
        
        transformOrigin: Item.TopRight
        scale: 0.85
        opacity: 0
        
        focus: true
        
        Keys.onEscapePressed: root.shouldShow = false
        
        onActiveFocusChanged: {
            if (!activeFocus && root.shouldShow) root.shouldShow = false
        }
        
        onVisibleChanged: {
            if (visible) forceActiveFocus()
        }
        
        MouseArea {
            anchors.fill: parent
            z: -1
            onClicked: root.shouldShow = false
        }
        
        // Animations
        SequentialAnimation {
            running: root.shouldShow
            ParallelAnimation {
                NumberAnimation { target: dashboardContainer; property: "scale"; from: 0.9; to: 1.0; duration: 300; easing.type: Easing.OutExpo }
                NumberAnimation { target: dashboardContainer; property: "opacity"; from: 0; to: 1; duration: 200 }
            }
        }
        
        ParallelAnimation {
            running: !root.shouldShow && dashboardContainer.opacity > 0
            NumberAnimation { target: dashboardContainer; property: "scale"; to: 0.9; duration: 200; easing.type: Easing.InCubic }
            NumberAnimation { target: dashboardContainer; property: "opacity"; to: 0; duration: 200 }
        }
        
        // Background
        Rectangle {
            id: dashboard
            anchors.fill: parent
            color: root.cSurface
            radius: 24
            border.color: root.cBorder
            border.width: 1
            clip: true
            
            MouseArea {
                anchors.fill: parent
                onClicked: (mouse) => { mouse.accepted = true }
            }
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20
                
                // Header
                RowLayout {
                    Layout.fillWidth: true
                    
                    ColumnLayout {
                        spacing: 0
                        Text {
                            text: Qt.formatTime(new Date(), "hh:mm")
                            font.family: "Inter"
                            font.pixelSize: 32
                            font.weight: Font.Bold
                            color: root.m3OnSurface
                        }
                        Text {
                            text: Qt.formatDate(new Date(), "dddd, MMMM d")
                            font.family: "Inter"
                            font.pixelSize: 14
                            color: root.m3OnSurfaceVariant
                        }
                        Timer {
                            interval: 1000; running: true; repeat: true
                            onTriggered: parent.children[0].text = Qt.formatTime(new Date(), "hh:mm")
                        }
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    RowLayout {
                        spacing: 8
                        ControlButton { icon: "󰐥"; onClicked: Qt.quit() }
                        ControlButton { icon: "󰍜"; onClicked: Qt.openUrlExternally("loginctl lock-session") }
                        ControlButton { icon: "󰒓"; onClicked: Qt.openUrlExternally("nm-connection-editor") }
                    }
                }
                
                // Grid
                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: 12
                    rowSpacing: 12
                    
                    QuickToggle {
                        icon: "󰖩"
                        label: "Wi-Fi"
                        subLabel: root.network.connected ? root.network.ssid : "Disconnected"
                        active: root.network.wifiEnabled
                        activeColor: root.cPrimary
                        onClicked: root.network.toggleWifi()
                    }
                    
                    QuickToggle {
                        icon: "󰂯"
                        label: "Bluetooth"
                        subLabel: root.bluetooth.powered ? "On" : "Off"
                        active: root.bluetooth.powered
                        activeColor: root.cPrimary
                        onClicked: root.bluetooth.togglePower()
                    }
                    
                    QuickToggle {
                        icon: "󰔎"
                        label: "Do Not Disturb"
                        subLabel: "Off"
                        active: root.notifs.dnd
                        onClicked: root.notifs.toggleDnd()
                    }
                    
                    QuickToggle {
                        icon: "󰅶"
                        label: "Caffeine"
                        subLabel: root.idleInhibitor.inhibited ? "On" : "Off"
                        active: root.idleInhibitor.inhibited
                        onClicked: root.idleInhibitor.inhibited = !root.idleInhibitor.inhibited
                    }
                    
                    QuickToggle {
                        icon: "󰹑"
                        label: "Screenshot"
                        subLabel: "Take Shot"
                        active: false
                        onClicked: root.screenshot.takeScreenshot("screen")
                    }
                }
                
                readonly property color cSubText: "#a6adc8"
                // Sliders
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    VolumeSlider {
                        audio: root.audio
                        pywal: root.pywal
                    }
                    BrightnessSlider {
                        brightness: root.brightness
                        pywal: root.pywal
                    }
                }
                
                // Stats
                SystemStats {
                    systemUsage: root.systemUsage
                    pywal: root.pywal
                }
                
                // Media
                MediaCard {
                    mpris: root.mpris
                    pywal: root.pywal
                }
                
                // Notifications
                NotificationList {
                    Layout.fillHeight: true
                    Layout.minimumHeight: 300
                    notifs: root.notifs
                    pywal: root.pywal
                }
            }
        }
    }
    
    component ControlButton: Rectangle {
        property string icon
        signal clicked()
        width: 40; height: 40; radius: 20
        color: Qt.rgba(root.m3OnSurface.r, root.m3OnSurface.g, root.m3OnSurface.b, 0.05)
        Text {
            anchors.centerIn: parent
            text: parent.icon
            font.family: "Material Design Icons"
            font.pixelSize: 20
            color: root.m3OnSurface
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }
}
