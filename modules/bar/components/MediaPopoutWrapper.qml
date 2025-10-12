import QtQuick 6.10
import qs.services

Item {
    id: root
    
    property string currentName: ""
    property bool hasCurrent: false
    
    visible: implicitWidth > 0 && implicitHeight > 0
    
    implicitWidth: hasCurrent ? contentLoader.implicitWidth + 32 : 0
    implicitHeight: hasCurrent ? contentLoader.implicitHeight + 32 : 0
    
    // Add a visible rectangle for debugging
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.width: 2
        border.color: "red"
        visible: root.hasCurrent
    }
    
    Behavior on implicitWidth {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }
    
    Behavior on implicitHeight {
        enabled: implicitWidth > 0
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }
    
    Loader {
        id: contentLoader
        anchors.centerIn: parent
        active: root.hasCurrent && root.currentName === "mediaplayer"
        source: active ? "MediaPlayerPopup.qml" : ""
        
        opacity: 0
        
        onLoaded: {
            item.player = Qt.binding(() => Players.active)
            item.shouldBeActive = Qt.binding(() => root.hasCurrent && root.currentName === "mediaplayer")
        }
        
        states: State {
            name: "active"
            when: contentLoader.active && contentLoader.status === Loader.Ready
            
            PropertyChanges {
                contentLoader.opacity: 1
            }
        }
        
        transitions: [
            Transition {
                from: ""
                to: "active"
                
                SequentialAnimation {
                    NumberAnimation {
                        property: "opacity"
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }
            },
            Transition {
                from: "active"
                to: ""
                
                SequentialAnimation {
                    NumberAnimation {
                        property: "opacity"
                        duration: 180
                        easing.type: Easing.InCubic
                    }
                }
            }
        ]
        
        // Keep popout visible when hovering over it
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            propagateComposedEvents: true
            acceptedButtons: Qt.NoButton
            
            onExited: {
                Qt.callLater(() => {
                    if (!containsMouse) {
                        root.hasCurrent = false
                    }
                })
            }
        }
    }
}
