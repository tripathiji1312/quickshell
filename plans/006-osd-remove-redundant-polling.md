# Plan 006: OSD — remove redundant 150ms polling timer in VolumeOSD

> **Drift check**: `git diff --stat 161c9d1..HEAD -- modules/osd/VolumeOSD.qml`

## Status

- **Priority**: P2 | **Effort**: S | **Risk**: LOW | **Category**: perf
- **Depends on**: none | **Planned at**: commit `161c9d1`

## Why this matters

`VolumeOSD.qml:67-86` has a 150ms polling Timer that reads `audio.percentage` and `audio.muted`. Lines 49-65 already have a `Connections` handler on `audio.onPercentageChanged` and `audio.onMutedChanged` that do the same thing. The timer is completely redundant — `Audio.qml` already polls `wpctl` at 250ms, so changes are received within 250ms via the Connections path.

## Steps

### Step 1: Remove the redundant 150ms Timer block

Remove lines 67-86 (the entire second Timer block):

```qml
Timer {
    interval: 150
    running: true
    repeat: true
    onTriggered: {
        ...
    }
}
```

**Verify**: `grep -n 'interval: 150' modules/osd/VolumeOSD.qml` → 0 matches. The `Connections` block (lines 49-65) must remain.

## Done criteria

- [ ] `grep -c 'interval: 150' modules/osd/VolumeOSD.qml` returns 0
- [ ] The `Connections` block with `onPercentageChanged` and `onMutedChanged` still exists
- [ ] `git diff --stat` shows only `modules/osd/VolumeOSD.qml`
