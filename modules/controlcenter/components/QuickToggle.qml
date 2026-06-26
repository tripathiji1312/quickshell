import QtQuick 6.10
import QtQuick.Layouts 6.10
import QtQuick.Controls 6.10
import "../../../components/effects"

Item {
    id: root

    property string icon: ""
    property string label: ""
    property string subLabel: ""
    property bool active: false
    property color activeColor: "#a6e3a1"
    property color textColor: "#e6e6e6"
    signal clicked()

    Layout.fillWidth: true
    Layout.preferredHeight: 80

    // M3 Expressive Squish Animation
    scale: mouseArea.pressed ? 0.95 : 1.0
    transformOrigin: Item.Center

    Behavior on scale {
        NumberAnimation {
            duration: 250
            easing.bezierCurve: Material3Anim.springBounce
        }
    }

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: 28
        color: root.active ? Qt.rgba(root.activeColor.r, root.activeColor.g, root.activeColor.b, 0.15) : Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.05)

        Behavior on color { ColorAnimation { duration: 250; easing.bezierCurve: Material3Anim.standard } }
    }

    // M3 State Layer
    Rectangle {
        anchors.fill: parent
        radius: bg.radius
        color: root.textColor
        opacity: mouseArea.pressed ? 0.12 : mouseArea.containsMouse ? 0.08 : 0.0
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: root.clicked()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        spacing: 16

        // Morphing Icon Container
        Rectangle {
            id: iconContainer
            Layout.preferredWidth: 48
            Layout.preferredHeight: 48
            radius: root.active ? 16 : 24
            color: root.active ? root.activeColor : Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.08)

            Behavior on radius { NumberAnimation { duration: 300; easing.bezierCurve: Material3Anim.emphasized } }
            Behavior on color { ColorAnimation { duration: 250; easing.bezierCurve: Material3Anim.standard } }

            Text {
                anchors.centerIn: parent
                text: root.icon
                font.family: "Material Design Icons"
                font.pixelSize: 26
                color: root.active ? Qt.rgba(0, 0, 0, 0.9) : root.textColor
                Behavior on color { ColorAnimation { duration: 250 } }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text: root.label
                font.family: "Inter"
                font.pixelSize: 15
                font.weight: Font.DemiBold
                color: root.textColor
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text: root.subLabel
                font.family: "Inter"
                font.pixelSize: 12
                color: root.active ? Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.9) : Qt.rgba(root.textColor.r, root.textColor.g, root.textColor.b, 0.5)
                elide: Text.ElideRight
                Layout.fillWidth: true
                Behavior on color { ColorAnimation { duration: 250 } }
            }
        }
    }
}
