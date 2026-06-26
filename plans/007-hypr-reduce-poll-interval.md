# Plan 007: Hypr — reduce fallback poll interval from 500ms to 5000ms

> **Drift check**: `git diff --stat 161c9d1..HEAD -- services/Hypr.qml`

## Status

- **Priority**: P2 | **Effort**: S | **Risk**: LOW | **Category**: perf
- **Depends on**: none | **Planned at**: commit `161c9d1`

## Why this matters

`Hypr.qml:37-44` polls `Hyprland.refreshWorkspaces()` every 500ms. Lines 46-68 handle the same updates via event-driven `Connections` on `Hyprland.onRawEvent` — covering workspace switches, window open/close, focus changes. The timer is a fallback for missed events, but 500ms is far too aggressive for a fallback.

## Steps

### Step 1: Change the timer interval from 500 to 5000

Change line 38: `interval: 500` → `interval: 5000`

**Verify**: `grep -n 'interval:' services/Hypr.qml` → shows `5000`.

## Done criteria

- [ ] `grep -n 'interval:' services/Hypr.qml` shows `5000`
- [ ] `git diff --stat` shows only `services/Hypr.qml`
