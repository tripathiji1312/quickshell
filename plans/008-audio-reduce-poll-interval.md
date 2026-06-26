# Plan 008: Audio — reduce polling interval from 250ms to 1000ms

> **Drift check**: `git diff --stat 161c9d1..HEAD -- services/Audio.qml`

## Status

- **Priority**: P2 | **Effort**: S | **Risk**: LOW | **Category**: perf
- **Depends on**: none | **Planned at**: commit `161c9d1`

## Why this matters

`Audio.qml:20-30` runs two `wpctl get-volume` processes (sink + source) every 250ms — 8 process spawns per second. The audio OSD has a per-cycle max of 250ms latency before it's noticeable. 1000ms polling still provides responsive volume control display (the OSD also triggers from the Connections path, which fires as soon as the poll reads a new value). 250ms is overkill for a value that only changes when the user turns a knob or clicks a slider.

## Steps

### Step 1: Change the audio timer interval from 250 to 1000

Change line 21: `interval: 250` → `interval: 1000`

**Verify**: `grep -n 'interval:' services/Audio.qml` → shows `1000`.

## Done criteria

- [ ] `grep -n 'interval:' services/Audio.qml` shows `1000`
- [ ] `git diff --stat` shows only `services/Audio.qml`
