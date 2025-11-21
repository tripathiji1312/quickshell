import QtQuick 6.10
import QtQuick.Layouts 6.10
import QtQuick.Controls 6.10
import Quickshell
Rectangle {
    id: root
    
    property string icon: ""
    property string label: ""
    property string subLabel: ""
    property bool active: false
    property color activeColor: "#a6e3a1" // Default green
    signal clicked()
    
    Layout.fillWidth: true
    Layout.preferredHeight: 60
    
    radius: 30
    
    color: active ? activeColor : Qt.rgba(1, 1, 1, 0.1)
    
    Behavior on color {
        ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
    }
    
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
    
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        spacing: 12
        
        // Icon Circle
        Rectangle {
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            radius: 18
            color: active ? Qt.rgba(1, 1, 1, 0.2) : "transparent"
            
            Text {
                anchors.centerIn: parent
                text: root.icon
                font.family: "Material Design Icons"
                font.pixelSize: 20
                color: active ? "#1e1e2e" : "#e6e6e6" // Dark text on active, light on inactive
            }
        }
        
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            
            Text {
                text: root.label
                font.family: "Inter"
                font.pixelSize: 13
                font.weight: Font.DemiBold
                color: active ? "#1e1e2e" : "#e6e6e6"
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            
            Text {
                text: root.subLabel
                font.family: "Inter"
                font.pixelSize: 11
                color: active ? Qt.rgba(0.12, 0.12, 0.18, 0.7) : Qt.rgba(0.9, 0.9, 0.9, 0.5)
                elide: Text.ElideRight
                Layout.fillWidth: true
                visible: text !== ""
            }
        }
    }
}
