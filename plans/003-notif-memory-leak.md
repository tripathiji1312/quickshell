# Plan 003: Notifications — destroy orphaned wrapper objects

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md`.
>
> **Drift check**: `git diff --stat 161c9d1..HEAD -- services/Notifs.qml`
> If changed, compare the excerpts below against live code before proceeding.

## Status

- **Priority**: P1 | **Effort**: M | **Risk**: LOW
- **Depends on**: none | **Category**: bug
- **Planned at**: commit `161c9d1`, 2026-06-26

## Why this matters

`Notifs.qml:101` caps notifications to `maxNotifications` (100) but never calls `destroy()` on the `QtObject` wrappers that exceed the limit. Each wrapper has a `Connections` object with 7 signal handlers. Over hours of use (especially spammy notifications), orphaned objects accumulate in memory. The hourly cleanup at line 70-78 drops array references but still never destroys the orphaned wrappers, and uses only a time-based filter (24h), so a burst of 100 notifications every hour leaves 100 dead objects/hour indefinitely.

## Current state

`services/Notifs.qml:100-101`:
```qml
// Cap maximum notifications to prevent memory leaks
root.notifications = [notifWrapper, ...root.notifications].slice(0, root.maxNotifications)
```

The `Notif` component (line 154-258) is a `QtObject` with a `Connections` child. When it's dropped from the `notifications` array without `destroy()`, the QML engine retains it because `Connections` holds a strong reference to its target.

## Scope

**In scope**: `services/Notifs.qml` (add `destroy()` before `slice()`)

**Out of scope**: The `deleteNotification()` function (line 268-276) already calls `destroy()` — that's correct. The hourly cleanup timer (line 64-79) — changing its logic is separate.

## Steps

### Step 1: Add `destroy()` call before the cap slice

Replace lines 100-101:

```qml
// Cap maximum notifications to prevent memory leaks
root.notifications = [notifWrapper, ...root.notifications].slice(0, root.maxNotifications)
```

With:

```qml
// Cap maximum notifications to prevent memory leaks
var capped = [notifWrapper, ...root.notifications]
var dropped = capped.slice(root.maxNotifications - 1)
for (var i = 0; i < dropped.length; i++) {
    if (dropped[i]) dropped[i].destroy()
}
root.notifications = capped.slice(0, root.maxNotifications)
```

Note: `capped.length` is `root.notifications.length + 1` (we prepended one). So `root.maxNotifications - 1` is the correct index for the first item to drop. If the list is already below max, `capped.slice(max-1)` returns an empty array, so the loop is a no-op.

**Verify**:
```bash
grep -n 'destroy' services/Notifs.qml
```
Expected output: 3 matches (the existing one in `deleteNotification`, the new one, and the component destructor path).

```bash
grep -n 'slice(0, root.maxNotifications)' services/Notifs.qml
```
Expected output: 1 match (the new line, not the old line 101).

## Test plan

Manual: after many notifications, the orphaned-object count should not grow unbounded. No crash expected.

## Done criteria

- [ ] `grep -c '\.destroy()' services/Notifs.qml` returns at least 2 (existing delete path + new cap path)
- [ ] The old line `root.notifications = [notifWrapper, ...root.notifications].slice(0, root.maxNotifications)` is gone
- [ ] No other files modified (`git diff --stat` shows only `services/Notifs.qml`)

## STOP conditions

- If the code at the cited lines doesn't match the excerpts, stop and report
- If `QtObject.destroy()` is not available or behaves differently in the QuickShell QML environment, stop and report

## Maintenance notes

If `maxNotifications` is ever lowered at runtime (it's currently a constant 100), the cap logic here should still be correct since it's per-insertion. The hourly cleanup timer (line 64-79) still leaks objects it filters out — it uses `filter` but never calls `destroy()` on filtered-out items. That's a separate issue (lower priority since it only runs once per hour).
