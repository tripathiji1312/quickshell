//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QSG_RENDER_LOOP=threaded
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000

import Quickshell
import Quickshell.Services.Notifications
import QtQuick 6.10
import "services" as QsServices
import "config" as QsConfig
import "modules/osd"
import "modules"

ShellRoot {
    id: root
    
    // Initialize services immediately
    readonly property var notifs: QsServices.Notifs
    readonly property var pywal: QsServices.Pywal
    readonly property var audio: QsServices.Audio
    readonly property var brightness: QsServices.Brightness
    
    // Only register as a notification daemon if explicitly enabled.
    // This avoids noisy warnings when another daemon is active.
    Loader {
        active: QsConfig.Config.notifications.registerServer
        sourceComponent: NotificationServer {
            keepOnReload: false
            actionsSupported: true
            bodyHyperlinksSupported: true
            bodyMarkupSupported: true
            imageSupported: true
            persistenceSupported: true

            onNotification: notif => {
                notif.tracked = true
                QsServices.Logger.debug("Notifs", `Received: ${notif.appName ?? ""} ${notif.summary ?? ""}`)
                notifs.addNotification(notif)
            }
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

    BatteryMonitor {}

    Component.onCompleted: {
        QsServices.Logger.info("Shell", "Loaded")
    }
}
