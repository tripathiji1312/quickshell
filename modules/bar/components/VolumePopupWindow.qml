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
    readonly property var audio: QsServices.Audio
    
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
            text: "Volume"
            font.family: "Inter"
            font.pixelSize: 14
            font.weight: Font.DemiBold
            color: pywal.foreground
        }
        
        // Output volume
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                
                Text {
                    text: audio.muted ? "󰖁" : "󰕾"
                    font.family: "Material Design Icons"
                    font.pixelSize: 20
                    color: pywal.foreground
                }
                
                Text {
                    text: "Output"
                    font.family: "Inter"
                    font.pixelSize: 12
                    color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.7)
                }
                
                Item { Layout.fillWidth: true }
                
                Text {
                    text: audio.percentage + "%"
                    font.family: "Inter"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: pywal.foreground
                }
                
                // Mute toggle
                Rectangle {
                    width: 28
                    height: 28
                    radius: 6
                    color: audio.muted ? pywal.color1 : Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.1)
                    
                    Behavior on color {
                        ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: audio.muted ? "󰝟" : "󰝚"
                        font.family: "Material Design Icons"
                        font.pixelSize: 14
                        color: pywal.foreground
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: audio.toggleMute()
                    }
                }
            }
            
            // Volume slider
            Slider {
                id: volumeSlider
                Layout.fillWidth: true
                from: 0
                to: 150
                value: audio.percentage
                
                onMoved: {
                    audio.setVolume(value / 100)
                }
                
                background: Rectangle {
                    x: volumeSlider.leftPadding
                    y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                    implicitWidth: 200
                    implicitHeight: 6
                    width: volumeSlider.availableWidth
                    height: implicitHeight
                    radius: 3
                    color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.1)
                    
                    Rectangle {
                        width: volumeSlider.visualPosition * parent.width
                        height: parent.height
                        color: pywal.color2
                        radius: 3
                        
                        Behavior on width {
                            NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                        }
                    }
                }
                
                handle: Rectangle {
                    x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
                    y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                    implicitWidth: 18
                    implicitHeight: 18
                    radius: 9
                    color: pywal.foreground
                    border.color: pywal.color2
                    border.width: 2
                    
                    Behavior on x {
                        NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                    }
                }
            }
        }
        
        // Input volume
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                
                Text {
                    text: audio.sourceMuted ? "󰍭" : "󰍬"
                    font.family: "Material Design Icons"
                    font.pixelSize: 20
                    color: pywal.foreground
                }
                
                Text {
                    text: "Input"
                    font.family: "Inter"
                    font.pixelSize: 12
                    color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.7)
                }
                
                Item { Layout.fillWidth: true }
                
                Text {
                    text: audio.sourcePercentage + "%"
                    font.family: "Inter"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: pywal.foreground
                }
                
                // Mute toggle
                Rectangle {
                    width: 28
                    height: 28
                    radius: 6
                    color: audio.sourceMuted ? pywal.color1 : Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.1)
                    
                    Behavior on color {
                        ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: audio.sourceMuted ? "󰝟" : "󰝚"
                        font.family: "Material Design Icons"
                        font.pixelSize: 14
                        color: pywal.foreground
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: audio.toggleSourceMute()
                    }
                }
            }
            
            // Input volume slider
            Slider {
                id: inputSlider
                Layout.fillWidth: true
                from: 0
                to: 150
                value: audio.sourcePercentage
                
                onMoved: {
                    audio.setSourceVolume(value / 100)
                }
                
                background: Rectangle {
                    x: inputSlider.leftPadding
                    y: inputSlider.topPadding + inputSlider.availableHeight / 2 - height / 2
                    implicitWidth: 200
                    implicitHeight: 6
                    width: inputSlider.availableWidth
                    height: implicitHeight
                    radius: 3
                    color: Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.1)
                    
                    Rectangle {
                        width: inputSlider.visualPosition * parent.width
                        height: parent.height
                        color: pywal.color3
                        radius: 3
                        
                        Behavior on width {
                            NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                        }
                    }
                }
                
                handle: Rectangle {
                    x: inputSlider.leftPadding + inputSlider.visualPosition * (inputSlider.availableWidth - width)
                    y: inputSlider.topPadding + inputSlider.availableHeight / 2 - height / 2
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
        }
    }
}
