import Quickshell
import Quickshell.Wayland
import QtQuick 6.10
import "../../config" as QsConfig
import "../../services" as QsServices

Scope {
    readonly property var config: QsConfig.Config
    
    // Media popup window - DISABLED: Media controls are in Control Center only
    // Loader {
    //     id: mediaPopupLoader
    //     source: "components/MediaPlayerPopupWindow.qml"
    //     
    //     property var mediaPopup: item
    // }
    
    // Bluetooth popup window
    Loader {
        id: bluetoothPopupLoader
        source: "components/BluetoothPopupWindow.qml"
        
        property var bluetoothPopup: item
    }
    
    // Network popup window
    Loader {
        id: networkPopupLoader
        source: "components/NetworkPopupWindow.qml"
        
        property var networkPopup: item
    }
    
    // Volume popup window
    Loader {
        id: volumePopupLoader
        source: "components/VolumePopupWindow.qml"
        
        property var volumePopup: item
    }
    
    // Brightness popup window
    Loader {
        id: brightnessPopupLoader
        source: "components/BrightnessPopupWindow.qml"
        
        property var brightnessPopup: item
    }
    
    // Control Center window
    Loader {
        id: controlCenterLoader
        source: "../controlcenter/ControlCenterWindow.qml"
        asynchronous: true
        
        property var controlCenter: item
        
        onStatusChanged: {
            QsServices.Logger.debug(
                "BarWrapper",
                `Control Center loader status: ${status === Loader.Ready ? "READY" : status === Loader.Loading ? "LOADING" : status === Loader.Error ? "ERROR" : "NULL"}`
            )
            if (status === Loader.Error) {
                QsServices.Logger.error("BarWrapper", "Control Center failed to load")
            }
            if (status === Loader.Ready) {
                QsServices.Logger.debug("BarWrapper", `Control Center loaded, item: ${item ? "EXISTS" : "NULL"}`)
            }
        }
    }

    Loader {
        id: launcherLoader
        source: "../launcher/LauncherWindow.qml"
        asynchronous: true

        property var launcher: item
    }

    Loader {
        id: sidebarLoader
        source: "../sidebar/SidebarWindow.qml"
        asynchronous: true

        property var sidebar: item
    }

    Loader {
        id: dashboardLoader
        source: "../dashboard/DashboardWindow.qml"
        asynchronous: true

        property var dashboard: item
    }
    
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: window
            
            property var modelData
            
            screen: modelData
            anchors {
                top: true
                left: true
                right: true
            }
            
            implicitHeight: config.bar.height
            color: "transparent"
            
            // Bar content
            Loader {
                id: barLoader
                anchors.fill: parent
                source: "Bar.qml"
                
                onStatusChanged: {
                    if (status === Loader.Ready) {
                        item.screen = Qt.binding(() => modelData)
                        item.barWindow = Qt.binding(() => window)
                        // item.mediaPopup = Qt.binding(() => mediaPopupLoader.item)  // DISABLED
                        item.bluetoothPopup = Qt.binding(() => bluetoothPopupLoader.item)
                        item.networkPopup = Qt.binding(() => networkPopupLoader.item)
                        item.volumePopup = Qt.binding(() => volumePopupLoader.item)
                        item.brightnessPopup = Qt.binding(() => brightnessPopupLoader.item)
                        item.controlCenter = Qt.binding(() => controlCenterLoader.item)
                        item.launcher = Qt.binding(() => launcherLoader.item)
                        item.sidebar = Qt.binding(() => sidebarLoader.item)
                        item.dashboard = Qt.binding(() => dashboardLoader.item)
                    }
                }
            }
        }
    }
}
