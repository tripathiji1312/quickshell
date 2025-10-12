import QtQuick 6.10
import QtQuick.Layouts 6.10
import QtQuick.Controls 6.10
import Quickshell
import Quickshell.Wayland
import "../../../services" as QsServices

PanelWindow {
    id: popupWindow
    
    property bool shouldShow: false
    property bool isHovered: false
    readonly property var pywal: QsServices.Pywal
    readonly property var brightness: QsServices.Brightness
    
    screen: Quickshell.screens[0]
    
    anchors {
        top: true
        right: true
    }
    
    margins {
        right: 0
        top: 0
    }
    
    width: 300
    height: contentColumn.implicitHeight + 24
    color: "transparent"
    visible: shouldShow || backgroundRect.opacity > 0
    
    // Background with hover detection
    Rectangle {
        id: backgroundRect
        anchors.fill: parent
        color: pywal.background
        opacity: popupWindow.shouldShow ? 0.98 : 0
        radius: 12
        
        scale: popupWindow.shouldShow ? 1 : 0.7
        transformOrigin: Item.TopRight
        
        Behavior on opacity {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }
        
        Behavior on scale {
            NumberAnimation { duration: 350; easing.type: Easing.OutBack; easing.overshoot: 1.5 }
        }
        
        border.color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.15)
        border.width: 1
        
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: popupWindow.isHovered = true
            onExited: {
                popupWindow.isHovered = false
                popupWindow.shouldShow = false
            }
        }
    }
    
    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12
        
        // Header
        Text {
            text: "Brightness"
            font.family: "Inter"
            font.pixelSize: 14
            font.weight: Font.DemiBold
            color: pywal.foreground
        }
        
        // Brightness control
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                
                Text {
                    text: "󰃠"
                    font.family: "Material Design Icons"
                    font.pixelSize: 20
                    color: pywal.foreground
                }
                
                Text {
                    text: "Display"
                    font.family: "Inter"
                    font.pixelSize: 12
                    color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.7)
                }
                
                Item { Layout.fillWidth: true }
                
                Text {
                    text: brightness.percentage + "%"
                    font.family: "Inter"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: pywal.foreground
                }
            }
            
            // Brightness slider
            Slider {
                id: brightnessSlider
                Layout.fillWidth: true
                from: 0
                to: 100
                value: brightness.percentage
                
                onMoved: {
                    brightness.setBrightness(value / 100)
                }
                
                background: Rectangle {
                    x: brightnessSlider.leftPadding
                    y: brightnessSlider.topPadding + brightnessSlider.availableHeight / 2 - height / 2
                    implicitWidth: 200
                    implicitHeight: 6
                    width: brightnessSlider.availableWidth
                    height: implicitHeight
                    radius: 3
                    color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.1)
                    
                    Rectangle {
                        width: brightnessSlider.visualPosition * parent.width
                        height: parent.height
                        color: pywal.color3
                        radius: 3
                        
                        Behavior on width {
                            NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                        }
                    }
                }
                
                handle: Rectangle {
                    x: brightnessSlider.leftPadding + brightnessSlider.visualPosition * (brightnessSlider.availableWidth - width)
                    y: brightnessSlider.topPadding + brightnessSlider.availableHeight / 2 - height / 2
                    implicitWidth: 18
                    implicitHeight: 18
                    radius: 9
                    color: pywal.foreground
                    border.color: pywal.color3
                    border.width: 2
                    
                    Behavior on x {
                        NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                    }
                }
            }
            
            // Quick brightness presets
            RowLayout {
                Layout.fillWidth: true
                spacing: 6
                
                Repeater {
                    model: [
                        { label: "25%", value: 0.25 },
                        { label: "50%", value: 0.5 },
                        { label: "75%", value: 0.75 },
                        { label: "100%", value: 1.0 }
                    ]
                    
                    Rectangle {
                        Layout.fillWidth: true
                        height: 28
                        radius: 6
                        color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.1)
                        
                        Text {
                            anchors.centerIn: parent
                            text: modelData.label
                            font.family: "Inter"
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: pywal.foreground
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: brightness.setBrightness(modelData.value)
                            
                            onPressed: parent.color = Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.2)
                            onReleased: parent.color = Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.1)
                        }
                    }
                }
            }
        }
    }
}
