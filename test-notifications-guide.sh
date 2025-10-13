#!/bin/bash
# QuickShell Notification Testing Guide

echo "╔═══════════════════════════════════════════════════════╗"
echo "║    QuickShell Notifications - Setup & Test Guide     ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo ""

# Step 1: Stop dunst
echo "📋 Step 1: Stop dunst (if running)"
echo "─────────────────────────────────────"
if pgrep -x dunst > /dev/null; then
    echo "⚠️  dunst is running and will intercept notifications"
    echo "   Run: killall dunst"
    echo ""
    read -p "   Kill dunst now? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        killall dunst
        echo "✅ dunst stopped"
    else
        echo "❌ dunst still running - notifications won't work!"
        exit 1
    fi
else
    echo "✅ dunst is not running"
fi
echo ""

# Step 2: Check QuickShell is running
echo "📋 Step 2: Check QuickShell"
echo "─────────────────────────────────────"
if pgrep -x quickshell > /dev/null; then
    echo "✅ QuickShell is running"
else
    echo "❌ QuickShell is NOT running"
    echo "   Start it with: quickshell --config ~/.config/quickshell/shell.qml"
    exit 1
fi
echo ""

# Step 3: Send test notifications
echo "📋 Step 3: Sending Test Notifications"
echo "─────────────────────────────────────"
echo ""

echo "1️⃣  Simple notification..."
notify-send "QuickShell Test" "This is a simple test notification"
sleep 2

echo "2️⃣  Notification with icon..."
notify-send -i firefox "Firefox" "Browser notification test"
sleep 2

echo "3️⃣  Critical notification..."
notify-send -u critical "Critical Alert!" "This is an urgent notification"
sleep 2

echo "4️⃣  Notification with long body..."
notify-send "System Update" "A new system update is available. This notification has a longer body text to test how wrapping works in the notification panel."
sleep 2

echo "5️⃣  Multiple notifications..."
notify-send -i spotify "Spotify" "Now Playing: Test Song"
sleep 0.5
notify-send -i telegram "Telegram" "New message from Friend"
sleep 0.5
notify-send -i code "VS Code" "Extension installed"
sleep 2

echo ""
echo "╔═══════════════════════════════════════════════════════╗"
echo "║              How to View Notifications               ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo ""
echo "1. Click the Control Center button in your bar (top right)"
echo "2. Click the 'Notifications' tab (bell icon 󰂚)"
echo "3. You should see all the test notifications above"
echo ""
echo "╔═══════════════════════════════════════════════════════╗"
echo "║                 Features to Test                      ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo ""
echo "✨ DND Toggle:"
echo "   Click the bell icon (󰂚/󰂛) to toggle Do Not Disturb"
echo ""
echo "🗑️  Clear All:"
echo "   Click the trash icon (󰎟) to clear all notifications"
echo ""
echo "❌ Individual Close:"
echo "   Click the X on any notification to dismiss it"
echo ""
echo "⏰ Time Display:"
echo "   Check timestamps ('Just now', '5m ago', etc.)"
echo ""
echo "🎨 Visual Features:"
echo "   • Hover effects on notifications"
echo "   • Urgent notifications have red tint"
echo "   • Smooth scrolling if many notifications"
echo ""
echo "╔═══════════════════════════════════════════════════════╗"
echo "║              Manual Testing Commands                  ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo ""
echo "Send custom notification:"
echo "  notify-send 'Your Title' 'Your message'"
echo ""
echo "With icon:"
echo "  notify-send -i icon-name 'Title' 'Message'"
echo ""
echo "Critical urgency:"
echo "  notify-send -u critical 'Title' 'Message'"
echo ""
echo "Available icons to test:"
echo "  firefox, spotify, telegram, discord, code,"
echo "  mail, calendar, terminal, folder, image-viewer"
echo ""
echo "╔═══════════════════════════════════════════════════════╗"
echo "║                  Troubleshooting                      ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo ""
echo "If notifications don't appear:"
echo ""
echo "1. Check dunst is not running:"
echo "   ps aux | grep dunst"
echo "   killall dunst"
echo ""
echo "2. Check QuickShell logs:"
echo "   tail -f /run/user/\$UID/quickshell/by-id/*/log.qslog"
echo ""
echo "3. Test notification daemon is responding:"
echo "   dbus-send --print-reply --dest=org.freedesktop.Notifications \\"
echo "     /org/freedesktop/Notifications \\"
echo "     org.freedesktop.Notifications.GetServerInformation"
echo ""
echo "4. Restart QuickShell:"
echo "   killall quickshell"
echo "   quickshell --config ~/.config/quickshell/shell.qml"
echo ""
echo "✅ Testing complete!"
