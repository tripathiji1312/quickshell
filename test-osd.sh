#!/bin/bash

echo "Killing QuickShell..."
killall quickshell
sleep 2

echo "Starting QuickShell..."
quickshell 2>&1 | grep -E "VolumeOSD|BrightnessOSD|Audio|Error|WARN" &

sleep 3
echo ""
echo "QuickShell started. Press volume keys and watch for log messages above."
echo "You should see: '🎵 [VolumeOSD] Component loaded' if OSD loaded successfully"
echo ""
echo "Press Ctrl+C to stop logging"
