import Quickshell
import Quickshell.Wayland
import QtQuick 6.10
import "../../config" as QsConfig
import "components" as BarComponents

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
            
            // Bar content
            Loader {
                id: barLoader
                anchors.fill: parent
                source: "Bar.qml"
                
                onStatusChanged: {
                    if (status === Loader.Ready) {
                        item.screen = Qt.binding(() => modelData)
                        item.barWindow = Qt.binding(() => window)
                        item.popoutWrapper = Qt.binding(() => popoutWrapper)
                    }
                }
            }
            
            // Popout overlay - positioned OVER the bar
            BarComponents.MediaPopoutWrapper {
                id: popoutWrapper
                
                // Position below the bar, aligned with media player
                anchors.top: parent.bottom
                anchors.topMargin: 8
                anchors.left: parent.left
                anchors.leftMargin: 12 + 8 + 200  // Left margin + workspaces + spacing
            }
        }
    }
}
