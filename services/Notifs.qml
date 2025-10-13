pragma Singleton

import QtQuick 6.10
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    property list<Notif> notifications: []
    readonly property var activeNotifications: notifications.filter(n => !n.closed)
    
    // Show all notifications from past 24 hours (including closed ones)
    readonly property var recentNotifications: notifications.filter(n => {
        const hoursSinceNotif = (new Date().getTime() - n.timestamp.getTime()) / (1000 * 60 * 60);
        return hoursSinceNotif < 24;
    })
    
    property bool dnd: false
    
    // Add notification from external NotificationServer
    function addNotification(notif) {
        console.log("📬 [Notifs Service] Adding notification:", notif.summary);
        
        const notifWrapper = notifComponent.createObject(root, {
            notification: notif
        });
        
        root.notifications = [notifWrapper, ...root.notifications];
        console.log("📋 Total notifications:", root.notifications.length);
    }

    // Notification wrapper component
    component Notif: QtObject {
        id: notifWrapper
        
        property var notification
        property date timestamp: new Date()
        property bool closed: false
        property bool hasAnimated: false  // Track if popup animation has played
        
        // Notification properties
        property string id: ""
        property string summary: ""
        property string body: ""
        property string appName: ""
        property string appIcon: ""
        property string image: ""
        property int urgency: 0
        property list<var> actions: []
        
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
                notifWrapper.actions = notifWrapper.notification.actions.map(a => ({
                    identifier: a.identifier,
                    text: a.text,
                    invoke: () => a.invoke()
                }));
            }
        }
        
        function close() {
            closed = true;
            if (root.notifications.includes(this)) {
                root.notifications = root.notifications.filter(n => n !== this);
                if (notification) {
                    notification.dismiss();
                }
                destroy();
            }
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
            
            id = notification.id;
            summary = notification.summary;
            body = notification.body;
            appName = notification.appName;
            appIcon = notification.appIcon;
            image = notification.image;
            urgency = notification.urgency;
            actions = notification.actions.map(a => ({
                identifier: a.identifier,
                text: a.text,
                invoke: () => a.invoke()
            }));
        }
    }
    
    Component {
        id: notifComponent
        
        Notif {}
    }
    
    // Clear all notifications
    function clearAll() {
        for (const notif of notifications.slice()) {
            notif.close();
        }
        notifications = [];
    }
    
    // Toggle DND
    function toggleDnd() {
        dnd = !dnd;
    }
}
