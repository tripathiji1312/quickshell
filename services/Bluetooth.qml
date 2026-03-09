pragma Singleton

import Quickshell
import Quickshell.Bluetooth
import QtQuick

Singleton {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var connectedDevices: Bluetooth.devices.values.filter(device => device.connected)
    readonly property bool powered: adapter?.enabled ?? false
    readonly property bool connected: connectedDevices.length > 0
    readonly property string deviceName: connected ? (connectedDevices[0]?.name ?? connectedDevices[0]?.alias ?? "Device") : ""
    readonly property int connectedCount: connectedDevices.length

    function togglePower() {
        if (adapter)
            adapter.enabled = !adapter.enabled
    }

    function setDiscovering(enabled: bool) {
        if (adapter)
            adapter.discovering = enabled
    }
}
