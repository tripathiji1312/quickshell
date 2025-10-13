#!/bin/bash
echo "═══════════════════════════════════════"
echo "  QuickShell Notification System Setup"
echo "═══════════════════════════════════════"
echo ""

# Kill dunst
echo "1. Stopping dunst..."
killall dunst 2>/dev/null
sleep 0.5
echo "   ✅ Done"

# Restart QuickShell
echo "2. Restarting QuickShell..."
killall quickshell 2>/dev/null
sleep 1

cd ~/.config/quickshell
quickshell --config shell.qml 2>&1 | grep -E "(QuickShell loaded|NotificationServer|Notification service)" &
QSPID=$!
sleep 3

if pgrep quickshell > /dev/null; then
    echo "   ✅ QuickShell started"
else
    echo "   ❌ QuickShell failed to start"
    exit 1
fi

# Test notification
echo "3. Testing notification..."
sleep 1
notify-send "QuickShell Test" "If you see this, notifications work!" &
NOTIF_PID=$!
sleep 2

if ps -p $NOTIF_PID > /dev/null 2>&1; then
    echo "   ❌ notify-send hanging (no server)"
    kill $NOTIF_PID 2>/dev/null
else
    echo "   ✅ Notification sent successfully!"
fi

echo ""
echo "════════════════════════════════════════"
echo "  Check: Control Center → Notifications"
echo "════════════════════════════════════════"
