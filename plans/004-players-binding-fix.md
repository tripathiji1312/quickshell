# Plan 004: Media Players — fix broken `active` property binding

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md`.
>
> **Drift check**: `git diff --stat 161c9d1..HEAD -- services/Players.qml`
> If changed, compare the excerpts below against live code before proceeding.

## Status

- **Priority**: P2 | **Effort**: M | **Risk**: LOW
- **Depends on**: none | **Category**: bug
- **Planned at**: commit `161c9d1`, 2026-06-26

## Why this matters

`Players.qml:16-24` defines `active` as a computed property binding. `updateActivePlayer()` (line 36-53) writes `active = newActive`, which **breaks the QML binding** — after the first manual write, the binding expression never re-evaluates. Currently the `Connections` handler (line 28-34) calls `updateActivePlayer()` on every MPRIS change, and a fallback timer (line 56-62) also calls it, so `active` keeps updating. But if the `onValuesChanged` signal ever fails to fire, or the timer is stopped, `active` goes stale permanently. The dual mechanism (binding + manual writes) is fragile and confusing.

## Current state

`services/Players.qml:16-24` (computed binding):
```qml
property var active: {
    for (var i = 0; i < list.length; i++) {
        if (list[i]?.isPlaying) {
            return list[i]
        }
    }
    return list[0] ?? null
}
```

`services/Players.qml:36-53` (manual overrider):
```qml
function updateActivePlayer() {
    var newActive = null
    for (var i = 0; i < list.length; i++) {
        if (list[i]?.isPlaying) {
            newActive = list[i]
            break
        }
    }
    if (!newActive && list.length > 0) {
        newActive = list[0]
    }
    if (active !== newActive) {
        active = newActive
    }
}
```

The binding and the function have identical logic. The function also checks `active !== newActive` before writing to avoid redundant binding breaks — but the first write still breaks the binding forever.

## Scope

**In scope**: `services/Players.qml`

**Out of scope**: Any other file, the media player UI components

## Steps

### Step 1: Remove the computed `active` binding, use a regular property

Replace lines 16-25:

```qml
// Active player should be the currently playing one, or first in list if none playing
property var active: {
    // Find the first playing player
    for (var i = 0; i < list.length; i++) {
        if (list[i]?.isPlaying) {
            return list[i]
        }
    }
    // If no player is playing, return the first one
    return list[0] ?? null
}
```

With:

```qml
property var active: null
```

### Step 2: Call `updateActivePlayer()` from `Component.onCompleted`

Add after the last property declaration (after line 13, before `active`):

```qml
Component.onCompleted: updateActivePlayer()
```

### Step 3: Refactor `updateActivePlayer()` to be more robust

Replace the existing `updateActivePlayer()` (lines 36-53) with:

```qml
function updateActivePlayer() {
    var newActive = null
    for (var i = 0; i < list.length; i++) {
        if (list[i]?.isPlaying) {
            newActive = list[i]
            break
        }
    }
    if (!newActive && list.length > 0) {
        newActive = list[0]
    }
    if (active !== newActive) {
        active = newActive
    }
}
```

(The function body is unchanged — it was already correct. The issue was the conflicting binding, which we removed.)

### Step 4: Verify the Connections and Timer still call `updateActivePlayer()`

No changes needed here — the `Connections` (line 28-34) and `Timer` (line 56-62) both correctly call `root.updateActivePlayer()`. Confirm they're still present.

**Verify**:
```bash
grep -n 'property var active' services/Players.qml
```
Expected output: `15: property var active: null` (or the relevant line number — just one match, no binding expression).

```bash
grep -n 'updateActivePlayer' services/Players.qml
```
Expected: 3 matches (definition, Connections call, Timer call, plus Component.onCompleted if added — should be 3 or 4).

## Test plan

Manual: play/pause media in different players, verify the bar media widget tracks the active player correctly. The behavior should be identical to before — no regression.

## Done criteria

- [ ] `grep -n 'property var active:' services/Players.qml` shows `active: null` (no binding expression)
- [ ] `grep -c 'updateActivePlayer' services/Players.qml` returns exactly 3 or 4 (definition + Connections + Timer + optional Component.onCompleted)
- [ ] The `active` property binding expression `for (var i = 0; i < list.length; i++)` is no longer present inside a `property var` initializer
- [ ] No other files modified (`git diff --stat` shows only `services/Players.qml`)

## STOP conditions

- If the code at the cited lines doesn't match the excerpts, stop and report
- If any consumer uses `active` with `Qt.binding()` expecting it to be a computed binding, stop and report (none in the current codebase — we checked)

## Maintenance notes

If a new consumer reads `Players.active` expecting it to auto-update without any timer/Connection event, this fix is relevant — `active` now only updates when `updateActivePlayer()` is called, which depends on the `Connections` (MPRIS player changes) and the fallback `Timer` (every 2s). Both are solid mechanisms.
