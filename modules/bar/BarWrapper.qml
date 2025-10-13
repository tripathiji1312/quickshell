import Quickshell
import Quickshell.Wayland
import QtQuick 6.10
import "../../config" as QsConfig

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
        
        property var controlCenter: item
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
                    }
                }
            }
        }
    }
}
