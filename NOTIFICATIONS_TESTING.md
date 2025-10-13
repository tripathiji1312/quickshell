# QuickShell Notifications - Testing Instructions

## ⚠️ IMPORTANT: Stop dunst first!

QuickShell needs to be the notification daemon. If dunst is running, it will intercept all notifications.

```bash
# Check if dunst is running
ps aux | grep dunst

# Stop dunst
killall dunst

# Prevent dunst from auto-starting (if using systemd)
systemctl --user stop dunst
systemctl --user disable dunst
```

## 🧪 Testing Notifications

Once dunst is stopped and QuickShell is running:

### Send Test Notifications

```bash
# Simple notification
notify-send "Hello" "This is a test notification"

# With icon
notify-send -i firefox "Firefox" "Browser notification"

# Critical (urgent)
notify-send -u critical "Alert!" "Important message"

# Multiple at once
notify-send "Message 1" "First notification"
notify-send "Message 2" "Second notification"
notify-send "Message 3" "Third notification"
```

### View Notifications

1. Open Control Center (button in your bar, top right)
2. Click the **Notifications** tab (󰂚 bell icon)
3. You should see all notifications listed

### Features to Test

- ✅ **DND Toggle** - Click bell icon to enable/disable
- ✅ **Clear All** - Click trash icon to clear all notifications
- ✅ **Individual Close** - Click X on each notification
- ✅ **Action Buttons** - If notification has actions, they appear as buttons
- ✅ **Timestamps** - Shows "Just now", "5m ago", "2h ago", etc.
- ✅ **Urgency Colors** - Critical notifications have red tint
- ✅ **Scrolling** - List scrolls if many notifications

## 🔧 Troubleshooting

### Notifications Not Appearing?

1. **Verify dunst is stopped:**
   ```bash
   pgrep dunst  # Should return nothing
   ```

2. **Check QuickShell is the notification server:**
   ```bash
   dbus-send --print-reply --dest=org.freedesktop.Notifications \
     /org/freedesktop/Notifications \
     org.freedesktop.Notifications.GetServerInformation
   ```
   Should return QuickShell as the server.

3. **Check QuickShell logs:**
   ```bash
   tail -f /run/user/$UID/quickshell/by-id/*/log.qslog
   ```
   Look for notification-related messages.

4. **Restart QuickShell:**
   ```bash
   killall quickshell
   quickshell --config ~/.config/quickshell/shell.qml
   ```

### Notifications Go to Old Handler?

If you see notifications in dunst/mako/another daemon:

```bash
# Kill all notification daemons
killall dunst mako swaync

# Restart QuickShell
killall quickshell
quickshell --config ~/.config/quickshell/shell.qml &

# Test again
notify-send "Test" "Should go to QuickShell now"
```

## 📝 Notes

- Notifications are stored in memory only (not persistent across restarts)
- DND mode prevents new notifications from appearing
- Images in notifications are supported (use `-i /path/to/image.png`)
- Action buttons work if the sending app provides them

## 🎯 Quick Test Command

```bash
# All-in-one test
killall dunst 2>/dev/null; \
notify-send "QuickShell" "Notification test 1" && \
sleep 1 && \
notify-send -u critical "Critical" "Urgent test" && \
sleep 1 && \
notify-send -i firefox "Firefox" "Browser test" && \
echo "✅ Check Control Center → Notifications tab"
```
