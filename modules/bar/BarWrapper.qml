import Quickshell
import Quickshell.Wayland
import QtQuick 6.10
import "../../config" as QsConfig
import "components" as BarComponents

Scope {
    readonly property var config: QsConfig.Config
    
    // Media player popup window
    BarComponents.MediaPlayerPopupWindow {
        id: mediaPopup
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
                        item.mediaPopup = Qt.binding(() => mediaPopup)
                    }
                }
            }
        }
    }
}
