//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QSG_RENDER_LOOP=threaded
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000

import Quickshell
import Quickshell.Services.Notifications
import QtQuick 6.10
import "services" as QsServices

ShellRoot {
    // Initialize services immediately
    readonly property var notifs: QsServices.Notifs
    readonly property var pywal: QsServices.Pywal
    
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
            // Filter out volume/brightness spam notifications
            const appName = notif.appName.toLowerCase();
            const summary = notif.summary.toLowerCase();
            
            // Skip notifications from volume/brightness tools - we have our own popups
            if (appName.includes("brightness") || 
                appName.includes("volume") ||
                appName.includes("brightnessctl") ||
                summary.includes("volume") ||
                summary.includes("brightness")) {
                console.log("🔇 [Filtered] Skipping OSD notification:", notif.appName, notif.summary);
                return;
            }
            
            console.log("📬 [ShellRoot] Notification received:", notif.summary);
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

    Component.onCompleted: {
        console.log("QuickShell loaded successfully!")
    }
}
