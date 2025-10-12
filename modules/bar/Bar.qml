import Quickshell
import QtQuick 6.10
import QtQuick.Layouts 6.10
import "../../config" as QsConfig
import "../../services" as QsServices

Item {
    id: root
    
    property var screen
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
    
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        anchors.topMargin: config.bar.padding
        anchors.bottomMargin: config.bar.padding
        spacing: 16
        
        // Left section - Minimal Workspaces
        Loader {
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
            source: "components/Workspaces.qml"
            onStatusChanged: {
                if (status === Loader.Ready) {
                    item.screen = Qt.binding(() => root.screen)
                }
            }
        }
        
        // Center section - Spacer
        Item {
            Layout.fillWidth: true
        }
        
        // Right section - Future: time, system indicators
        Item {
            Layout.preferredWidth: 0
            Layout.fillHeight: true
        }
    }
}
