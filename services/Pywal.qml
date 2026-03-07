pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick 6.10
import "../config" as QsConfig
import "." as QsServices

Singleton {
    id: root
    
    // Pywal color properties with defaults as proper colors
    property color background: "#070605"
    property color foreground: "#e9e5e6"
    property color cursor: "#e9e5e6"
    
    // Individual color properties for easy access
    property color color0: "#070605"
    property color color1: "#DE1222"
    property color color2: "#37B679"  // Green for connected states
    property color color3: "#FF9F00"  // Orange for warnings
    property color color4: "#CE6649"
    property color color5: "#9A847D"
    property color color6: "#B39FA7"
    property color color7: "#e9e5e6"
    property color color8: "#a3a0a1"
    property color color9: "#DE1222"
    property color color10: "#37B679"
    property color color11: "#BE5052"
    property color color12: "#CE6649"
    property color color13: "#9A847D"
    property color color14: "#B39FA7"
    property color color15: "#e9e5e6"
    
    // === Semantic Color Tokens ===
    // Use these instead of hardcoded colors for consistency
    
    // Primary accent color (derived from pywal)
    readonly property color primary: color4
    readonly property color primaryContainer: Qt.rgba(color4.r, color4.g, color4.b, 0.2)
    readonly property color onPrimary: foreground
    
    // Secondary accent
    readonly property color secondary: color5
    readonly property color secondaryContainer: Qt.rgba(color5.r, color5.g, color5.b, 0.2)
    
    // Tertiary accent
    readonly property color tertiary: color6
    readonly property color tertiaryContainer: Qt.rgba(color6.r, color6.g, color6.b, 0.2)
    
    // Surface colors (for cards, popups, containers)
    readonly property color surface: background
    readonly property color surfaceDim: Qt.darker(background, 1.1)
    readonly property color surfaceBright: Qt.lighter(background, 1.3)
    readonly property color surfaceContainer: Qt.lighter(background, 1.15)
    readonly property color surfaceContainerLow: Qt.lighter(background, 1.08)
    readonly property color surfaceContainerHigh: Qt.lighter(background, 1.22)
    readonly property color surfaceContainerHighest: Qt.lighter(background, 1.3)
    readonly property color onSurface: foreground
    readonly property color onSurfaceVariant: color8
    
    // Outline colors
    readonly property color outline: color8
    readonly property color outlineVariant: Qt.rgba(color8.r, color8.g, color8.b, 0.5)
    
    // State colors
    readonly property color success: color2      // Green
    readonly property color onSuccess: background
    readonly property color warning: color3      // Orange
    readonly property color onWarning: background
    readonly property color error: color1        // Red
    readonly property color onError: foreground
    readonly property color info: color4         // Blue-ish accent
    
    // Interactive state overlays
    readonly property color stateLayerLight: Qt.rgba(foreground.r, foreground.g, foreground.b, 1)
    readonly property color stateLayerDark: Qt.rgba(background.r, background.g, background.b, 1)
    
    // Inverse colors (for contrast situations)
    readonly property color inverseSurface: foreground
    readonly property color inverseOnSurface: background
    readonly property color inversePrimary: Qt.lighter(primary, 1.5)
    
    // Scrim (overlay for modals)
    readonly property color scrim: Qt.rgba(0, 0, 0, 0.5)
    
    // Shadow color
    readonly property color shadow: Qt.rgba(0, 0, 0, 0.3)
    
    function loadColors(text: string): void {
        try {
            const data = JSON.parse(text);
            if (data.special) {
                root.background = data.special.background || root.background;
                root.foreground = data.special.foreground || root.foreground;
                root.cursor = data.special.cursor || root.cursor;
            }
            if (data.colors) {
                // Load individual colors
                if (data.colors.color0) root.color0 = data.colors.color0;
                if (data.colors.color1) root.color1 = data.colors.color1;
                if (data.colors.color2) root.color2 = data.colors.color2;
                if (data.colors.color3) root.color3 = data.colors.color3;
                if (data.colors.color4) root.color4 = data.colors.color4;
                if (data.colors.color5) root.color5 = data.colors.color5;
                if (data.colors.color6) root.color6 = data.colors.color6;
                if (data.colors.color7) root.color7 = data.colors.color7;
                if (data.colors.color8) root.color8 = data.colors.color8;
                if (data.colors.color9) root.color9 = data.colors.color9;
                if (data.colors.color10) root.color10 = data.colors.color10;
                if (data.colors.color11) root.color11 = data.colors.color11;
                if (data.colors.color12) root.color12 = data.colors.color12;
                if (data.colors.color13) root.color13 = data.colors.color13;
                if (data.colors.color14) root.color14 = data.colors.color14;
                if (data.colors.color15) root.color15 = data.colors.color15;
            }
            QsServices.Logger.debug("Pywal", "colors.json loaded")
        } catch (e) {
            QsServices.Logger.error("Pywal", "Failed to parse colors.json", e?.message ?? e)
        }
    }
    
    // Load colors from pywal cache
    FileView {
        id: pywalFile
        path: QsConfig.Config.paths.pywalColors
        watchChanges: true
        onLoaded: root.loadColors(text())
        onFileChanged: root.loadColors(text())
        onLoadFailed: err => QsServices.Logger.warn("Pywal", `colors.json not loaded: ${FileViewError.toString(err)}`)
    }
}
