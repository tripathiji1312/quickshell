# 🧪 Notification Fixes - Testing Guide

## What Was Fixed

### 1. ✅ Position - Closer to Bar
- **Before**: `margins.top: 60`
- **After**: `margins.top: 8`
- **Effect**: Notifications now appear just below the bar

### 2. ✅ Expand from Top-Right Corner
- **Added**: `transformOrigin: Item.TopRight`
- **Added**: Scale animation from 0.8 → 1.0 with OutBack easing
- **Effect**: Notifications "pop out" from the corner with a subtle bounce

### 3. ✅ Stack New on Top
- **Already working**: `[notifWrapper, ...notifications]` prepends new to start
- **Verified**: `.slice(0, 3)` takes first 3 (newest)

### 4. ✅ Fixed Re-Animation Bug
- **Problem**: Every time a notification closed, all others re-animated
- **Root cause**: `Component.onCompleted` fired on every model change
- **Solution**: Added `hasAnimated` property to track animation state
- **Now**: Only animates once when notification is created

### 5. ✅ Reduced Size
- **Before**: `width: 380`
- **After**: `width: 340`
- **Effect**: Smaller, more compact cards

### 6. ✅ Reduced Spacing
- **Before**: `spacing: 12`
- **After**: `spacing: 6`
- **Effect**: Tighter stack, less gap between notifications

### 7. ✅ Filtered Volume/Brightness Spam
- **Problem**: Every 1% volume/brightness change created a notification
- **Solution**: Filter in NotificationServer's `onNotification` handler
- **Filters**: appName or summary containing "brightness", "volume", "brightnessctl"
- **Effect**: Only shows real notifications, not OSD updates

## 🧪 Test Cases

### Test 1: Position & Expand Animation
```bash
notify-send "Position Test" "Should appear close to bar and expand from corner"
```

**Expected**:
- Notification appears 8px below bar
- Scales from 0.8 to 1.0 with slight bounce
- Slides in 60px from right

### Test 2: No Re-Animation Bug
```bash
# Send 3 notifications
notify-send "Test 1" "First notification"
sleep 1
notify-send "Test 2" "Second notification"
sleep 1
notify-send "Test 3" "Third notification"

# Now close the middle one - others should NOT re-animate
```

**Expected**:
- First three notifications appear with animation
- When you close one, the others stay still (no re-animation)
- Only new notifications animate

### Test 3: Volume/Brightness Filtering
```bash
# These should be FILTERED (not appear as notifications)
notify-send -a "brightnessctl" "Brightness" "50%"
notify-send "Volume" "Volume at 75%"
notify-send "Brightness Control" "Set to 80%"

# This should appear normally
notify-send "Firefox" "Download complete"
```

**Expected**:
- First 3 notifications are filtered (check logs: "🔇 [Filtered]")
- Firefox notification appears normally

**Check logs**:
```bash
tail -f /run/user/$UID/quickshell/*/log.qslog | grep -E "Filtered|Notification received"
```

### Test 4: Stacking Order
```bash
# Send multiple notifications quickly
for i in {1..5}; do
  notify-send "Notification $i" "Sent at $(date +%H:%M:%S)"
  sleep 0.3
done
```

**Expected**:
- Shows max 3 notifications
- Notification 5 (newest) is on TOP
- Notification 3 is on BOTTOM
- Notifications 1 and 2 are hidden (only 3 shown at once)

### Test 5: Compact Size & Spacing
```bash
notify-send "Compact Test 1" "First card"
sleep 0.5
notify-send "Compact Test 2" "Second card"
sleep 0.5
notify-send "Compact Test 3" "Third card"
```

**Expected**:
- Each card is 340px wide (narrower than before)
- Only 6px gap between cards (tighter)
- Overall cleaner, more compact appearance

### Test 6: Auto-Dismiss Still Works
```bash
notify-send "Auto-Dismiss Test" "Should disappear after 7 seconds"
```

**Expected**:
- Notification appears with animation
- After 7 seconds, fades out smoothly
- No other notifications re-animate when it closes

## 🔍 Visual Checklist

When testing, verify:
- [ ] Notifications appear very close to top bar (8px gap)
- [ ] Each notification scales up from corner with bounce
- [ ] Closing one doesn't make others "jump" or re-animate
- [ ] Max 3 visible at once
- [ ] Newest notification is at the TOP of stack
- [ ] Cards are narrower (340px not 380px)
- [ ] Gap between cards is tight (6px not 12px)
- [ ] Volume/brightness changes don't spam notifications
- [ ] Real notifications still work perfectly

## 🐛 Debug Commands

### Check NotificationServer
```bash
dbus-send --print-reply --dest=org.freedesktop.Notifications \
  /org/freedesktop/Notifications \
  org.freedesktop.Notifications.GetServerInformation
```

### Monitor Filtered Notifications
```bash
tail -f /run/user/$UID/quickshell/*/log.qslog | grep "🔇"
```

### Monitor Received Notifications
```bash
tail -f /run/user/$UID/quickshell/*/log.qslog | grep "📬"
```

### Count Active Notifications
```bash
# Send this after your tests
notify-send "Debug" "Check console for notification count"
# Look for "📋 Total notifications: X" in logs
```

## 📊 Performance Notes

### Animation Performance
- **Expand**: 350ms OutBack (slight bounce)
- **Slide**: 350ms OutCubic (smooth deceleration)
- **Remove**: 200ms OutCubic (quick fade)
- **Running together**: Both animations start simultaneously for smooth effect

### Filter Performance
- Filtering happens BEFORE notification is added to list
- No memory wasted on volume/brightness spam
- Console shows "🔇 [Filtered]" for each blocked notification

## ✅ Success Criteria

All fixes working correctly when:
1. ✅ Notifications appear near top bar (8px margin)
2. ✅ Expand animation pops from corner with bounce
3. ✅ Closing notifications doesn't re-trigger animations
4. ✅ Newest notification shows on top of stack
5. ✅ Cards are compact (340px) with tight spacing (6px)
6. ✅ Volume/brightness changes don't create notifications
7. ✅ All animations are smooth and performant

## 🎉 Next Steps

Once all tests pass:
1. Restart QuickShell: `killall quickshell && quickshell &`
2. Use normally and verify no notification spam
3. Adjust `margins.top` in NotificationPopups.qml if needed
4. Adjust filter list if other apps spam notifications

Enjoy your polished notification system! 🚀
