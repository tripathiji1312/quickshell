import QtQuick 6.10

QtObject {
    readonly property var workspaces: QtObject {
        // Workspace count
        property int count: 8
        
        // Modern indicator style
        property bool showOccupiedIndicator: true
        property bool showActiveIndicator: true
        
        // Unified island style (deprecated - now built into Bar.qml)
        property bool unifiedPill: true
        property int pillPadding: 8
        
        // Smooth animations
        property bool enableClickAnimation: true
        property bool enableSwitchAnimation: true
        property int animationDuration: 200
        
        // Pywal-based colors
        property string activeColor: "#BE5052"
        property string occupiedColor: "#9A847D"
        property string emptyColor: "#a3a0a1"
        property string activeTextColor: "#e9e5e6"
        property string inactiveTextColor: "#a3a0a1"
        property string backgroundColor: "#070605"
        property string pillBackgroundColor: "#0a0908"
        
        // Modern sizing
        property int workspaceSize: 18
        property int spacing: 6
        property int cornerRadius: 10
        property int indicatorSize: 4
    }
    
    // Floating island bar design
    readonly property int height: 36                // Compact floating islands
    readonly property int padding: 4               // Tight padding around content
    readonly property real backgroundOpacity: 0.0  // Fully transparent (islands handle their own background)
    
    // Island styling
    readonly property var islands: QtObject {
        property int borderRadius: 18              // Smaller pill radius
        property real surfaceOpacity: 1.0           // Solid surface
        property real borderOpacity: 0.12          // Subtle border glow
        property int spacing: 6                    // Tighter gap between elements
    }
}
