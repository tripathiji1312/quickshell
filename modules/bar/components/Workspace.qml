import Quickshell
import QtQuick 6.10
import "../../../config" as QsConfig
import "../../../services" as QsServices
import "../../../components/effects"

// Modern fluid workspace indicator
Rectangle {
    id: root
    
    property int workspaceId: 1
    property bool isActive: false
    property bool isOccupied: false
    
    signal clicked()
    
    readonly property var config: QsConfig.Config
    readonly property var pywal: QsServices.Pywal
    
    // Dynamic sizing with fluid animation
    implicitWidth: {
        if (isActive) return 28  // Expanded pill for active
        if (isOccupied) return 10  // Larger dot for occupied
        return 6  // Minimal dot for empty
    }
    implicitHeight: {
        if (isActive) return 10
        return 6  // Consistent height for non-active
    }
    
    // Beautiful gradient-based colors
    color: {
        if (isActive) return pywal.primary
        if (isOccupied) return Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.5)
        return Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.2)
    }
    
    border.width: 0
    radius: height / 2
    
    // Smooth material animations
    Behavior on implicitWidth {
        NumberAnimation {
            duration: Material3Anim.medium2
            easing.bezierCurve: Material3Anim.emphasizedDecelerate
        }
    }
    
    Behavior on implicitHeight {
        NumberAnimation {
            duration: Material3Anim.medium2
            easing.bezierCurve: Material3Anim.emphasizedDecelerate
        }
    }
    
    Behavior on color {
        ColorAnimation {
            duration: Material3Anim.short4
            easing.bezierCurve: Material3Anim.standard
        }
    }
    
    Behavior on opacity {
        NumberAnimation {
            duration: Material3Anim.short4
            easing.bezierCurve: Material3Anim.standard
        }
    }
    
    Behavior on scale {
        NumberAnimation {
            duration: Material3Anim.short2
            easing.bezierCurve: Material3Anim.standard
        }
    }
    
    // Inner glow for active workspace
    Rectangle {
        visible: isActive
        anchors.fill: parent
        anchors.margins: 1
        radius: parent.radius - 1
        color: "transparent"
        border.width: 1
        border.color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.2)
        
        Behavior on opacity {
            NumberAnimation { 
                duration: Material3Anim.short3
                easing.bezierCurve: Material3Anim.standard
            }
        }
    }
    
    // Subtle glow pulse for active workspace
    Rectangle {
        visible: isActive
        anchors.centerIn: parent
        width: parent.width + 4
        height: parent.height + 4
        radius: (height) / 2
        color: "transparent"
        border.width: 2
        border.color: Qt.rgba(pywal.primary.r, pywal.primary.g, pywal.primary.b, 0.15)
        
        SequentialAnimation on opacity {
            running: isActive
            loops: Animation.Infinite
            
            NumberAnimation { to: 0.3; duration: 1500; easing.type: Easing.InOutSine }
            NumberAnimation { to: 0.8; duration: 1500; easing.type: Easing.InOutSine }
        }
    }
    
    // Workspace number tooltip on hover
    Rectangle {
        id: tooltip
        visible: mouseArea.containsMouse
        anchors.centerIn: parent
        width: 18
        height: 18
        radius: 4
        color: Qt.rgba(pywal.surfaceContainerHighest.r, pywal.surfaceContainerHighest.g, pywal.surfaceContainerHighest.b, 0.95)
        border.width: 1
        border.color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.1)
        
        opacity: mouseArea.containsMouse ? 1 : 0
        scale: mouseArea.containsMouse ? 1 : 0.8
        
        Behavior on opacity {
            NumberAnimation { duration: Material3Anim.short2 }
        }
        
        Behavior on scale {
            NumberAnimation { 
                duration: Material3Anim.short3
                easing.bezierCurve: Material3Anim.emphasizedDecelerate
            }
        }
        
        Text {
            anchors.centerIn: parent
            text: workspaceId
            color: pywal.foreground
            font.pixelSize: 10
            font.weight: Font.Bold
            font.family: "Inter"
        }
    }
    
    // Mouse interaction
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        anchors.margins: -4  // Larger hit area
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: root.clicked()
        
        onPressed: {
            root.scale = 0.85
        }
        
        onReleased: {
            root.scale = 1.0
        }
        
        onEntered: {
            if (!isActive) {
                root.scale = 1.2
            }
        }
        
        onExited: {
            root.scale = 1.0
        }
    }
    
    scale: 1.0
}
