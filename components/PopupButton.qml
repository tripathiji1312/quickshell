// Reusable bar button component with popup support
import QtQuick 6.10
import QtQuick.Layouts 6.10
import "../services" as QsServices

Item {
    id: root
    
    // Required properties
    required property string iconText
    required property string labelText
    required property color iconColor
    
    // Optional popup reference
    property var popup: null
    property var barWindow: null
    
    // Optional click handler
    signal clicked()
    
    // Appearance
    readonly property var pywal: QsServices.Pywal
    readonly property var logger: QsServices.Logger
    readonly property bool isHovered: mouseArea.containsMouse
    
    implicitWidth: contentRow.implicitWidth
    implicitHeight: contentRow.implicitHeight
    
    // Show popup timer
    Timer {
        id: showTimer
        interval: 300
        onTriggered: {
            if (popup && barWindow) {
                logger.debug("PopupButton", "Showing popup for: " + labelText)
                const pos = root.mapToItem(barWindow.contentItem, 0, 0)
                const rightEdge = pos.x + root.width
                const screenWidth = barWindow.screen.width
                popup.margins.right = Math.round(screenWidth - rightEdge)
                popup.margins.top = Math.round(barWindow.height + 6)
                popup.shouldShow = true
            }
        }
    }
    
    // Hover detection
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        
        onEntered: {
            if (popup) {
                showTimer.start()
            }
        }
        
        onExited: {
            showTimer.stop()
        }
        
        onClicked: {
            root.clicked()
        }
    }
    
    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: 6
        
        // Icon
        Text {
            id: icon
            Layout.alignment: Qt.AlignVCenter
            
            text: root.iconText
            font.family: "Material Design Icons"
            font.pixelSize: 16
            color: root.iconColor
            
            Behavior on color {
                ColorAnimation { 
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }
        }
        
        // Label (optional, only shown if text is provided)
        Text {
            id: label
            Layout.alignment: Qt.AlignVCenter
            
            visible: root.labelText !== ""
            text: root.labelText
            font.family: "Inter"
            font.pixelSize: 12
            font.weight: Font.Medium
            color: pywal.foreground
            
            Behavior on opacity {
                NumberAnimation { 
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }
        }
    }
    
    // Hover highlight effect
    Rectangle {
        anchors.fill: parent
        anchors.margins: -4
        radius: 6
        color: Qt.rgba(pywal.color4.r, pywal.color4.g, pywal.color4.b, 0.1)
        opacity: isHovered ? 1 : 0
        z: -1
        
        Behavior on opacity {
            NumberAnimation { 
                duration: 150
                easing.type: Easing.OutCubic
            }
        }
    }
}
