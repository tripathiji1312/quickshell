import QtQuick 6.10
import QtQuick.Layouts 6.10
import QtQuick.Controls 6.10
import "../../../services" as QsServices
import "../../../config" as QsConfig

// Status Indicators - Caffeine and DND dots in the bar
Item {
    id: root
    
    readonly property var pywal: QsServices.Pywal
    readonly property var idleInhibitor: QsServices.IdleInhibitor
    readonly property var notifs: QsServices.Notifs
    
    readonly property bool caffeineActive: idleInhibitor.inhibited
    readonly property bool dndActive: notifs.dnd
    readonly property bool hasActiveIndicators: caffeineActive || dndActive
    
    implicitWidth: hasActiveIndicators ? indicatorRow.implicitWidth : 0
    implicitHeight: 28
    
    visible: hasActiveIndicators
    opacity: hasActiveIndicators ? 1 : 0
    
    Behavior on implicitWidth {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }
    Behavior on opacity {
        NumberAnimation { duration: 150 }
    }
    
    Row {
        id: indicatorRow
        anchors.centerIn: parent
        spacing: 6
        
        // Caffeine indicator (coffee icon)
        Rectangle {
            id: caffeineIndicator
            width: caffeineActive ? 22 : 0
            height: 22
            radius: 11
            color: Qt.rgba(pywal.primary.r, pywal.primary.g, pywal.primary.b, 0.2)
            visible: caffeineActive
            
            Behavior on width {
                NumberAnimation { duration: 200; easing.bezierCurve: [0.34, 1.56, 0.64, 1] }
            }
            
            Text {
                anchors.centerIn: parent
                text: "󰛊"  // Coffee icon
                font.family: "Material Design Icons"
                font.pixelSize: 12
                color: pywal.primary
            }
            
            // Subtle pulse animation when active
            SequentialAnimation on opacity {
                running: caffeineActive
                loops: Animation.Infinite
                NumberAnimation { to: 0.7; duration: 1500; easing.type: Easing.InOutSine }
                NumberAnimation { to: 1.0; duration: 1500; easing.type: Easing.InOutSine }
            }
            
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                
                ToolTip.visible: containsMouse
                ToolTip.text: "Caffeine Mode (click to disable)"
                ToolTip.delay: 300
                
                onClicked: idleInhibitor.inhibited = false
            }
        }
        
        // DND indicator (bell off icon)
        Rectangle {
            id: dndIndicator
            width: dndActive ? 22 : 0
            height: 22
            radius: 11
            color: Qt.rgba(pywal.warning.r, pywal.warning.g, pywal.warning.b, 0.2)
            visible: dndActive
            
            Behavior on width {
                NumberAnimation { duration: 200; easing.bezierCurve: [0.34, 1.56, 0.64, 1] }
            }
            
            Text {
                anchors.centerIn: parent
                text: "󰂛"  // Bell off icon
                font.family: "Material Design Icons"
                font.pixelSize: 12
                color: pywal.warning
            }
            
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                
                ToolTip.visible: containsMouse
                ToolTip.text: "Do Not Disturb (click to disable)"
                ToolTip.delay: 300
                
                onClicked: notifs.dnd = false
            }
        }
    }
}
