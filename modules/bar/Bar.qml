import Quickshell
import QtQuick 6.10
import QtQuick.Layouts 6.10
import QtQuick.Effects
import "components" as BarComponents
import "../../components/effects"
import "../../config" as QsConfig
import "../../services" as QsServices

Item {
    id: root
    
    property var screen
    property var barWindow
    property var mediaPopup
    property var bluetoothPopup
    property var networkPopup
    property var volumePopup
    property var brightnessPopup
    property var controlCenter
    property var launcher
    property var sidebar
    property var dashboard
    
    readonly property var config: QsConfig.Config
    readonly property var appearance: QsConfig.AppearanceConfig
    readonly property var pywal: QsServices.Pywal
    
    // ═══════════════════════════════════════════════════════════════════════
    // MINIMAL AESTHETIC BAR
    // Clean, professional, beautiful - inspired by modern Linux rice
    // ═══════════════════════════════════════════════════════════════════════
    
    // Main bar container with floating effect
    Item {
        id: barContainer
        anchors.fill: parent
        anchors.topMargin: 1
        anchors.leftMargin: 9
        anchors.rightMargin: 9
        anchors.bottomMargin: 1
        
        // ═══════════════════════════════════════════════════════════════
        // LEFT MODULE - Workspaces
        // ═══════════════════════════════════════════════════════════════
        Rectangle {
            id: leftModule
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            height: 28
            width: leftContent.implicitWidth + 16
            
            radius: 14
            color: pywal.surfaceContainer
            
            // Elegant shadow simulation with subtle border
            border.width: 1
            border.color: Qt.rgba(0, 0, 0, 0.15)
            
            // Smooth transitions
            Behavior on color {
                ColorAnimation { duration: 400; easing.type: Easing.OutCubic }
            }
            
            Behavior on width {
                NumberAnimation { duration: 350; easing.bezierCurve: [0.34, 1.56, 0.64, 1] }
            }
            
            // Top highlight for depth
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 1
                height: parent.height / 2
                radius: parent.radius - 1
                
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.04) }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }
            
            RowLayout {
                id: leftContent
                anchors.centerIn: parent
                spacing: 10
                
                // Workspaces
                Loader {
                    id: workspacesLoader
                    Layout.alignment: Qt.AlignVCenter
                    asynchronous: true
                    source: "components/Workspaces.qml"
                    
                    Binding {
                        target: workspacesLoader.item
                        property: "screen"
                        value: root.screen
                        when: workspacesLoader.status === Loader.Ready && root.screen !== undefined
                        restoreMode: Binding.RestoreBinding
                    }
                }
            }
        }
        
        // ═══════════════════════════════════════════════════════════════
        // CENTER MODULE - Clock (Focal Point)
        // ═══════════════════════════════════════════════════════════════
        Rectangle {
            id: centerModule
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            height: 28
            width: clockLoader.implicitWidth + 20
            
            radius: 14
            color: pywal.surfaceContainer
            
            border.width: 1
            border.color: Qt.rgba(0, 0, 0, 0.15)
            
            Behavior on color {
                ColorAnimation { duration: 400; easing.type: Easing.OutCubic }
            }
            
            // Top highlight
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 1
                height: parent.height / 2
                radius: parent.radius - 1
                
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.04) }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }
            
            Loader {
                id: clockLoader
                anchors.centerIn: parent
                asynchronous: true
                source: "components/Clock.qml"

                Binding {
                    target: clockLoader.item
                    property: "launcher"
                    value: root.launcher
                    when: clockLoader.status === Loader.Ready && root.launcher !== undefined
                    restoreMode: Binding.RestoreBinding
                }

                Binding {
                    target: clockLoader.item
                    property: "controlCenter"
                    value: root.controlCenter
                    when: clockLoader.status === Loader.Ready && root.controlCenter !== undefined
                    restoreMode: Binding.RestoreBinding
                }

                Binding {
                    target: clockLoader.item
                    property: "sidebar"
                    value: root.sidebar
                    when: clockLoader.status === Loader.Ready && root.sidebar !== undefined
                    restoreMode: Binding.RestoreBinding
                }

                Binding {
                    target: clockLoader.item
                    property: "dashboard"
                    value: root.dashboard
                    when: clockLoader.status === Loader.Ready && root.dashboard !== undefined
                    restoreMode: Binding.RestoreBinding
                }
            }
        }
        
        // ═══════════════════════════════════════════════════════════════
        // RIGHT SIDE - Three Separate Pills
        // ═══════════════════════════════════════════════════════════════
        Row {
            id: rightPills
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6
            
            // ═══ PILL 1: Network + Bluetooth (Connectivity) ═══
            Rectangle {
                id: connectivityPill
                height: 28
                width: connectivityContent.implicitWidth + 16
                radius: 14
                color: pywal.surfaceContainer
                border.width: 1
                border.color: Qt.rgba(0, 0, 0, 0.15)
                
                Behavior on color {
                    ColorAnimation { duration: 300 }
                }
                Behavior on width {
                    NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                }
                
                // Highlight
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 1
                    height: parent.height / 2
                    radius: parent.radius - 1
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.04) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }
                
                Row {
                    id: connectivityContent
                    anchors.centerIn: parent
                    spacing: 4
                    
                    Loader {
                        id: networkLoader
                        anchors.verticalCenter: parent.verticalCenter
                        asynchronous: true
                        source: "components/Network.qml"
                        
                        Binding {
                            target: networkLoader.item
                            property: "barWindow"
                            value: root.barWindow
                            when: networkLoader.status === Loader.Ready && root.barWindow !== undefined
                            restoreMode: Binding.RestoreBinding
                        }
                        
                        Binding {
                            target: networkLoader.item
                            property: "networkPopup"
                            value: root.networkPopup
                            when: networkLoader.status === Loader.Ready && root.networkPopup !== undefined
                            restoreMode: Binding.RestoreBinding
                        }
                    }
                    
                    // Separator
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 1
                        height: 12
                        radius: 0.5
                        color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.12)
                    }
                    
                    Loader {
                        id: bluetoothLoader
                        anchors.verticalCenter: parent.verticalCenter
                        asynchronous: true
                        source: "components/Bluetooth.qml"
                        
                        Binding {
                            target: bluetoothLoader.item
                            property: "barWindow"
                            value: root.barWindow
                            when: bluetoothLoader.status === Loader.Ready && root.barWindow !== undefined
                            restoreMode: Binding.RestoreBinding
                        }
                        
                        Binding {
                            target: bluetoothLoader.item
                            property: "bluetoothPopup"
                            value: root.bluetoothPopup
                            when: bluetoothLoader.status === Loader.Ready && root.bluetoothPopup !== undefined
                            restoreMode: Binding.RestoreBinding
                        }
                    }
                }
            }
            
            // ═══ PILL 2: Brightness + Volume (Audio/Display) ═══
            Rectangle {
                id: audioPill
                height: 28
                width: audioContent.implicitWidth + 16
                radius: 14
                color: pywal.surfaceContainer
                border.width: 1
                border.color: Qt.rgba(0, 0, 0, 0.15)
                
                Behavior on color {
                    ColorAnimation { duration: 300 }
                }
                Behavior on width {
                    NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                }
                
                // Highlight
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 1
                    height: parent.height / 2
                    radius: parent.radius - 1
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.04) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }
                
                Row {
                    id: audioContent
                    anchors.centerIn: parent
                    spacing: 6
                    
                    Loader {
                        id: brightnessLoader
                        anchors.verticalCenter: parent.verticalCenter
                        asynchronous: true
                        source: "components/Brightness.qml"
                        
                        Binding {
                            target: brightnessLoader.item
                            property: "barWindow"
                            value: root.barWindow
                            when: brightnessLoader.status === Loader.Ready && root.barWindow !== undefined
                            restoreMode: Binding.RestoreBinding
                        }
                        
                        Binding {
                            target: brightnessLoader.item
                            property: "brightnessPopup"
                            value: root.brightnessPopup
                            when: brightnessLoader.status === Loader.Ready && root.brightnessPopup !== undefined
                            restoreMode: Binding.RestoreBinding
                        }
                    }
                    
                    // Separator
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 1
                        height: 12
                        radius: 0.5
                        color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.12)
                    }
                    
                    Loader {
                        id: volumeLoader
                        anchors.verticalCenter: parent.verticalCenter
                        asynchronous: true
                        source: "components/Volume.qml"
                        
                        Binding {
                            target: volumeLoader.item
                            property: "barWindow"
                            value: root.barWindow
                            when: volumeLoader.status === Loader.Ready && root.barWindow !== undefined
                            restoreMode: Binding.RestoreBinding
                        }
                        
                        Binding {
                            target: volumeLoader.item
                            property: "volumePopup"
                            value: root.volumePopup
                            when: volumeLoader.status === Loader.Ready && root.volumePopup !== undefined
                            restoreMode: Binding.RestoreBinding
                        }
                    }
                }
            }
            
            // ═══ PILL 3: Battery + Control Center + Tray ═══
            Rectangle {
                id: powerPill
                height: 28
                width: powerContent.implicitWidth + 16
                radius: 14
                color: pywal.surfaceContainer
                border.width: 1
                border.color: Qt.rgba(0, 0, 0, 0.15)
                
                Behavior on color {
                    ColorAnimation { duration: 300 }
                }
                Behavior on width {
                    NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                }
                
                // Highlight
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 1
                    height: parent.height / 2
                    radius: parent.radius - 1
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.04) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }
                
                Row {
                    id: powerContent
                    anchors.centerIn: parent
                    spacing: 6
                    
                    // Status Indicators (Caffeine, DND)
                    Loader {
                        id: statusIndicatorsLoader
                        anchors.verticalCenter: parent.verticalCenter
                        asynchronous: true
                        source: "components/StatusIndicators.qml"
                        visible: item?.hasActiveIndicators ?? false
                    }
                    
                    // Separator (only if status indicators visible)
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 1
                        height: 12
                        radius: 0.5
                        color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.12)
                        visible: statusIndicatorsLoader.item?.hasActiveIndicators ?? false
                    }
                    
                    // Battery
                    Loader {
                        id: batteryLoader
                        anchors.verticalCenter: parent.verticalCenter
                        asynchronous: true
                        source: "components/Battery.qml"
                    }

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 1
                        height: 12
                        radius: 0.5
                        color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.12)
                    }

                    Loader {
                        id: notifCenterLoader
                        anchors.verticalCenter: parent.verticalCenter
                        asynchronous: true
                        source: "components/NotificationCenterToggle.qml"

                        Binding {
                            target: notifCenterLoader.item
                            property: "sidebar"
                            value: root.sidebar
                            when: notifCenterLoader.status === Loader.Ready && root.sidebar !== undefined
                            restoreMode: Binding.RestoreBinding
                        }

                        Binding {
                            target: notifCenterLoader.item
                            property: "controlCenter"
                            value: root.controlCenter
                            when: notifCenterLoader.status === Loader.Ready && root.controlCenter !== undefined
                            restoreMode: Binding.RestoreBinding
                        }

                        Binding {
                            target: notifCenterLoader.item
                            property: "launcher"
                            value: root.launcher
                            when: notifCenterLoader.status === Loader.Ready && root.launcher !== undefined
                            restoreMode: Binding.RestoreBinding
                        }
                    }
                    
                    // Separator
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 1
                        height: 12
                        radius: 0.5
                        color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.12)
                    }
                    
                    // Control Center Toggle
                    Loader {
                        id: controlCenterLoader
                        anchors.verticalCenter: parent.verticalCenter
                        asynchronous: true
                        source: "components/ControlCenterToggle.qml"
                        
                        Binding {
                            target: controlCenterLoader.item
                            property: "controlCenter"
                            value: root.controlCenter
                            when: controlCenterLoader.status === Loader.Ready && root.controlCenter !== undefined
                            restoreMode: Binding.RestoreBinding
                        }
                    }

                    
                    // System Tray (only if has items)
                    Loader {
                        id: systemTrayLoader
                        anchors.verticalCenter: parent.verticalCenter
                        asynchronous: true
                        source: "components/SystemTray.qml"
                        visible: item?.hasItems ?? false
                    }
                }
            }
        }
        
        // ═══════════════════════════════════════════════════════════════
        // MEDIA MODULE - Always visible (shows "No media" when not playing)
        // ═══════════════════════════════════════════════════════════════
        Rectangle {
            id: mediaModule
            anchors.left: leftModule.right
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            height: 28
            width: mediaPlayerLoader.implicitWidth + 16
            
            radius: 14
            color: pywal.surfaceContainer
            
            border.width: 1
            border.color: Qt.rgba(0, 0, 0, 0.15)
            
            clip: true
            
            Behavior on width {
                NumberAnimation { 
                    duration: 400
                    easing.bezierCurve: [0.34, 1.56, 0.64, 1]
                }
            }
            
            // Top highlight
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 1
                height: parent.height / 2
                radius: parent.radius - 1
                
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.04) }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }
            
            Loader {
                id: mediaPlayerLoader
                anchors.centerIn: parent
                asynchronous: true
                source: "components/MediaPlayer.qml"
                
                Binding {
                    target: mediaPlayerLoader.item
                    property: "barWindow"
                    value: root.barWindow
                    when: mediaPlayerLoader.status === Loader.Ready && root.barWindow !== undefined
                    restoreMode: Binding.RestoreBinding
                }
                
                Binding {
                    target: mediaPlayerLoader.item
                    property: "mediaPopup"
                    value: root.mediaPopup
                    when: mediaPlayerLoader.status === Loader.Ready && root.mediaPopup !== undefined
                    restoreMode: Binding.RestoreBinding
                }
            }
        }
    }
}
