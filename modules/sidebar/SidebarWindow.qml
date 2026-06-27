import QtQuick 6.10
import QtQuick.Layouts 6.10
import QtQuick.Controls 6.10 as QQC
import Quickshell
import Quickshell.Wayland
import "../../config" as QsConfig
import "../../services" as QsServices
import "../../components"

PanelWindow {
    id: root

    property bool shouldShow: false

    readonly property var config: QsConfig.Config
    readonly property var pywal: QsServices.Pywal
    readonly property var notifs: QsServices.Notifs
    readonly property color cSurface: pywal.surfaceContainerHighest
    readonly property color cSurfaceContainer: pywal.surfaceContainerHigh
    readonly property color cSurfaceContainerHigh: pywal.surfaceContainerHigh
    readonly property color cPrimary: pywal.primary
    readonly property color cText: pywal.foreground
    readonly property color cSubText: pywal.onSurfaceMuted
    readonly property color cBorder: pywal.outlineVariant
    readonly property var visibleNotifications: (notifs.recentNotifications ?? []).slice(0, config.sidebar.maxHistory)

    function closeSidebar() {
        shouldShow = false
    }

    function iconSourceFor(notification) {
        if (!notification?.appIcon)
            return ""
        if (notification.appIcon.startsWith("/") || notification.appIcon.startsWith("file://"))
            return notification.appIcon
        return "image://icon/" + notification.appIcon
    }

    function urgencyColor(notification) {
        if (notification?.urgency === 2)
            return pywal.error
        if (notification?.urgency === 0)
            return Qt.rgba(cText.r, cText.g, cText.b, 0.5)
        return cPrimary
    }

    onShouldShowChanged: {
        if (shouldShow) {
            notifs.markAllRead()
            Qt.callLater(() => panel.forceActiveFocus())
        }
    }

    screen: Quickshell.screens[0]
    anchors {
        top: true
        right: true
    }
    margins {
        top: (config.bar.height ?? 34) + config.sidebar.margin + 6
        right: config.sidebar.margin
    }
    implicitWidth: config.sidebar.width
    implicitHeight: shouldShow || panel.opacity > 0 ? Math.min(screen.height - margins.top - 18, 760) : 0
    visible: config.sidebar.enabled && (shouldShow || panel.opacity > 0)
    color: "transparent"

    WlrLayershell.keyboardFocus: shouldShow ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    FocusScope {
        id: panel
        anchors.fill: parent
        property real revealOffset: shouldShow ? 0 : 18
        scale: shouldShow ? 1.0 : 0.975
        opacity: shouldShow ? 1.0 : 0.0
        focus: root.shouldShow
        transform: Translate { x: panel.revealOffset }

        Keys.onEscapePressed: root.closeSidebar()

        Behavior on scale {
            NumberAnimation { duration: 220; easing.bezierCurve: [0.22, 1.0, 0.36, 1.0] }
        }

        Behavior on opacity {
            NumberAnimation { duration: 180; easing.type: Easing.OutQuad }
        }

        Behavior on revealOffset {
            NumberAnimation { duration: 240; easing.bezierCurve: [0.05, 0.7, 0.1, 1.0] }
        }

        AuroraSurface {
            anchors.fill: parent
            radius: 26
            color: root.cSurface
            strokeColor: root.cBorder
            accentColor: root.cPrimary
            elevation: 4
            highlighted: root.shouldShow

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 16

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Rectangle {
                        Layout.preferredWidth: 42
                        Layout.preferredHeight: 42
                        radius: 14
                        color: Qt.rgba(root.cPrimary.r, root.cPrimary.g, root.cPrimary.b, 0.14)

                        Text {
                            anchors.centerIn: parent
                            text: root.notifs.dnd ? "󰂛" : "󰂚"
                            font.family: "Material Design Icons"
                            font.pixelSize: 20
                            color: root.cPrimary
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: "Notification Center"
                            font.family: QsConfig.Config.appearance.fontFamily
                            font.pixelSize: 16
                            font.weight: Font.Bold
                            color: root.cText
                        }

                        Text {
                            text: root.notifs.dnd
                                ? "Do Not Disturb is enabled"
                                : `${root.visibleNotifications.length} notification${root.visibleNotifications.length === 1 ? "" : "s"} in history`
                            font.family: QsConfig.Config.appearance.fontFamily
                            font.pixelSize: 11
                            color: root.cSubText
                        }
                    }

                    QQC.Switch {
                        id: dndSwitch
                        checked: root.notifs.dnd
                        onToggled: root.notifs.dnd = checked
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        radius: 17
                        color: root.cSurfaceContainer

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10

                            Text {
                                text: root.notifs.unreadCount > 0 ? `${root.notifs.unreadCount} unread` : "All caught up"
                                font.family: QsConfig.Config.appearance.fontFamily
                                font.pixelSize: 11
                                font.weight: Font.Medium
                                color: root.cText
                            }

                            Item { Layout.fillWidth: true }

                            Text {
                                text: "Last 24h"
                                font.family: QsConfig.Config.appearance.fontFamily
                                font.pixelSize: 11
                                color: root.cSubText
                            }
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: clearText.implicitWidth + 20
                        Layout.preferredHeight: 34
                        radius: 17
                        color: clearMouse.containsMouse ? root.cSurfaceContainerHigh : root.cSurfaceContainer
                        visible: root.visibleNotifications.length > 0

                        Text {
                            id: clearText
                            anchors.centerIn: parent
                            text: "Clear"
                            font.family: QsConfig.Config.appearance.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: root.cText
                        }

                        MouseArea {
                            id: clearMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.notifs.clearAll()
                        }
                    }
                }

                ListView {
                    id: listView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 10
                    model: root.visibleNotifications

                    delegate: Rectangle {
                        id: card
                        required property var modelData
                        required property int index
                        property bool expanded: false

                        width: listView.width
                        height: cardContent.implicitHeight + 52
                        radius: 20
                        color: cardMouse.containsMouse ? root.cSurfaceContainerHigh : root.cSurfaceContainer
                        border.width: modelData.read ? 1 : 1.25
                        border.color: modelData.read
                            ? Qt.rgba(root.cText.r, root.cText.g, root.cText.b, 0.05)
                            : Qt.rgba(root.urgencyColor(modelData).r, root.urgencyColor(modelData).g, root.urgencyColor(modelData).b, 0.32)

                        Behavior on color { ColorAnimation { duration: 120 } }
                        Behavior on border.color { ColorAnimation { duration: 120 } }

                        MouseArea {
                            id: cardMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                card.expanded = !card.expanded
                                card.modelData.read = true
                            }
                        }

                        NotificationCard {
                            id: cardContent
                            anchors {
                                left: parent.left; right: parent.right; top: parent.top
                                leftMargin: 12; rightMargin: 12; topMargin: 12
                            }
                            notification: card.modelData
                            pywal: root.pywal
                            showCloseButton: false
                            showTimestamp: true
                            showUnreadDot: true
                            showActions: true
                            showBody: card.expanded
                            showAppIcon: true

                            primaryColor: root.cPrimary
                            onSurfaceColor: root.cText
                            onSurfaceVariantColor: root.cSubText
                            errorColor: pywal.error
                            surfaceContainerHighColor: root.cSurfaceContainerHigh
                        }

                        RowLayout {
                            anchors {
                                left: parent.left; right: parent.right; bottom: parent.bottom
                                leftMargin: 12; rightMargin: 12; bottomMargin: 12
                            }
                            spacing: 8

                            Item { Layout.fillWidth: true }

                            Rectangle {
                                Layout.preferredWidth: 78
                                Layout.preferredHeight: 28
                                radius: 14
                                color: closeMouse.containsMouse
                                    ? Qt.rgba(root.cText.r, root.cText.g, root.cText.b, 0.12)
                                    : Qt.rgba(root.cText.r, root.cText.g, root.cText.b, 0.06)

                                Text {
                                    anchors.centerIn: parent
                                    text: card.modelData.closed ? "Dismissed" : "Dismiss"
                                    font.family: QsConfig.Config.appearance.fontFamily
                                    font.pixelSize: 10
                                    color: root.cText
                                }

                                MouseArea {
                                    id: closeMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        card.modelData.read = true
                                        card.modelData.close()
                                    }
                                }
                            }

                            Rectangle {
                                Layout.preferredWidth: 70
                                Layout.preferredHeight: 28
                                radius: 14
                                color: deleteMouse.containsMouse
                                    ? Qt.rgba(pywal.error.r, pywal.error.g, pywal.error.b, 0.16)
                                    : Qt.rgba(pywal.error.r, pywal.error.g, pywal.error.b, 0.10)

                                Text {
                                    anchors.centerIn: parent
                                    text: "Delete"
                                    font.family: QsConfig.Config.appearance.fontFamily
                                    font.pixelSize: 10
                                    color: pywal.error
                                }

                                MouseArea {
                                    id: deleteMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.notifs.deleteNotification(card.modelData)
                                }
                            }
                        }
                    }

                    footer: Item {
                        width: listView.width
                        height: 10
                    }

                    QQC.ScrollBar.vertical: QQC.ScrollBar {
                        policy: QQC.ScrollBar.AsNeeded
                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        visible: root.visibleNotifications.length === 0

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "󰂜"
                            font.family: "Material Design Icons"
                            font.pixelSize: 46
                            color: Qt.rgba(root.cText.r, root.cText.g, root.cText.b, 0.22)
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "No notifications right now"
                            font.family: QsConfig.Config.appearance.fontFamily
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: root.cSubText
                        }
                    }
                }
            }
        }
    }
}