# Plan 009: Dependencies — add missing packages to setup.sh

> **Drift check**: `git diff --stat 161c9d1..HEAD -- setup.sh README.md`

## Status

- **Priority**: P2 | **Effort**: S | **Risk**: LOW | **Category**: dx
- **Depends on**: none | **Planned at**: commit `161c9d1`

## Why this matters

Several tools used by the shell are missing from `setup.sh`'s PACKAGES list and README's dependency table. New users installing via `setup.sh` get a working bar but discover that screenshots silently fail (missing `jq`, `wl-clipboard`, `wf-recorder`), notifications may not appear (missing `libnotify`), and visual effects may be missing (missing `qt6-quickeffects`).

## Current state

Missing packages:
- `jq` — used by `services/Screenshot.qml:47` for parsing `hyprctl` JSON output
- `wl-clipboard` — provides `wl-copy`, used by `services/Screenshot.qml:107,187`
- `wf-recorder` — used by `services/Screenshot.qml:138` for screen recording  
- `libnotify` — provides `notify-send`, used by `services/Screenshot.qml:109`
- `qt6-quickeffects` — required for `QtQuick.Effects` imports in 14 files

## Steps

### Step 1: Add missing packages to setup.sh

Add these to the `PACKAGES` array in `setup.sh`:

```
qt6-quickeffects
jq
wl-clipboard
wf-recorder
libnotify
```

### Step 2: Add entries to README dependency table

Add rows to the README dependencies table. The table uses this format:

```
| `jq` | JSON parsing for window geometry |
| `wl-clipboard` | Wayland clipboard (`wl-copy`) |
| `wf-recorder` | Screen recording |
| `libnotify` | Desktop notifications (`notify-send`) |
| `qt6-quickeffects` | Material Design 3 visual effects |
```

## Done criteria

- [ ] `grep -c 'jq' setup.sh` returns >= 1
- [ ] `grep -c 'wl-clipboard' setup.sh` returns >= 1
- [ ] `grep -c 'wf-recorder' setup.sh` returns >= 1
- [ ] `grep -c 'libnotify' setup.sh` returns >= 1
- [ ] `grep -c 'qt6-quickeffects' setup.sh` returns >= 1
- [ ] `git diff --stat` shows only `setup.sh` and optionally `README.md`
