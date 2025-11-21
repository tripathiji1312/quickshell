import QtQuick 6.10
import QtQuick.Layouts 6.10
import QtQuick.Controls 6.10
import QtQuick.Effects
import Quickshell

Rectangle {
    id: root
    
    required property var mpris
    property var activePlayer: mpris.active
    property var pywal
    
    Layout.fillWidth: true
    Layout.preferredHeight: 140
    
    radius: 24
    color: Qt.rgba(0, 0, 0, 0.2)
    clip: true
    
    visible: activePlayer !== null
    
    // Blurred Background
    Image {
        id: bgImage
        anchors.fill: parent
        source: activePlayer?.trackArtUrl ?? ""
        fillMode: Image.PreserveAspectCrop
        visible: false
    }
    
    MultiEffect {
        anchors.fill: parent
        source: bgImage
        blurEnabled: true
        blur: 1.0
        blurMax: 64
        saturation: 0.4
        brightness: -0.4
    }
    
    // Content
    RowLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16
        
        // Album Art
        Rectangle {
            Layout.preferredWidth: 100
            Layout.preferredHeight: 100
            radius: 16
            color: Qt.rgba(1, 1, 1, 0.1)
            clip: true
            
            Image {
                anchors.fill: parent
                source: activePlayer?.trackArtUrl ?? ""
                fillMode: Image.PreserveAspectCrop
            }
            
            Text {
                anchors.centerIn: parent
                text: "󰝚"
                font.family: "Material Design Icons"
                font.pixelSize: 40
                color: Qt.rgba(1, 1, 1, 0.5)
                visible: !activePlayer?.trackArtUrl
            }
        }
        
        // Info & Controls
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 4
            
            Text {
                text: activePlayer?.trackTitle ?? "No Media"
                font.family: "Inter"
                font.pixelSize: 16
                font.weight: Font.Bold
                color: "#ffffff"
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            
            Text {
                text: activePlayer?.trackArtist ?? ""
                font.family: "Inter"
                font.pixelSize: 13
                color: Qt.rgba(1, 1, 1, 0.7)
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            
            Item { Layout.fillHeight: true }
            
            // Controls
            RowLayout {
                Layout.fillWidth: true
                spacing: 20
                
                // Prev
                Text {
                    text: "󰒮"
                    font.family: "Material Design Icons"
                    font.pixelSize: 24
                    color: "#ffffff"
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: activePlayer?.previous()
                    }
                }
                
                // Play/Pause
                Rectangle {
                    width: 40
                    height: 40
                    radius: 20
                    color: "#ffffff"
                    
                    Text {
                        anchors.centerIn: parent
                        text: activePlayer?.isPlaying ? "󰏤" : "󰐊"
                        font.family: "Material Design Icons"
                        font.pixelSize: 24
                        color: "#000000"
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: activePlayer?.playPause()
                    }
                }
                
                // Next
                Text {
                    text: "󰒭"
                    font.family: "Material Design Icons"
                    font.pixelSize: 24
                    color: "#ffffff"
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: activePlayer?.next()
                    }
                }
            }
        }
    }
}
