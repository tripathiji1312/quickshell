import Quickshell
import QtQuick 6.10
import "../../../config" as QsConfig
import "../../../services" as QsServices

Rectangle {
    id: root
    
    property int workspaceId: 1
    property bool isActive: false
    property bool isOccupied: false
    
    signal clicked()
    
    readonly property var config: QsConfig.Config
    readonly property var pywal: QsServices.Pywal
    
    // Clean sizing - simple pills
    implicitWidth: {
        if (isActive) return config.bar.workspaces.workspaceSize * 2.5  // Long pill ONLY for active
        // Occupied and empty are same small size - no expansion!
        return config.bar.workspaces.workspaceSize * 0.8  // Small dot for both occupied and empty
    }
    implicitHeight: config.bar.workspaces.workspaceSize
    
    // Beautiful gradient-like colors from pywal
    color: {
        if (isActive) return pywal.colors.color3  // Muted red
        if (isOccupied) return pywal.colors.color5  // Muted brown
        return pywal.colors.color8  // Muted gray for empty
    }
    
    // No borders - clean look
    border.width: 0
    radius: config.bar.workspaces.cornerRadius
    
    // Smooth opacity for different states
    opacity: {
        if (isActive) return 1.0
        if (isOccupied) return 0.8  // Slightly more visible than empty
        return 0.3  // Very subtle for empty
    }
    
    // Buttery smooth transitions
    Behavior on implicitWidth {
        NumberAnimation {
            duration: config.bar.workspaces.animationDuration
            easing.type: Easing.OutCubic
        }
    }
    
    Behavior on color {
        ColorAnimation {
            duration: config.bar.workspaces.animationDuration
            easing.type: Easing.OutCubic
        }
    }
    
    Behavior on opacity {
        NumberAnimation {
            duration: config.bar.workspaces.animationDuration
            easing.type: Easing.OutCubic
        }
    }
    
    Behavior on scale {
        NumberAnimation {
            duration: 100
            easing.type: Easing.OutCubic
        }
    }
    
    // Single elegant dot in center of active workspace
    Rectangle {
        visible: isActive && !mouseArea.containsMouse
        anchors.centerIn: parent
        width: config.bar.workspaces.indicatorSize
        height: config.bar.workspaces.indicatorSize
        radius: config.bar.workspaces.indicatorSize / 2
        color: pywal.foreground
        opacity: 0.9
        
        Behavior on opacity {
            NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
        }
    }
    
    // Workspace number on hover (all workspaces)
    Text {
        visible: mouseArea.containsMouse
        anchors.centerIn: parent
        text: workspaceId
        color: pywal.foreground
        font.pixelSize: 10
        font.weight: Font.Medium
        opacity: 0.9
        
        Behavior on opacity {
            NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
        }
    }
    
    // Mouse interaction - smooth and responsive
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: root.clicked()
        
        onPressed: {
            if (config.bar.workspaces.enableClickAnimation) {
                root.scale = 0.85
            }
        }
        
        onReleased: {
            root.scale = 1.0
        }
        
        onEntered: {
            if (isActive) {
                root.opacity = 1.0
            } else if (isOccupied) {
                root.opacity = 0.85
            } else {
                root.opacity = 0.5
                root.scale = 1.2
            }
        }
        
        onExited: {
            if (isActive) {
                root.opacity = 1.0
            } else if (isOccupied) {
                root.opacity = 0.7
            } else {
                root.opacity = 0.3
            }
            root.scale = 1.0
        }
    }
    
    // Initial state
    scale: 1.0
}
