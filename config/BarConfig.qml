import QtQuick 6.10

QtObject {
    readonly property var workspaces: QtObject {
        // Minimal workspace count
        property int count: 8
        
        // Clean, minimal indicators
        property bool showOccupiedIndicator: true
        property bool showActiveIndicator: true
        
        // Unified pill container style
        property bool unifiedPill: true              // NEW: All workspaces in one pill
        property int pillPadding: 6                  // Padding inside the unified pill
        
        // Smooth, subtle animations
        property bool enableClickAnimation: true
        property bool enableSwitchAnimation: true
        property int animationDuration: 180
        
        // Pywal-based colors (will be overridden by Pywal service)
        property string activeColor: "#BE5052"      // pywal color3 - muted red
        property string occupiedColor: "#9A847D"    // pywal color5 - muted brown
        property string emptyColor: "#a3a0a1"       // pywal color8 - muted gray
        property string activeTextColor: "#e9e5e6"  // pywal foreground
        property string inactiveTextColor: "#a3a0a1" // pywal color8
        property string backgroundColor: "#070605"   // pywal background
        property string pillBackgroundColor: "#0a0908" // Slightly lighter than pure background
        
        // Even smaller, ultra-minimal sizing
        property int workspaceSize: 20              // Smaller!
        property int spacing: 5                     // Tighter spacing
        property int cornerRadius: 10               // Fully rounded
        property int indicatorSize: 3               // Subtle indicator dot
    }
    
    readonly property int height: 32                // Even thinner bar
    readonly property int padding: 5                // Minimal padding
    readonly property real backgroundOpacity: 0.80  // More transparent
}
