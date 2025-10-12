pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick 6.10

Singleton {
    id: root
    
    // Pywal color properties with defaults
    property string background: "#070605"
    property string foreground: "#e9e5e6"
    property string cursor: "#e9e5e6"
    
    property var colors: ({
        color0: "#070605",
        color1: "#DE1222",
        color2: "#F60B2A",
        color3: "#BE5052",
        color4: "#CE6649",
        color5: "#9A847D",
        color6: "#B39FA7",
        color7: "#e9e5e6",
        color8: "#a3a0a1",
        color9: "#DE1222",
        color10: "#F60B2A",
        color11: "#BE5052",
        color12: "#CE6649",
        color13: "#9A847D",
        color14: "#B39FA7",
        color15: "#e9e5e6"
    })
    
    function loadColors(text: string): void {
        try {
            const data = JSON.parse(text);
            if (data.special) {
                root.background = data.special.background || root.background;
                root.foreground = data.special.foreground || root.foreground;
                root.cursor = data.special.cursor || root.cursor;
            }
            if (data.colors) {
                root.colors = data.colors;
            }
            console.log("Pywal colors loaded successfully");
        } catch (e) {
            console.error("Failed to parse pywal colors:", e);
        }
    }
    
    // Load colors from pywal cache
    FileView {
        id: pywalFile
        path: "/home/tripathiji/.cache/wal/colors.json"
        watchChanges: true
        onLoaded: root.loadColors(text())
        onFileChanged: root.loadColors(text())
    }
}
