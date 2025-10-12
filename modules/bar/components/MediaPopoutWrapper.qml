import QtQuick 6.10
import qs.services

Item {
    id: wrapper
    
    property bool shouldShow: false
    property real targetX: 0  // X position to align popup to
    
    // Non-animated dimensions
    readonly property real nonAnimWidth: shouldShow ? 360 : 0
    readonly property real nonAnimHeight: shouldShow ? contentLoader.item?.implicitHeight ?? 0 : 0
    
    implicitWidth: nonAnimWidth
    implicitHeight: nonAnimHeight
    
    visible: width > 0 && height > 0
    clip: true
    
    // Smooth width/height animations
    Behavior on implicitWidth {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }
    
    Behavior on implicitHeight {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }
    
    // Animated background
    Rectangle {
        anchors.fill: parent
        anchors.leftMargin: targetX
        anchors.rightMargin: parent.width - targetX - 360
        
        color: Pywal.background || "#1e1e2e"
        opacity: 0.98
        radius: 12
        
        border.width: 1
        border.color: Pywal.color2 || "#89b4fa"
        
        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }
        
        Behavior on color {
            ColorAnimation { duration: 200 }
        }
    }
    
    // Content loader
    Loader {
        id: contentLoader
        
        anchors.fill: parent
        anchors.leftMargin: targetX
        anchors.rightMargin: parent.width - targetX - 360
        
        active: wrapper.shouldShow
        source: "MediaPlayerPopout.qml"
        
        onStatusChanged: {
            if (status === Loader.Ready && item) {
                item.wrapperItem = Qt.binding(() => wrapper)
            }
        }
    }
    
    // Hover area to keep popup open
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        
        onEntered: {
            // Keep popup open when hovering over it
            if (contentLoader.item) {
                contentLoader.item.isHovered = true
            }
        }
        
        onExited: {
            if (contentLoader.item) {
                contentLoader.item.isHovered = false
            }
        }
    }
}
