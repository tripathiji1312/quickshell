import Quickshell
import Quickshell.Wayland
import QtQuick 6.10
import "../../config" as QsConfig

Scope {
    readonly property var config: QsConfig.Config
    
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
            mask: Region { item: barLoader }
            
            Loader {
                id: barLoader
                anchors.fill: parent
                source: "Bar.qml"
                
                onStatusChanged: {
                    if (status === Loader.Ready) {
                        item.screen = Qt.binding(() => modelData)
                    }
                }
            }
        }
    }
}
