import QtQuick 6.10
import QtQuick.Layouts 6.10
import qs.services
import "../../../components/effects"

Item {
    id: root

    property var launcher
    property var controlCenter
    property var sidebar
    property var dashboard
    
    implicitWidth: clockRow.implicitWidth
    implicitHeight: clockRow.implicitHeight
    
    Row {
        id: clockRow
        anchors.centerIn: parent
        spacing: 8
        
        // Compact time display
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 1
            
            // Hours
            Text {
                id: hoursText
                text: Time.format("hh")
                color: Pywal.foreground
                font.pixelSize: 12
                font.weight: Font.Bold
                font.family: "Inter"
                font.letterSpacing: 0.3
            }
            
            // Animated colon separator
            Text {
                id: colonSeparator
                text: ":"
                color: Pywal.primary
                font.pixelSize: 12
                font.weight: Font.Bold
                font.family: "Inter"
                
                // Subtle pulse animation
                SequentialAnimation on opacity {
                    running: true
                    loops: Animation.Infinite
                    
                    NumberAnimation { to: 0.4; duration: 800; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0; duration: 800; easing.type: Easing.InOutSine }
                }
            }
            
            // Minutes
            Text {
                id: minutesText
                text: Time.format("mm")
                color: Pywal.foreground
                font.pixelSize: 12
                font.weight: Font.Bold
                font.family: "Inter"
                font.letterSpacing: 0.3
            }
        }
        
        // Compact date
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: Time.format("ddd d")
            color: Qt.rgba(Pywal.foreground.r, Pywal.foreground.g, Pywal.foreground.b, 0.6)
            font.pixelSize: 10
            font.weight: Font.Medium
            font.family: "Inter"
        }
    }

    MouseArea {
        anchors.fill: parent
        anchors.margins: -6
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                if (!root.dashboard)
                    return

                root.dashboard.shouldShow = !root.dashboard.shouldShow
                if (root.dashboard.shouldShow) {
                    if (root.launcher)
                        root.launcher.shouldShow = false
                    if (root.controlCenter)
                        root.controlCenter.shouldShow = false
                    if (root.sidebar)
                        root.sidebar.shouldShow = false
                }
                return
            }

            if (!root.launcher)
                return

            root.launcher.shouldShow = !root.launcher.shouldShow
            if (root.launcher.shouldShow) {
                if (root.controlCenter)
                    root.controlCenter.shouldShow = false
                if (root.sidebar)
                    root.sidebar.shouldShow = false
                if (root.dashboard)
                    root.dashboard.shouldShow = false
            }
        }
    }
}
