# QuickShell Notifications - Complete Modern Redesign

## ✨ What's New

### Modern Notification Design
- **Glassmorphic cards** - Semi-transparent with subtle borders
- **Smooth animations** - 400ms slide-in with OutCubic easing
- **Smart auto-dismiss** - 7 seconds with smooth fade-out
- **Urgent accent** - Red left border for critical notifications
- **Compact layout** - Shows up to 3 notifications at once
- **Individual removal** - Each card animates out independently

### Functional Improvements
- ✅ **Clickable actions** - Action buttons that invoke and dismiss
- ✅ **Close button** - Smooth hover effect with cursor pointer
- ✅ **Timestamp display** - Shows relative time ("now", "5m ago")
- ✅ **Image support** - Rounded images with 90px height
- ✅ **No reload issues** - Fixed the popup recreation problem

### Visual Polish
- **Typography** - Inter font, proper line heights
- **Spacing** - 14px padding, 6px element spacing
- **Colors** - Pywal integrated, 92% background opacity
- **Icons** - App icons with brightness/saturation effects
- **Hover states** - Subtle 5% white overlay

## 🔧 Hyprland Integration

### The Popup Animation Issue
Hyprland's default layer shell animations can conflict with QuickShell's internal animations, causing:
- Double animations
- Flickering
- Stuttering transitions

### Solution

Add to your `~/.config/hypr/hyprland.conf`:

```conf
# Smooth layer animations
animation = layersIn, 1, 4, default, popin 80%
animation = layersOut, 1, 3, default, popin 80%

# QuickShell layer rules
layerrule = animation popin, ^(quickshell.*)$
layerrule = blur, ^(quickshell.*)$
layerrule = ignorealpha 0.3, ^(quickshell.*)$
```

Or if you prefer no Hyprland animations on notifications:

```conf
# Disable Hyprland animations for QuickShell notifications
layerrule = noanim, ^(quickshell.*)$
```

Then reload Hyprland:
```bash
hyprctl reload
```

## 🎨 Customization

### Adjust Auto-Dismiss Time
In `NotificationPopups.qml`, line ~76:
```qml
Timer {
    interval: 7000  // Change to 5000 for 5s, 10000 for 10s
    running: notifCard.isVisible
    onTriggered: {
        notifCard.isVisible = false
        Qt.callLater(() => modelData.close())
    }
}
```

### Change Max Visible Notifications
In `NotificationPopups.qml`, line ~15:
```qml
readonly property var activePopups: notifs.activeNotifications.slice(0, 3)
//                                                                      ^ Change to 5 for more
```

### Modify Card Appearance
```qml
// Background opacity (line ~49)
color: Qt.rgba(..., 0.92)  // 0.0 = transparent, 1.0 = solid

// Border (line ~56)
border.width: 1  // 0 = no border, 2 = thicker

// Radius (line ~41)
radius: 10  // Higher = more rounded

// Urgent accent (line ~63)
width: 3  // Thickness of red bar
```

### Position Adjustment
```qml
// Top-right margins (line ~21-24)
margins {
    top: 60   // Distance from top
    right: 16 // Distance from right
}
```

## 🧪 Testing

### Send Test Notifications
```bash
# Simple
notify-send "Test" "Hello QuickShell!"

# With icon
notify-send -i firefox "Firefox" "Browser notification"

# Critical (red accent)
notify-send -u critical "Alert!" "Important message"

# With action buttons (if supported)
notify-send "Action Test" "Click the button" \
  --action="open=Open" --action="dismiss=Dismiss"

# Multiple notifications
for i in {1..5}; do
  notify-send "Notification $i" "Testing multiple popups"
  sleep 0.5
done
```

### Debug Console Output
Watch QuickShell logs:
```bash
tail -f /run/user/$UID/quickshell/by-id/*/log.qslog | grep "📬\|🔔"
```

You should see:
- `🔔 NotificationServer registered on D-Bus`
- `📬 [ShellRoot] Notification received: ...`
- `📋 Total notifications: X`

## 📋 Features Summary

| Feature | Status | Notes |
|---------|--------|-------|
| Popup display | ✅ | Top-right corner |
| Smooth animations | ✅ | 400ms slide-in |
| Auto-dismiss | ✅ | 7 seconds |
| Manual close | ✅ | Click X button |
| Action buttons | ✅ | Click to invoke |
| Images | ✅ | 90px rounded |
| Urgent styling | ✅ | Red accent bar |
| Timestamps | ✅ | Relative time |
| No reload bug | ✅ | Fixed! |
| Hyprland compat | ✅ | Use config |

## 🐛 Troubleshooting

### Popups Don't Show
1. Check dunst is not running: `killall dunst`
2. Verify QuickShell is notification server:
   ```bash
   dbus-send --print-reply --dest=org.freedesktop.Notifications \
     /org/freedesktop/Notifications \
     org.freedesktop.Notifications.GetServerInformation
   ```
3. Check logs for `🔔 NotificationServer registered`

### Animations Stutter
- Add Hyprland layerrule: `layerrule = noanim, ^(quickshell.*)$`
- Or reduce animation duration in NotificationPopups.qml

### Cards Stack Weirdly
- Reduce max notifications: `slice(0, 2)` instead of `slice(0, 3)`
- Increase spacing: `spacing: 16` instead of `spacing: 12`

### Text Too Small/Large
Adjust font sizes in NotificationPopups.qml:
- App name: `font.pixelSize: 11`
- Summary: `font.pixelSize: 14`
- Body: `font.pixelSize: 12`

## 🎯 Next Steps

Your notifications are now:
- ✅ Modern and minimal
- ✅ Smoothly animated
- ✅ Fully functional
- ✅ Hyprland compatible

To further enhance:
1. Add blur effect (requires compositor support)
2. Implement grouping by app
3. Add notification history persistence
4. Create notification panel integration
5. Add sound effects

Enjoy your polished notification system! 🎉
