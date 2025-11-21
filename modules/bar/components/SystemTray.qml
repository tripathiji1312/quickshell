import QtQuick 6.10
import QtQuick.Layouts 6.10
import Quickshell
import Quickshell.Services.SystemTray

RowLayout {
    id: root
    spacing: 4
    
    Repeater {
        model: SystemTray.items
        
        delegate: Rectangle {
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            radius: 4
            color: "transparent"
            
            Image {
                anchors.centerIn: parent
                width: 16
                height: 16
                source: modelData.icon
                visible: status === Image.Ready
            }
            
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: {
                    if (mouse.button === Qt.LeftButton) {
                        modelData.activate(0, 0)
                    } else if (mouse.button === Qt.RightButton) {
                        modelData.menu.open(0, 0)
                    }
                }
            }
        }
    }
}
