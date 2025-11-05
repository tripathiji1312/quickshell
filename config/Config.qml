pragma Singleton

import Quickshell

Singleton {
    readonly property BarConfig bar: BarConfig {}
    readonly property AppearanceConfig appearance: AppearanceConfig {}
    
    // Control Center configuration
    readonly property var controlCenter: ({
        width: 700,
        maxHeight: 1000,
        padding: 16,
        spacing: 12,
        margin: 4,
        cornerRadius: 24
    })
    
    // Notification configuration
    readonly property var notifications: ({
        popupWidth: 340,
        maxVisible: 5,
        timeout: 7000,
        spacing: 8,
        margin: 8
    })
    
    // Popup configuration
    readonly property var popups: ({
        width: 280,
        minHeight: 100,
        maxHeight: 400,
        hoverDelay: 300,
        margin: 6
    })
}
