import QtQuick 6.10
import Quickshell
import "../../../services" as QsServices
import "../../../components/effects"

Item {
    id: root

    property var sidebar
    property var controlCenter
    property var launcher

    readonly property var pywal: QsServices.Pywal
    readonly property var notifs: QsServices.Notifs
    readonly property bool isActive: sidebar?.shouldShow ?? false
    readonly property bool isHovered: mouse.containsMouse
    readonly property int unreadCount: notifs.unreadCount

    implicitWidth: bell.implicitWidth + (badge.visible ? badge.width + 4 : 8)
    implicitHeight: bell.implicitHeight

    MouseArea {
        id: mouse
        anchors.fill: parent
        anchors.margins: -4
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            if (!sidebar)
                return

            sidebar.shouldShow = !sidebar.shouldShow
            if (sidebar.shouldShow) {
                if (controlCenter)
                    controlCenter.shouldShow = false
                if (launcher)
                    launcher.shouldShow = false
            }
        }
    }

    Text {
        id: bell
        anchors.centerIn: parent
        text: unreadCount > 0 ? "󰂚" : "󰂜"
        font.family: "Material Design Icons"
        font.pixelSize: 18
        color: isActive || unreadCount > 0
            ? pywal.primary
            : isHovered
                ? pywal.primary
                : pywal.foreground

        Behavior on color {
            ColorAnimation {
                duration: Material3Anim.short3
                easing.bezierCurve: Material3Anim.standard
            }
        }

        scale: mouse.pressed ? 0.92 : (isHovered || isActive ? 1.08 : 1.0)
        Behavior on scale {
            NumberAnimation {
                duration: Material3Anim.short2
                easing.bezierCurve: Material3Anim.standard
            }
        }
    }

    Rectangle {
        id: badge
        anchors.left: bell.right
        anchors.leftMargin: 2
        anchors.top: bell.top
        width: Math.max(16, badgeText.implicitWidth + 8)
        height: 16
        radius: 8
        color: Qt.rgba(pywal.primary.r, pywal.primary.g, pywal.primary.b, 0.9)
        visible: unreadCount > 0

        Text {
            id: badgeText
            anchors.centerIn: parent
            text: unreadCount > 99 ? "99+" : `${unreadCount}`
            font.family: "Inter"
            font.pixelSize: 9
            font.weight: Font.Bold
            color: pywal.background
        }
    }
}