pragma Singleton

import QtQuick 6.10
import Quickshell
import Quickshell.Services.Notifications
import "." as QsServices

Singleton {
    id: root

    // Use a JS array so Array helpers (filter/slice/etc) work reliably.
    property var notifications: []
    readonly property var activeNotifications: notifications.filter(n => !!n && !n.closed)
    
    // Maximum notifications to keep in memory (lowercase to comply with QML naming rules)
    readonly property int maxNotifications: 100
    
    // Show all notifications from past 24 hours (including closed ones) - for notification center
    readonly property var recentNotifications: notifications.filter(n => {
        if (!n || !n.timestamp)
            return false
        const hoursSinceNotif = (new Date().getTime() - n.timestamp.getTime()) / (1000 * 60 * 60)
        return hoursSinceNotif < 24
    }).sort((a, b) => b.timestamp.getTime() - a.timestamp.getTime())
    
    // Group notifications by app for better UX
    readonly property var groupedNotifications: {
        const groups = {}
        const active = activeNotifications
        for (let i = 0; i < active.length; i++) {
            const n = active[i]
            const key = n.appName || "Unknown"
            if (!groups[key]) {
                groups[key] = []
            }
            groups[key].push(n)
        }
        return groups
    }
    
    // Get notification counts per app
    readonly property var notificationCounts: {
        const counts = {}
        const grouped = groupedNotifications
        for (let app in grouped) {
            counts[app] = grouped[app].length
        }
        return counts
    }
    
    property bool dnd: false
    
    // Cleanup timer to prevent memory leaks
    Timer {
        interval: 3600000  // Clean up every hour
        repeat: true
        running: true
        triggeredOnStart: false
        
        onTriggered: {
            const oneDayAgo = new Date().getTime() - (24 * 60 * 60 * 1000)
            const oldCount = root.notifications.length
            root.notifications = root.notifications.filter(n => n && n.timestamp && n.timestamp.getTime() > oneDayAgo)
            const cleaned = oldCount - root.notifications.length
            if (cleaned > 0) {
                QsServices.Logger.debug("Notifs", `Cleaned up ${cleaned} old notifications`)
            }
        }
    }
    
    // Add notification from external NotificationServer
    function addNotification(notif) {
        // Check DND mode
        if (dnd && notif.urgency !== NotificationUrgency.Critical) {
            QsServices.Logger.debug("Notifs", `DND active - suppressing: ${notif.summary}`)
            return;
        }

        QsServices.Logger.debug("Notifs", `Adding notification: ${notif.summary}`)
        
        const notifWrapper = notifComponent.createObject(root, {
            notification: notif
        })

        if (!notifWrapper) {
            QsServices.Logger.error("Notifs", "Failed to create notification wrapper")
            return
        }
        
        // Cap maximum notifications to prevent memory leaks
        root.notifications = [notifWrapper, ...root.notifications].slice(0, root.maxNotifications)
        QsServices.Logger.debug("Notifs", `Total notifications: ${root.notifications.length}`)
        QsServices.Logger.debug("Notifs", `Queued: ${notifWrapper.appName ?? ""} ${notifWrapper.summary ?? ""}`)
    }

    function _actionsToArray(actionList) {
        const out = []
        if (!actionList)
            return out

        const len = actionList.length ?? 0
        for (let i = 0; i < len; i++) {
            const a = actionList[i]
            if (!a)
                continue
            out.push({
                identifier: a.identifier,
                text: a.text,
                invoke: () => a.invoke()
            })
        }
        return out
    }
    
    // Toggle DND mode
    function toggleDnd() {
        dnd = !dnd;
        QsServices.Logger.info("Notifs", `DND mode: ${dnd ? "enabled" : "disabled"}`)
    }
    
    // Clear all notifications
    function clearAll() {
        notifications.forEach(n => n.close());
        QsServices.Logger.info("Notifs", "All notifications cleared")
    }
    
    // Clear notifications from specific app
    function clearApp(appName) {
        notifications.filter(n => n.appName === appName).forEach(n => n.close());
        QsServices.Logger.info("Notifs", `Cleared notifications from: ${appName}`)
    }

    // Notification wrapper component
    component Notif: QtObject {
        id: notifWrapper
        
        property var notification
        property date timestamp: new Date()
        property bool closed: false
        property bool hasAnimated: false  // Track if popup animation has played
        
        // Notification properties
        property string notifId: ""
        property string summary: ""
        property string body: ""
        property string appName: ""
        property string appIcon: ""
        property string image: ""
        property int urgency: NotificationUrgency.Normal
        // Use a JS array so `.length`/indexing and helpers work reliably.
        property var actions: []
        
        // Time formatting
        readonly property string timeString: {
            const diff = new Date().getTime() - timestamp.getTime();
            const minutes = Math.floor(diff / 60000);
            const hours = Math.floor(minutes / 60);
            const days = Math.floor(hours / 24);
            
            if (days > 0) return days + "d ago";
            if (hours > 0) return hours + "h ago";
            if (minutes > 0) return minutes + "m ago";
            return "Just now";
        }
        
        // Connections to notification object
        readonly property Connections conn: Connections {
            target: notifWrapper.notification
            
            function onClosed() {
                notifWrapper.close();
            }
            
            function onSummaryChanged() {
                notifWrapper.summary = notifWrapper.notification.summary;
            }
            
            function onBodyChanged() {
                notifWrapper.body = notifWrapper.notification.body;
            }
            
            function onAppNameChanged() {
                notifWrapper.appName = notifWrapper.notification.appName;
            }
            
            function onAppIconChanged() {
                notifWrapper.appIcon = notifWrapper.notification.appIcon;
            }
            
            function onImageChanged() {
                notifWrapper.image = notifWrapper.notification.image;
            }
            
            function onUrgencyChanged() {
                notifWrapper.urgency = notifWrapper.notification.urgency;
            }
            
            function onActionsChanged() {
                notifWrapper.actions = root._actionsToArray(notifWrapper.notification.actions)
            }
        }
        
        function close() {
            if (closed) return;
            
            // Mark as closed but keep in history for notification center
            closed = true;
            
            // Only dismiss from the notification daemon, don't remove from list
            if (notification) {
                notification.dismiss();
            }

            QsServices.Logger.debug("Notifs", `Notification closed (kept in history): ${summary}`)
        }
        
        function invokeAction(actionId) {
            const action = actions.find(a => a.identifier === actionId);
            if (action && action.invoke) {
                action.invoke();
            }
        }
        
        Component.onCompleted: {
            if (!notification)
                return;
            
            notifId = `${notification.id}`
            summary = notification.summary
            body = notification.body
            appName = notification.appName
            appIcon = notification.appIcon
            image = notification.image
            urgency = notification.urgency
            actions = root._actionsToArray(notification.actions)
        }
    }
    
    Component {
        id: notifComponent
        
        Notif {}
    }
    
    // Delete a specific notification (permanently remove from history)
    function deleteNotification(notif) {
        if (root.notifications.includes(notif)) {
            root.notifications = root.notifications.filter(n => n !== notif);
            if (notif.notification) {
                notif.notification.dismiss();
            }
            notif.destroy();
            QsServices.Logger.debug("Notifs", "Notification permanently deleted")
        }
    }
}
