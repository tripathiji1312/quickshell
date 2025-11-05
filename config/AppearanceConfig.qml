import QtQuick 6.10

QtObject {
    readonly property var rounding: QtObject {
        property int small: 4
        property int medium: 8
        property int large: 12
        property int full: 9999
    }

    readonly property var spacing: QtObject {
        property int tiny: 2
        property int small: 4
        property int medium: 8
        property int large: 12
        property int huge: 16
    }

    readonly property var padding: QtObject {
        property int tiny: 2
        property int small: 4
        property int medium: 8
        property int large: 12
        property int huge: 16
    }

    readonly property var font: QtObject {
        property string family: "Inter"
        property int small: 10
        property int medium: 12
        property int large: 14
        property int huge: 16
    }

    readonly property var anim: QtObject {
        readonly property var durations: QtObject {
            property int instant: 0
            property int fast: 150
            property int normal: 200
            property int medium: 250
            property int slow: 350
            property int slower: 500
        }

        readonly property var curves: QtObject {
            // Standard Material Design easing curves
            property var standard: [0.2, 0.0, 0, 1.0]
            property var standardDecel: [0.0, 0.0, 0, 1.0]
            property var standardAccel: [0.3, 0.0, 1, 1.0]
            property var emphasizedDecel: [0.05, 0.7, 0.1, 1.0]
            property var emphasizedAccel: [0.3, 0.0, 0.8, 0.15]
        }
        
        readonly property var easing: QtObject {
            property int standard: Easing.OutCubic
            property int emphasized: Easing.OutBack
            property int sharp: Easing.InOutQuad
            property int smooth: Easing.InOutCubic
        }
    }

    readonly property var transparency: QtObject {
        property real full: 1.0
        property real high: 0.87
        property real medium: 0.60
        property real low: 0.38
        property real minimal: 0.12
    }
}
