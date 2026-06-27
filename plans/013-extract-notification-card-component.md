# Plan 013: Extract shared NotificationCard component

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md`.
>
> **Drift check (run first)**: `git diff --stat 259e77c..HEAD -- modules/bar/components/NotificationPopups.qml modules/controlcenter/components/NotificationList.qml modules/sidebar/SidebarWindow.qml components/`
> If any in-scope file changed since this plan was written, compare the
> "Current state" excerpts against the live code before proceeding; on a
> mismatch, treat it as a STOP condition.

## Status

- **Priority**: P3
- **Effort**: M
- **Risk**: MED
- **Depends on**: none
- **Category**: tech-debt
- **Planned at**: commit `259e77c`, 2026-06-27

## Why this matters

The notification card layout is duplicated in three independent views:
`NotificationPopups.qml` (840 lines, full popup), `NotificationList.qml`
(123 lines, compact control-center view), and `SidebarWindow.qml`
(483 lines, notification center). Card rendering logic (app icon, summary,
body, actions, timestamps, urgency colors) is reimplemented in each with
slightly different code paths. Any layout change must be manually synced
across all three — they're already drifting (different animation patterns,
different app-icon fallback styles, different urgency handling).

Extracting the shared content section into a `components/NotificationCard.qml`
component ensures visual consistency and reduces maintenance surface.

## Current state

Three independent card implementations:

**NotificationPopups.qml** (lines 82–837) — full popup card in a Repeater:
- Swipe gestures (left dismiss, right close)
- Spring drop-in entrance animation
- Progress bar with timeout auto-dismiss
- App icon image with fallback to "󰂞"
- Summary, body (expandable), image preview
- Action buttons (M3 tonal pills)
- Urgency accent stripe with critical pulse
- Close button (hover-reveal spring)
- Hover overlay and elevation shadow

**NotificationList.qml** (lines 71–109) — compact card in a ListView:
- Simple border-radius card
- Static icon (always "󰂚")
- Summary + body text
- Close button
- No progress bar, no swipe, no animations, no image preview

**SidebarWindow.qml** (lines 223–446) — sidebar card in a ListView:
- Expand/collapse body
- Read/unread dot indicator
- Timestamp
- App name + summary
- App icon image with fallback to first letter
- Action buttons
- Urgency color on border
- Dismiss + Delete action buttons

All three use the same notification data model (`modelData` / `notifWrapper`)
with these common properties: `summary`, `body`, `appName`, `appIcon`,
`urgency`, `actions`, `timeString`, `image`, `closed`.

## Commands you will need

| Purpose      | Command                           | Expected on success |
|--------------|-----------------------------------|---------------------|
| Check QML    | `./reload-quickshell.sh`          | no startup errors   |

## Scope

**In scope**:
- `components/NotificationCard.qml` — create (new shared component)
- `modules/bar/components/NotificationPopups.qml` — replace inline card content
- `modules/controlcenter/components/NotificationList.qml` — replace inline card
- `modules/sidebar/SidebarWindow.qml` — replace inline card

**Out of scope** (do NOT touch):
- Swipe gesture logic in NotificationPopups (the swipe container and
  animations stay in NotificationPopups.qml; only the card *content* is
  extracted)
- Entry/exit animations for popup notifications
- The empty-state views ("No Notifications", "No notifications right now")
- The overall ListView/Repeater structure of each view

## Git workflow

- Branch: `advisor/013-extract-notification-card`
- Commit message: `refactor: extract shared NotificationCard component`
- Do NOT push or open a PR unless instructed.

## Steps

### Step 1: Create `components/NotificationCard.qml`

Create the file `components/NotificationCard.qml` with the shared content
layout. This component handles the notification content inside the card —
the outer container card (background, border, radius, hover effects) and
animations remain in each consumer.

```qml
import QtQuick 6.10
import QtQuick.Layouts
import "../services" as QsServices
import "../config" as QsConfig

Item {
    id: root

    required property var notification
    property var pywal: null

    // Feature flags
    property bool showCloseButton: true
    property bool showTimestamp: false
    property bool showUnreadDot: false
    property bool showActions: true
    property bool showBody: true
    property bool showAppIcon: true

    // Configured from consumer context
    property color primaryColor: pywal?.primary ?? "#88cc88"
    property color onSurfaceColor: pywal?.foreground ?? "#dddddd"
    property color onSurfaceVariantColor: pywal?.onSurfaceMuted ?? "#999999"
    property color errorColor: pywal?.error ?? "#ff4444"
    property color surfaceContainerHighColor: pywal?.surfaceContainerHigh ?? "#1a1a1a"

    // Urgency color helper
    function urgencyColor(urgency) {
        if (urgency === 2) return errorColor
        if (urgency === 0) return Qt.rgba(onSurfaceColor.r, onSurfaceColor.g, onSurfaceColor.b, 0.5)
        return primaryColor
    }

    // App icon source helper
    function iconSource(icon) {
        if (!icon) return ""
        if (icon.startsWith("/") || icon.startsWith("file://")) return icon
        return "image://icon/" + icon
    }

    implicitHeight: contentLayout.implicitHeight

    ColumnLayout {
        id: contentLayout
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 8

        // --- Header Row: icon + summary + timestamp + close ---
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            // App icon
            Rectangle {
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                Layout.alignment: Qt.AlignTop
                radius: 12
                visible: showAppIcon
                color: Qt.rgba(urgencyColor(notification?.urgency ?? 1).r,
                               urgencyColor(notification?.urgency ?? 1).g,
                               urgencyColor(notification?.urgency ?? 1).b, 0.12)

                Image {
                    anchors.centerIn: parent
                    width: 20; height: 20
                    visible: notification?.appIcon && notification.appIcon.length > 0
                    source: root.iconSource(notification?.appIcon ?? "")
                    fillMode: Image.PreserveAspectFit
                    smooth: true; cache: true; asynchronous: true
                }

                Text {
                    anchors.centerIn: parent
                    visible: !notification?.appIcon || notification.appIcon.length === 0
                    text: "󰂚"
                    font.family: "Material Design Icons"
                    font.pixelSize: 18
                    color: urgencyColor(notification?.urgency ?? 1)
                    opacity: 0.8
                }
            }

            // Summary + app name
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    Layout.fillWidth: true
                    text: notification?.summary ?? "Notification"
                    font.family: QsConfig.Config.appearance.fontFamily ?? "Inter"
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    color: onSurfaceColor
                    elide: Text.ElideRight
                    font.letterSpacing: -0.15
                }

                Text {
                    Layout.fillWidth: true
                    text: notification?.appName ?? ""
                    font.family: QsConfig.Config.appearance.fontFamily ?? "Inter"
                    font.pixelSize: 11
                    color: onSurfaceVariantColor
                    elide: Text.ElideRight
                    visible: text.length > 0
                }
            }

            // Unread dot
            Rectangle {
                Layout.preferredWidth: 8
                Layout.preferredHeight: 8
                Layout.alignment: Qt.AlignTop
                radius: 4
                visible: showUnreadDot && notification && !notification.read
                color: primaryColor
                Layout.topMargin: 4
            }

            // Timestamp
            Text {
                visible: showTimestamp
                text: notification?.timeString ?? ""
                font.family: QsConfig.Config.appearance.fontFamily ?? "Inter"
                font.pixelSize: 10
                color: onSurfaceVariantColor
                Layout.alignment: Qt.AlignTop
                Layout.topMargin: 2
            }

            // Close button
            Rectangle {
                Layout.preferredWidth: 26
                Layout.preferredHeight: 26
                Layout.alignment: Qt.AlignTop
                radius: 13
                visible: showCloseButton
                color: closeMouse.containsMouse
                    ? Qt.rgba(errorColor.r, errorColor.g, errorColor.b, 0.12)
                    : "transparent"
                Behavior on color { ColorAnimation { duration: 120 } }

                Text {
                    anchors.centerIn: parent
                    text: "󰅖"
                    font.family: "Material Design Icons"
                    font.pixelSize: 13
                    color: closeMouse.containsMouse ? errorColor : Qt.rgba(onSurfaceColor.r, onSurfaceColor.g, onSurfaceColor.b, 0.45)
                    Behavior on color { ColorAnimation { duration: 120 } }
                }

                MouseArea {
                    id: closeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.notification && root.notification.close)
                            root.notification.close()
                    }
                }
            }
        }

        // --- Body text ---
        Text {
            Layout.fillWidth: true
            text: notification?.body ?? ""
            font.family: QsConfig.Config.appearance.fontFamily ?? "Inter"
            font.pixelSize: 12
            color: onSurfaceVariantColor
            wrapMode: Text.WordWrap
            maximumLineCount: 3
            elide: Text.ElideRight
            lineHeight: 1.4
            visible: showBody && text.length > 0
        }

        // --- Image preview ---
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            radius: 10
            clip: true
            visible: notification?.image && notification.image.length > 0
            color: surfaceContainerHighColor

            Image {
                anchors.fill: parent
                anchors.margins: 1
                source: root.iconSource(notification?.image ?? "")
                fillMode: Image.PreserveAspectCrop
                smooth: true; cache: true; asynchronous: true
            }
        }

        // --- Action buttons ---
        Flow {
            Layout.fillWidth: true
            spacing: 6
            visible: showActions && notification?.actions && notification.actions.length > 0

            Repeater {
                model: notification?.actions ?? []

                Rectangle {
                    required property var modelData
                    width: actionLabel.implicitWidth + 22
                    height: 28
                    radius: 14
                    color: actionMouse.containsMouse
                        ? Qt.rgba(primaryColor.r, primaryColor.g, primaryColor.b, 0.18)
                        : Qt.rgba(primaryColor.r, primaryColor.g, primaryColor.b, 0.10)
                    Behavior on color { ColorAnimation { duration: 120 } }
                    scale: actionMouse.pressed ? 0.94 : 1.0
                    Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }

                    Text {
                        id: actionLabel
                        anchors.centerIn: parent
                        text: modelData.text ?? modelData.identifier ?? ""
                        font.pixelSize: 11
                        font.weight: Font.Medium
                        font.family: QsConfig.Config.appearance.fontFamily ?? "Inter"
                        font.letterSpacing: 0.3
                        color: primaryColor
                    }

                    MouseArea {
                        id: actionMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (modelData.invoke)
                                modelData.invoke()
                            if (root.notification && root.notification.close)
                                root.notification.close()
                        }
                    }
                }
            }
        }
    }
}
```

**Verify**: The file exists at `components/NotificationCard.qml` and can be
imported with `import "../../components"` from module files.

### Step 2: Update `NotificationPopups.qml`

Replace the inline card content (the entire `ColumnLayout` block starting at
`contentCol` around line 532 down to line 834) with a `NotificationCard`:

Inside the `cardBg` Rectangle, replace the `ColumnLayout` content:
```qml
NotificationCard {
    id: contentCard
    anchors {
        left: parent.left
        right: parent.right
        top: parent.top
        margins: 16
        topMargin: 18
    }
    notification: modelData
    pywal: root.pywal
    showCloseButton: true
    showTimestamp: false
    showActions: true
    showBody: true
    showAppIcon: true

    primaryColor: root.m3Primary
    onSurfaceColor: root.m3OnSurface
    onSurfaceVariantColor: root.m3OnSurfaceVariant
    errorColor: root.m3Error
    surfaceContainerHighColor: root.m3SurfaceContainerHigh
}
```

Remove the old content `ColumnLayout` (lines ~532–834) and the close
button `MouseArea` at line ~663–672 (the close button is now in the
NotificationCard).

Keep ALL existing code above `cardBg` and the gesture/swipe logic—the
`cardBg` Rectangle itself and all animation/gesture code stays.

**Verify**: The file still has the `gestureArea` MouseArea, `entranceAnim`,
`exitRight`, `exitLeft`, `snapBack`, `dismissAnim`, and `scrollTimer`.

### Step 3: Update `NotificationList.qml`

Replace the inline delegate (lines 71–109) with:

```qml
delegate: Rectangle {
    id: notifDelegate
    required property var modelData

    width: notifListView.width
    height: cardContent.implicitHeight + 24
    radius: 20
    color: notifMouse.pressed ? Qt.rgba(root.cOnSurface.r, root.cOnSurface.g, root.cOnSurface.b, 0.12)
        : notifMouse.containsMouse ? Qt.rgba(root.cOnSurface.r, root.cOnSurface.g, root.cOnSurface.b, 0.08)
        : root.cSurfaceContainerHigh
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
```

**Verify**: The `NotificationList.qml` should be shorter and the import
line `import "../../../components"` should be present (add it if not).

### Step 4: Update `SidebarWindow.qml`

Replace the inline delegate (lines 223–446) with:

```qml
delegate: Rectangle {
    id: card
    required property var modelData
    required property int index
    property bool expanded: false

    width: listView.width
    height: cardContent.implicitHeight + 22
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
        anchors.fill: parent
        anchors.margins: 12
        notification: card.modelData
        pywal: root.pywal
        showCloseButton: false      // Sidebar uses Dismiss + Delete buttons instead
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

    // Dismiss + Delete buttons (sidebar-specific, below the card content)
    RowLayout {
        anchors {
            left: parent.left; right: parent.right; bottom: parent.bottom
            leftMargin: 12; rightMargin: 12; bottomMargin: 12
        }
        spacing: 8
        // ... keep existing Dismiss and Delete buttons from lines 386-444
    }
}
```

Keep the existing Dismiss and Delete buttons at the bottom. Remove the
duplicated content sections (icon, summary, body, actions, timestamp, unread
dot) from the inline delegate — they're now in NotificationCard.

**Verify**: The `SidebarWindow.qml` should be noticeably shorter. Add
`import "../../components"` if not present (it should already be at line 8).

### Step 5: Update `components/qmldir`

Open `components/qmldir` and add:
```
NotificationCard 1.0 NotificationCard.qml
```

**Verify**: `grep "NotificationCard" components/qmldir` matches the new line.

## Test plan

No tests exist. Verification is by visual inspection:

1. Open a notification popup → confirm it renders with icon, summary, body,
   close button, and action buttons
2. Open the Control Center → confirm notification list shows cards with
   close button
3. Open the Sidebar → confirm notification cards show with icon, summary,
   timestamp, unread dot, body (on click), and action buttons
4. Click Close on popup → notification is dismissed
5. Click Dismiss/Delete on sidebar → notification is dismissed/deleted
6. `./reload-quickshell.sh` → no errors

## Done criteria

Machine-checkable. ALL must hold:

- [ ] `ls components/NotificationCard.qml` succeeds
- [ ] `grep "NotificationCard" components/qmldir` matches
- [ ] `grep -c "NotificationCard" modules/bar/components/NotificationPopups.qml` ≥ 1 (the import usage)
- [ ] `grep -c "NotificationCard" modules/controlcenter/components/NotificationList.qml` ≥ 1
- [ ] `grep -c "NotificationCard" modules/sidebar/SidebarWindow.qml` ≥ 1
- [ ] The old duplicated summary/appName/body/action layout code is gone from
      all three files (no more inline `modelData.summary` card rendering)
- [ ] `plans/README.md` status row updated

## STOP conditions

Stop and report back (do not improvise) if:

- The code at the locations in "Current state" doesn't match the excerpts
  (codebase has drifted since 259e77c)
- A consumer file has significantly different notification data model
  (e.g., different property names) — verify `modelData.summary`,
  `modelData.body`, `modelData.appName`, etc. exist in all three
- The component doesn't render correctly after substitution — revert the
  failing consumer and report which property was incompatible
- Any file outside the in-scope list needs modification

## Maintenance notes

- Future changes to the notification card layout (app icon, summary styling,
  body truncation, action button style) should be made in
  `components/NotificationCard.qml` and will propagate to all three views.
- If a consumer needs a variant-specific feature (e.g., the swipe dismiss
  from NotificationPopups), it goes in the consumer file, not the shared
  component.
- The component uses feature flags (`showBody`, `showTimestamp`, etc.) to
  avoid a sprawling props API — add a new flag when a consumer needs a
  behavior difference.
- The `urgencyColor()` helper is now in two places (NotificationCard.qml
  and SidebarWindow.qml — the sidebar still needs it for border color).
  Future work could move the helper into the `Notifs` service.
