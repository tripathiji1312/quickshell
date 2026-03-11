import QtQuick 6.10

QtObject {
    readonly property var rounding: QtObject {
        property int small: 8
        property int medium: 14
        property int large: 20
        property int extraLarge: 30
        property int full: 9999
    }

    // Standardized radius (Material 3)
    readonly property var radius: QtObject {
        property int xs: 6
        property int s: 10
        property int m: 16
        property int l: 22
        property int xl: 32
        property int full: 9999
    }

    readonly property var spacing: QtObject {
        property int tiny: 4
        property int small: 8
        property int medium: 12
        property int large: 16
        property int huge: 24
    }

    readonly property var margins: QtObject {
        property int xs: 6
        property int s: 10
        property int m: 14
        property int l: 20
        property int xl: 28
    }

    readonly property var padding: QtObject {
        property int tiny: 4
        property int small: 8
        property int medium: 12
        property int large: 16
        property int huge: 22
    }

    readonly property var font: QtObject {
        property string family: "Inter"
        property int small: 10
        property int medium: 12
        property int large: 14
        property int huge: 16
    }

    // Material 3 Typography Scale
    readonly property var typography: QtObject {
        property string family: "Inter"
        
        readonly property var displayLarge: QtObject { property int size: 57; property int weight: Font.Normal }
        readonly property var displayMedium: QtObject { property int size: 45; property int weight: Font.Normal }
        readonly property var displaySmall: QtObject { property int size: 36; property int weight: Font.Normal }
        
        readonly property var headlineLarge: QtObject { property int size: 32; property int weight: Font.Normal }
        readonly property var headlineMedium: QtObject { property int size: 28; property int weight: Font.Normal }
        readonly property var headlineSmall: QtObject { property int size: 24; property int weight: Font.Normal }
        
        readonly property var titleLarge: QtObject { property int size: 22; property int weight: Font.Normal }
        readonly property var titleMedium: QtObject { property int size: 16; property int weight: Font.Medium }
        readonly property var titleSmall: QtObject { property int size: 14; property int weight: Font.Medium }
        
        readonly property var labelLarge: QtObject { property int size: 14; property int weight: Font.Medium }
        readonly property var labelMedium: QtObject { property int size: 12; property int weight: Font.Medium }
        readonly property var labelSmall: QtObject { property int size: 11; property int weight: Font.Medium }
        
        readonly property var bodyLarge: QtObject { property int size: 16; property int weight: Font.Normal }
        readonly property var bodyMedium: QtObject { property int size: 14; property int weight: Font.Normal }
        readonly property var bodySmall: QtObject { property int size: 12; property int weight: Font.Normal }
    }

    readonly property var anim: QtObject {
        readonly property var durations: QtObject {
            property int instant: 0
            property int fast: 120
            property int normal: 180
            property int medium: 260
            property int slow: 340
            property int slower: 460
        }

        readonly property var curves: QtObject {
            property var standard: [0.2, 0.0, 0, 1.0]
            property var standardDecel: [0.0, 0.0, 0, 1.0]
            property var standardAccel: [0.3, 0.0, 1, 1.0]
            property var emphasizedDecel: [0.05, 0.7, 0.1, 1.0]
            property var emphasizedAccel: [0.3, 0.0, 0.8, 0.15]
            property var springGentle: [0.22, 1.0, 0.36, 1.0]
            property var springExpressive: [0.34, 1.56, 0.64, 1.0]
        }
        
        readonly property var easing: QtObject {
            property int standard: Easing.OutCubic
            property int emphasized: Easing.OutCubic
            property int sharp: Easing.InOutQuad
            property int smooth: Easing.InOutCubic
            property int spring: Easing.OutBack
        }
    }

    readonly property var transparency: QtObject {
        property real full: 1.0
        property real high: 0.92
        property real medium: 0.68
        property real low: 0.42
        property real minimal: 0.14
    }
}
