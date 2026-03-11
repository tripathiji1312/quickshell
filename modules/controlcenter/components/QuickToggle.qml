import QtQuick 6.10
import QtQuick.Layouts 6.10
import QtQuick.Controls 6.10
import Quickshell
import "../../../components/effects"

Rectangle {
    id: root
    
    property string icon: ""
    property string label: ""
    property string subLabel: ""
    property bool active: false
    property color activeColor: "#a6e3a1"
    property color surfaceColor: Qt.rgba(0.15, 0.15, 0.18, 1)
    property color textColor: "#e6e6e6"
    signal clicked()
    
    Layout.fillWidth: true
    Layout.preferredHeight: 72

    radius: 24

    color: active
        ? Qt.rgba(activeColor.r, activeColor.g, activeColor.b, 0.16)
        : surfaceColor
    border.width: 1
    border.color: active
        ? Qt.rgba(activeColor.r, activeColor.g, activeColor.b, 0.32)
        : Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.12)
    
    // Smooth M3 color transition
    Behavior on color {
        ColorAnimation { 
            duration: Material3Anim.medium2
            easing.bezierCurve: Material3Anim.standard
        }
    }

    Behavior on border.color {
        ColorAnimation {
            duration: Material3Anim.short4
            easing.bezierCurve: Material3Anim.standard
        }
    }
    
    // Press scale animation
    scale: toggleMouse.pressed ? 0.98 : toggleMouse.containsMouse ? Material3Anim.hoverScale : 1.0
    Behavior on scale {
        NumberAnimation {
            duration: Material3Anim.short2
            easing.bezierCurve: Material3Anim.springGentle
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 64
        radius: parent.radius
        color: Qt.rgba(activeColor.r, activeColor.g, activeColor.b, active ? 0.14 : 0.06)
        opacity: active || toggleMouse.containsMouse ? 1 : 0.84
    }
    
    // Hover state overlay
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
            color: root.active 
                ? Qt.rgba(1, 1, 1, Material3Anim.hoverOpacity)
                : Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.06)
        opacity: toggleMouse.containsMouse && !toggleMouse.pressed ? 1 : 0
        
        Behavior on opacity {
            NumberAnimation {
                duration: Material3Anim.short3
                easing.bezierCurve: Material3Anim.standard
            }
        }
    }
    
    MouseArea {
        id: toggleMouse
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: root.clicked()
    }
    
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        spacing: 14
        
        // Icon Circle
        Rectangle {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            radius: 20
            color: active 
                ? Qt.rgba(1, 1, 1, 0.18) 
                : Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.10)
            
            Behavior on color {
                ColorAnimation {
                    duration: Material3Anim.short4
                    easing.bezierCurve: Material3Anim.standard
                }
            }
            
            Text {
                anchors.centerIn: parent
                text: root.icon
                font.family: "Material Design Icons"
                font.pixelSize: 22
                color: root.textColor
                
                Behavior on color {
                    ColorAnimation {
                        duration: Material3Anim.short4
                        easing.bezierCurve: Material3Anim.standard
                    }
                }
            }
        }
        
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            
            Text {
                text: root.label
                font.family: "Inter"
                font.pixelSize: 14
                font.weight: Font.DemiBold
                color: root.textColor
                elide: Text.ElideRight
                Layout.fillWidth: true
                
                Behavior on color {
                    ColorAnimation {
                        duration: Material3Anim.short4
                        easing.bezierCurve: Material3Anim.standard
                    }
                }
            }
            
            Text {
                text: root.subLabel
                font.family: "Inter"
                font.pixelSize: 12
                color: active 
                    ? Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.72)
                    : Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.6)
                elide: Text.ElideRight
                Layout.fillWidth: true
                visible: text !== ""
                
                Behavior on color {
                    ColorAnimation {
                        duration: Material3Anim.short4
                        easing.bezierCurve: Material3Anim.standard
                    }
                }
            }
        }
    }
}
