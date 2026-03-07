pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import "." as QsServices

Singleton {
    id: root

    readonly property list<AccessPoint> networks: []
    readonly property AccessPoint active: networks.find(n => n.active) ?? null
    property bool wifiEnabled: true
    readonly property bool scanning: rescanProc.running
    
    // Convenience properties for Control Center
    readonly property bool connected: active !== null
    readonly property string ssid: active?.ssid ?? "Not Connected"
    readonly property int signalStrength: active?.signalStrength ?? 0
    
    property var savedNetworks: []
    
    // Consumer visibility control - set to false to pause polling when UI is hidden
    property bool pollingActive: true

    function enableWifi(enabled: bool): void {
        const cmd = enabled ? "on" : "off";
        enableWifiProc.exec(["nmcli", "radio", "wifi", cmd]);
    }

    function toggleWifi(): void {
        const cmd = wifiEnabled ? "off" : "on";
        enableWifiProc.exec(["nmcli", "radio", "wifi", cmd]);
    }

    function rescanWifi(): void {
        rescanProc.running = true;
    }

    function connectToNetwork(ssid: string, password: string): void {
        // Validate SSID to prevent command injection
        if (!ssid || ssid.trim().length === 0) {
            QsServices.Logger.warn("Network", "Invalid SSID: empty")
            return
        }
        
        // Check for dangerous characters that could be used for injection
        const dangerousChars = [";", "`", "$", "|", "&", "\n", "\r", "\\"]
        for (let i = 0; i < dangerousChars.length; i++) {
            if (ssid.includes(dangerousChars[i])) {
                QsServices.Logger.warn("Network", "Invalid SSID: contains dangerous character")
                return
            }
        }
        
        QsServices.Logger.info("Network", `Connecting to: ${ssid} ${password.length > 0 ? "(with password)" : "(saved)"}`)
        
        if (password && password.length > 0) {
            // Connect to new network with password
            connectProc.exec(["nmcli", "dev", "wifi", "connect", ssid, "password", password]);
        } else {
            // Connect to saved network using connection name (which is usually the SSID)
            connectProc.exec(["nmcli", "connection", "up", "id", ssid]);
        }
    }
    
    function isNetworkSaved(ssid: string): bool {
        checkSavedProc.exec(["nmcli", "-g", "NAME", "connection", "show"]);
        return savedNetworks.includes(ssid);
    }

    function disconnectFromNetwork(): void {
        if (active) {
            disconnectProc.exec(["nmcli", "connection", "down", active.ssid]);
        }
    }

    function getWifiStatus(): void {
        wifiStatusProc.running = true;
    }

    Process {
        running: true
        command: ["nmcli", "m"]
        stdout: SplitParser {
            onRead: getNetworks.running = true
        }
    }

    Process {
        id: wifiStatusProc

        running: true
        command: ["nmcli", "radio", "wifi"]
        environment: ({
                LANG: "C.UTF-8",
                LC_ALL: "C.UTF-8"
            })
        stdout: StdioCollector {
            onStreamFinished: {
                root.wifiEnabled = text.trim() === "enabled";
            }
        }
    }

    Process {
        id: enableWifiProc

        onExited: {
            root.getWifiStatus();
            getNetworks.running = true;
        }
    }

    Process {
        id: rescanProc

        command: ["nmcli", "dev", "wifi", "list", "--rescan", "yes"]
        onExited: {
            getNetworks.running = true;
        }
    }

    Process {
        id: connectProc

        stdout: SplitParser {
            onRead: data => {
                QsServices.Logger.debug("Network", `Connection output: ${data}`)
                getNetworks.running = true
            }
        }
        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0) {
                    QsServices.Logger.warn("Network", `Connection error: ${text.trim()}`)
                }
            }
        }
        onExited: (code, status) => {
            QsServices.Logger.debug("Network", `Connection exited code=${code} status=${status}`)
            getNetworks.running = true
        }
    }

    Process {
        id: disconnectProc

        stdout: SplitParser {
            onRead: getNetworks.running = true
        }
    }
    
    Process {
        id: checkSavedProc
        
        command: ["nmcli", "-g", "NAME", "connection", "show"]
        environment: ({
                LANG: "C.UTF-8",
                LC_ALL: "C.UTF-8"
            })
        stdout: StdioCollector {
            onStreamFinished: {
                root.savedNetworks = text.trim().split('\n').filter(n => n.length > 0);
                // Keep logs quiet during periodic refresh; only emit on actual changes.
                const current = root.savedNetworks
                const prev = root._prevSavedNetworks
                let changed = current.length !== prev.length
                if (!changed) {
                    for (let i = 0; i < current.length; i++) {
                        if (current[i] !== prev[i]) {
                            changed = true
                            break
                        }
                    }
                }
                if (changed) {
                    root._prevSavedNetworks = current.slice(0)
                    QsServices.Logger.debug("Network", `Saved networks: ${root.savedNetworks.length}`)
                }
            }
        }
    }

    property var _prevSavedNetworks: []
    
    Component.onCompleted: {
        checkSavedProc.running = true // Load saved networks on start
    }
    
    Timer {
        interval: 10000 // Update saved networks every 10 seconds
        running: root.pollingActive  // Pause when no consumer is visible
        repeat: true
        onTriggered: checkSavedProc.running = true
    }

    Process {
        id: getNetworks

        running: true
        command: ["nmcli", "-g", "ACTIVE,SIGNAL,FREQ,SSID,BSSID,SECURITY", "d", "w"]
        environment: ({
                LANG: "C.UTF-8",
                LC_ALL: "C.UTF-8"
            })
        stdout: StdioCollector {
            onStreamFinished: {
                const PLACEHOLDER = "STRINGWHICHHOPEFULLYWONTBEUSED";
                const rep = new RegExp("\\\\:", "g");
                const rep2 = new RegExp(PLACEHOLDER, "g");

                const allNetworks = text.trim().split("\n").map(n => {
                    const net = n.replace(rep, PLACEHOLDER).split(":");
                    return {
                        active: net[0] === "yes",
                        strength: parseInt(net[1]),
                        frequency: parseInt(net[2]),
                        ssid: net[3]?.replace(rep2, ":") ?? "",
                        bssid: net[4]?.replace(rep2, ":") ?? "",
                        security: net[5] ?? ""
                    };
                }).filter(n => n.ssid && n.ssid.length > 0);

                // Group networks by SSID and prioritize connected ones
                const networkMap = new Map();
                for (const network of allNetworks) {
                    const existing = networkMap.get(network.ssid);
                    if (!existing) {
                        networkMap.set(network.ssid, network);
                    } else {
                        // Prioritize active/connected networks
                        if (network.active && !existing.active) {
                            networkMap.set(network.ssid, network);
                        } else if (!network.active && !existing.active) {
                            // If both are inactive, keep the one with better signal
                            if (network.strength > existing.strength) {
                                networkMap.set(network.ssid, network);
                            }
                        }
                        // If existing is active and new is not, keep existing
                    }
                }

                const networks = Array.from(networkMap.values());

                const rNetworks = root.networks;

                const destroyed = rNetworks.filter(rn => !networks.find(n => n.frequency === rn.frequency && n.ssid === rn.ssid && n.bssid === rn.bssid));
                for (const network of destroyed)
                    rNetworks.splice(rNetworks.indexOf(network), 1).forEach(n => n.destroy());

                for (const network of networks) {
                    const match = rNetworks.find(n => n.frequency === network.frequency && n.ssid === network.ssid && n.bssid === network.bssid);
                    if (match) {
                        match.lastIpcObject = network;
                    } else {
                        rNetworks.push(apComp.createObject(root, {
                            lastIpcObject: network
                        }));
                    }
                }
            }
        }
    }

    component AccessPoint: QtObject {
        required property var lastIpcObject
        readonly property string ssid: lastIpcObject.ssid
        readonly property string bssid: lastIpcObject.bssid
        readonly property int strength: lastIpcObject.strength
        readonly property int frequency: lastIpcObject.frequency
        readonly property bool active: lastIpcObject.active
        readonly property string security: lastIpcObject.security
        readonly property bool isSecure: security.length > 0
    }

    Component {
        id: apComp

        AccessPoint {}
    }
}
