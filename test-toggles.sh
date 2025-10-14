#!/bin/bash
# Test DND and Caffeine toggles

echo "=== Testing Control Center Toggles ==="
echo ""

echo "1. Testing DND Toggle:"
echo "   - Open Control Center"
echo "   - Click DND button"
echo "   - Check console output for: '🔕 DND toggled'"
echo "   - Icon should change: 󰂚 → 󰂛"
echo ""

echo "2. Testing Caffeine Toggle:"
echo "   - Click Caffeine button"  
echo "   - Check console output for: '☕ Caffeine toggled'"
echo "   - Icon should change: 󰾪 → 󰅶"
echo ""

echo "3. Verify Caffeine is Working:"
echo "   - When ON, screen should NOT auto-sleep"
echo "   - Check with: systemctl --user status *inhibit* | grep -i quickshell"
echo ""

echo "4. Manual verification:"
pgrep -fa "systemd-inhibit.*QuickShell" && echo "   ✅ Caffeine process is running" || echo "   ❌ No caffeine process found"
echo ""

echo "=== Test Instructions ==="
echo "1. Open Control Center (click icon in top-right bar)"
echo "2. Try toggling DND and Caffeine"
echo "3. Watch terminal output for log messages"
echo ""

echo "To monitor in real-time:"
echo "  journalctl --user -f | grep -E '(DND|Caffeine|IdleInhibitor)'"
