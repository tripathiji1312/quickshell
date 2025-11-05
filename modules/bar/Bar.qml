import Quickshell
import QtQuick 6.10
import QtQuick.Layouts 6.10
import "components" as BarComponents
import "../../config" as QsConfig
import "../../services" as QsServices

Item {
    id: root
    
    property var screen
    property var barWindow
    property var mediaPopup  // Reference to media popup window
    property var bluetoothPopup  // Reference to bluetooth popup window
    property var networkPopup  // Reference to network popup window
    property var volumePopup  // Reference to volume popup window
    property var brightnessPopup  // Reference to brightness popup window
    property var controlCenter  // Reference to control center window
    
    readonly property var config: QsConfig.Config
    readonly property var pywal: QsServices.Pywal
    
    // Minimal, clean background with pywal colors
    Rectangle {
        anchors.fill: parent
        color: pywal.background
        opacity: config.bar.backgroundOpacity
        
        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
    }
    
    // Left section - Workspaces and Media Player
    RowLayout {
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 16
        
        // Minimal Workspaces
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
        
        // Media Player
        Loader {
            id: mediaPlayerLoader
            Layout.alignment: Qt.AlignVCenter
            Layout.leftMargin: 8
            Layout.minimumWidth: 120
            Layout.preferredWidth: item ? item.implicitWidth : 120
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
        
        // System Tray
        Loader {
            id: systemTrayLoader
            Layout.alignment: Qt.AlignVCenter
            Layout.leftMargin: 8
            asynchronous: true
            source: "components/SystemTray.qml"
        }
    }
    
    // Center section - Clock (absolutely centered)
    Loader {
        id: clockLoader
        anchors.centerIn: parent
        asynchronous: true
        source: "components/Clock.qml"
    }
    
    // Right section - System, Volume, Brightness, Network, Bluetooth, Battery
    RowLayout {
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 16
        
        // System usage (CPU, Memory, Disk)
        Loader {
            id: systemUsageLoader
            Layout.alignment: Qt.AlignVCenter
            asynchronous: true
            source: "components/SystemUsage.qml"
        }
        
        // Separator
        Rectangle {
            width: 1
            height: 16
            color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.2)
        }
        
        // Volume module
        Loader {
            id: volumeLoader
            Layout.alignment: Qt.AlignVCenter
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
        
        // Brightness module
        Loader {
            id: brightnessLoader
            Layout.alignment: Qt.AlignVCenter
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
            width: 1
            height: 16
            color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.2)
        }
        
        // Network module
        Loader {
            id: networkLoader
            Layout.alignment: Qt.AlignVCenter
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
        
        // Bluetooth module
        Loader {
            id: bluetoothLoader
            Layout.alignment: Qt.AlignVCenter
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
        
        // Separator
        Rectangle {
            width: 1
            height: 16
            color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.2)
        }
        
        // Control Center toggle
        Loader {
            id: controlCenterLoader
            Layout.alignment: Qt.AlignVCenter
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
        
        // Battery module
        Loader {
            id: batteryLoader
            Layout.alignment: Qt.AlignVCenter
            asynchronous: true
            source: "components/Battery.qml"
        }
    }
}
