import QtQuick 6.10
import QtQuick.Layouts 6.10
import Quickshell
import Quickshell.Bluetooth
import "../../../services" as QsServices

// Clean Bluetooth indicator - No shadows, proper alignment
Item {
    id: root
    
    property var barWindow
    property var bar  // Reference to Bar.qml root for inline popup toggle
    
    readonly property var pywal: QsServices.Pywal
    readonly property bool isHovered: mouseArea.containsMouse
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var connectedDevices: Bluetooth.devices.values.filter(d => d.connected)
    readonly property bool hasConnection: connectedDevices.length > 0
    readonly property bool isEnabled: adapter?.enabled ?? false
    readonly property string deviceName: hasConnection ? (connectedDevices[0]?.name ?? "Device") : ""
    readonly property int deviceCount: connectedDevices.length
    
    implicitWidth: bluetoothRow.implicitWidth
    implicitHeight: 20
    
    RowLayout {
        id: bluetoothRow
        anchors.centerIn: parent
        spacing: 5
        
        // Bluetooth icon
        Text {
            id: bluetoothIcon
            Layout.alignment: Qt.AlignVCenter
            
            text: {
                if (!isEnabled) return "󰂲"
                if (hasConnection) return "󰂱"
                return "󰂯"
            }
            
            font.family: "Material Design Icons"
            font.pixelSize: 14
            
            color: {
                if (!isEnabled) return Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.3)
                if (isHovered) return pywal.primary
                if (hasConnection) return Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.8)
                return Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.5)
            }
            
            Behavior on color { ColorAnimation { duration: 150 } }
            
            scale: isHovered ? 1.05 : 1.0
            Behavior on scale { NumberAnimation { duration: 100 } }
        }
        
        // Device name - simple text, no gradient overlay
        Text {
            id: deviceText
            Layout.alignment: Qt.AlignVCenter
            Layout.maximumWidth: 65
            
            text: {
                if (!isEnabled) return "Off"
                if (!hasConnection) return "No Device"
                if (deviceCount > 1) return deviceName + " +" + (deviceCount - 1)
                return deviceName
            }
            
            font.family: "Inter"
            font.pixelSize: 10
            font.weight: hasConnection ? Font.Medium : Font.Normal
            elide: Text.ElideRight
            
            color: {
                if (!isEnabled || !hasConnection) return Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.4)
                if (isHovered) return pywal.foreground
                return Qt.rgba(pywal.foreground.r, pywal.foreground.g, pywal.foreground.b, 0.75)
            }
            
            Behavior on color { ColorAnimation { duration: 150 } }
        }
    }
    
    // Click handler
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        anchors.margins: -4
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        
        onClicked: {
            if (root.bar) {
                root.bar.togglePopup("bluetooth")
            }
        }
    }
}
