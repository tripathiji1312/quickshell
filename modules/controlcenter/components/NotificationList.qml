import QtQuick 6.10
import QtQuick.Layouts 6.10
import Quickshell
import "../../../components"
import "../../../components/effects"

Item {
    id: root

    required property var notifs
    property var pywal

    readonly property color cSurfaceContainer: pywal ? pywal.surfaceContainer : "#111111"
    readonly property color cSurfaceContainerHigh: pywal ? pywal.surfaceContainerHigh : "#1a1a1a"
    readonly property color cOnSurface: pywal ? pywal.foreground : "#dddddd"
    readonly property color cOnSurfaceVariant: pywal ? pywal.onSurfaceMuted : "#999999"
    readonly property color cPrimary: pywal ? pywal.primary : "#88cc88"

    Layout.fillWidth: true
    Layout.fillHeight: true

    Rectangle {
        anchors.fill: parent
        radius: 28
        color: root.cSurfaceContainer

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                Text { text: "Notifications"; font.family: "Inter"; font.pixelSize: 16; font.weight: Font.Bold; color: root.cOnSurface }
                Item { Layout.fillWidth: true }

                Rectangle {
                    visible: (notifs.recentNotifications?.length ?? 0) > 0
                    width: clearAllText.implicitWidth + 24; height: 32; radius: 16
                    color: clearAllMouse.pressed ? Qt.rgba(root.cOnSurface.r, root.cOnSurface.g, root.cOnSurface.b, 0.12) : clearAllMouse.containsMouse ? Qt.rgba(root.cOnSurface.r, root.cOnSurface.g, root.cOnSurface.b, 0.08) : "transparent"
                    Behavior on color { ColorAnimation { duration: 150 } }
                    scale: clearAllMouse.pressed ? 0.95 : 1.0
                    Behavior on scale { NumberAnimation { duration: 100; easing.bezierCurve: Material3Anim.springGentle } }

                    Text { id: clearAllText; anchors.centerIn: parent; text: "Clear All"; font.family: "Inter"; font.pixelSize: 12; font.weight: Font.Medium; color: root.cOnSurfaceVariant }
                    MouseArea { id: clearAllMouse; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; hoverEnabled: true; onClicked: notifs.clearAll() }
                }
            }

            ListView {
                id: notifListView
                Layout.fillWidth: true; Layout.fillHeight: true
                clip: true; spacing: 8
                model: notifs.recentNotifications ?? []

                // M3 Spatial Entrance
                add: Transition {
                    NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 300; easing.bezierCurve: Material3Anim.emphasizedDecelerate }
                    NumberAnimation { property: "x"; from: 50; to: 0; duration: 300; easing.bezierCurve: Material3Anim.emphasizedDecelerate }
                }

                remove: Transition {
                    NumberAnimation { property: "opacity"; to: 0; duration: 150; easing.bezierCurve: Material3Anim.emphasizedAccelerate }
                    NumberAnimation { property: "x"; to: 50; duration: 150; easing.bezierCurve: Material3Anim.emphasizedAccelerate }
                }

                displaced: Transition {
                    NumberAnimation { properties: "x,y"; duration: 250; easing.bezierCurve: Material3Anim.standard }
                }

                delegate: Rectangle {
                    id: notifDelegate
                    required property var modelData

                    width: notifListView.width
                    height: cardContent.implicitHeight + 24
                    radius: 20
                    color: notifMouse.pressed ? Qt.rgba(root.cOnSurface.r, root.cOnSurface.g, root.cOnSurface.b, 0.12) : notifMouse.containsMouse ? Qt.rgba(root.cOnSurface.r, root.cOnSurface.g, root.cOnSurface.b, 0.08) : root.cSurfaceContainerHigh
                    Behavior on color { ColorAnimation { duration: 150 } }

                    MouseArea {
                        id: notifMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (notifDelegate.modelData.actions?.length > 0)
                            notifDelegate.modelData.actions[0].invoke()
                    }

                    NotificationCard {
                        id: cardContent
                        anchors.fill: parent
                        anchors.margins: 14
                        notification: notifDelegate.modelData
                        pywal: root.pywal
                        showCloseButton: true
                        showTimestamp: false
                        showActions: false
                        showBody: true
                        showAppIcon: false

                        primaryColor: root.cPrimary
                        onSurfaceColor: root.cOnSurface
                        onSurfaceVariantColor: root.cOnSurfaceVariant
                    }
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 12
                    visible: (notifs.recentNotifications?.length ?? 0) === 0
                    opacity: visible ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                    Text { Layout.alignment: Qt.AlignHCenter; text: "󰂚"; font.family: "Material Design Icons"; font.pixelSize: 56; color: Qt.rgba(root.cOnSurface.r, root.cOnSurface.g, root.cOnSurface.b, 0.1) }
                    Text { Layout.alignment: Qt.AlignHCenter; text: "No Notifications"; font.family: "Inter"; font.pixelSize: 14; font.weight: Font.Medium; color: Qt.rgba(root.cOnSurface.r, root.cOnSurface.g, root.cOnSurface.b, 0.4) }
                }
            }
        }
    }
}
