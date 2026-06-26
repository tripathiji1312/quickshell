import QtQuick 6.10
import QtQuick.Layouts 6.10
import QtQuick.Controls 6.10
import "../../../components/effects"

Item {
    id: root

    required property var audio
    property var pywal

    readonly property int currentVolume: audio.percentage
    readonly property bool isMuted: audio.muted

    readonly property color cSurface: pywal ? pywal.surfaceContainer : "#1a1a1a"
    readonly property color cOnSurface: pywal ? pywal.foreground : "#dddddd"
    readonly property color cPrimary: pywal ? pywal.primary : "#88cc88"

    Layout.fillWidth: true
    Layout.preferredHeight: 64

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 24
        spacing: 16

        // M3 Icon Button
        Rectangle {
            Layout.preferredWidth: 44; Layout.preferredHeight: 44; radius: 22
            color: muteMouse.pressed ? Qt.rgba(root.cOnSurface.r, root.cOnSurface.g, root.cOnSurface.b, 0.12) : muteMouse.containsMouse ? Qt.rgba(root.cOnSurface.r, root.cOnSurface.g, root.cOnSurface.b, 0.08) : "transparent"
            Behavior on color { ColorAnimation { duration: 150 } }
            scale: muteMouse.pressed ? 0.92 : 1.0
            Behavior on scale { NumberAnimation { duration: 100; easing.bezierCurve: Material3Anim.springGentle } }

            Text {
                anchors.centerIn: parent
                text: root.isMuted ? "󰝟" : (root.currentVolume > 66 ? "󰕾" : (root.currentVolume > 33 ? "󰖀" : "󰕿"))
                font.family: "Material Design Icons"; font.pixelSize: 24
                color: root.isMuted ? Qt.rgba(root.cOnSurface.r, root.cOnSurface.g, root.cOnSurface.b, 0.4) : root.cPrimary
                Behavior on color { ColorAnimation { duration: 150 } }
            }
            MouseArea { id: muteMouse; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; hoverEnabled: true; onClicked: root.audio.toggleMute() }
        }

        Slider {
            id: slider
            Layout.fillWidth: true; Layout.fillHeight: true
            from: 0; to: 100; value: root.currentVolume; live: true
            onMoved: root.audio.setVolume(value / 100)

            background: Rectangle {
                x: slider.leftPadding; y: slider.topPadding + slider.availableHeight / 2 - height / 2
                implicitWidth: 200; implicitHeight: 8
                width: slider.availableWidth; height: implicitHeight
                radius: 4
                color: Qt.rgba(root.cOnSurface.r, root.cOnSurface.g, root.cOnSurface.b, 0.1)

                Rectangle {
                    width: slider.visualPosition * parent.width; height: parent.height; radius: 4
                    color: root.isMuted ? Qt.rgba(root.cOnSurface.r, root.cOnSurface.g, root.cOnSurface.b, 0.3) : root.cPrimary
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
            }

            // M3 Expressive Morphing Handle
            handle: Rectangle {
                x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                y: slider.topPadding + slider.availableHeight / 2 - height / 2
                property real targetHeight: slider.pressed ? 32 : 20
                width: 20
                height: targetHeight
                radius: width / 2
                color: root.cPrimary

                Behavior on height { NumberAnimation { duration: 200; easing.bezierCurve: Material3Anim.emphasized } }
            }
        }

        Text {
            Layout.preferredWidth: 44
            text: root.currentVolume + "%"
            font.family: "Inter"; font.pixelSize: 15; font.weight: Font.Bold
            color: root.cOnSurface; horizontalAlignment: Text.AlignRight
        }
    }
}
