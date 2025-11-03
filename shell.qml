//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QSG_RENDER_LOOP=threaded
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000

import Quickshell
import Quickshell.Services.Notifications
import QtQuick 6.10
import "services" as QsServices
import "modules/osd"

ShellRoot {
    id: root
    
    // Initialize services immediately
    readonly property var notifs: QsServices.Notifs
    readonly property var pywal: QsServices.Pywal
    readonly property var audio: QsServices.Audio
    readonly property var brightness: QsServices.Brightness
    
    // Direct NotificationServer to ensure it starts
    NotificationServer {
        id: notificationServer
        
        keepOnReload: false
        actionsSupported: true
        bodyHyperlinksSupported: true
        bodyMarkupSupported: true
        imageSupported: true
        persistenceSupported: true
        
        onNotification: notif => {
            console.log("📬 [ShellRoot] Notification received:", notif.appName, notif.summary);
            notif.tracked = true;
            notifs.addNotification(notif);
        }
        
        Component.onCompleted: {
            console.log("🔔 NotificationServer registered on D-Bus");
        }
    }
    
    Loader {
        id: barLoader
        source: "modules/bar/BarWrapper.qml"
    }
    
    // Notification popups in top-right corner
    Loader {
        id: notificationPopupsLoader
        source: "modules/bar/components/NotificationPopups.qml"
    }
    
    // OSD overlays (volume and brightness)
    Wrapper {
        pywal: root.pywal
    }

    Component.onCompleted: {
        console.log("QuickShell loaded successfully!")
    }
}
