# Plan 005: Cleanup — remove dead popup window files

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md`.
>
> **Drift check**: `git diff --stat 161c9d1..HEAD -- modules/bar/components/`
> If any of the files listed below has been modified (not just deleted), STOP.

## Status

- **Priority**: P2 | **Effort**: S | **Risk**: LOW
- **Depends on**: none | **Category**: tech-debt
- **Planned at**: commit `161c9d1`, 2026-06-26

## Why this matters

The codebase migrated from separate popup windows to inline panels, but 8 old popup window files remain in `modules/bar/components/` totaling ~2762 lines. They are not loaded by any file. They confuse contributors (which popup pattern should a new feature follow?), waste disk space, and add maintenance burden (search results, grep hits). Separately, the `example/` directory contains a different project (ArchDots) that doesn't match the architecture of this repo.

## Current state

Dead files in `modules/bar/components/`:
- `BluetoothPopupWindow.qml` (~445 lines)
- `BrightnessPopupWindow.qml` (~274 lines)
- `MediaPlayerPopup.qml` (~378 lines)
- `MediaPlayerPopupWindow.qml` (~327 lines)
- `MediaPlayerPopout.qml` (~246 lines)
- `MediaPopoutWrapper.qml` (~94 lines)
- `NetworkPopupWindow.qml` (~620 lines)
- `VolumePopupWindow.qml` (~378 lines)

These are legacy — the popup content now lives inline in `Bar.qml` (lines 500-661) and separate panel files (`BluetoothPanel.qml`, `NetworkPanel.qml`, etc.).

Also: `modules/bar/popouts/` is empty; `modules/dock/` is empty; `modules/notifications/` is empty. The `example/` directory is a different project.

## Scope

**In scope** (delete these files):
- `modules/bar/components/BluetoothPopupWindow.qml`
- `modules/bar/components/BrightnessPopupWindow.qml`
- `modules/bar/components/MediaPlayerPopup.qml`
- `modules/bar/components/MediaPlayerPopupWindow.qml`
- `modules/bar/components/MediaPlayerPopout.qml`
- `modules/bar/components/MediaPopoutWrapper.qml`
- `modules/bar/components/NetworkPopupWindow.qml`
- `modules/bar/components/VolumePopupWindow.qml`

**Optionally** (empty dirs):
- `modules/bar/popouts/` (empty — remove)
- `modules/dock/` (empty — remove)
- `modules/notifications/` (empty — remove)
- `example/` (stale project — remove)

**Out of scope**: Any file that is actively loaded or imported. Bar.qml, BarWrapper.qml, any panel file. Do NOT delete `BluetoothPanel.qml`, `NetworkPanel.qml` (these are the current implementations).

## Steps

### Step 1: Confirm no file loads any of the dead files

```bash
grep -rn 'BluetoothPopupWindow\|BrightnessPopupWindow\|MediaPlayerPopup\|MediaPopout\|NetworkPopupWindow\|VolumePopupWindow' modules/ --include='*.qml'
```

Expected: zero matches (they are not imported anywhere). If there ARE matches, STOP — those callers need to be checked first.

### Step 2: Delete the dead files

```bash
rm modules/bar/components/BluetoothPopupWindow.qml
rm modules/bar/components/BrightnessPopupWindow.qml
rm modules/bar/components/MediaPlayerPopup.qml
rm modules/bar/components/MediaPlayerPopupWindow.qml
rm modules/bar/components/MediaPlayerPopout.qml
rm modules/bar/components/MediaPopoutWrapper.qml
rm modules/bar/components/NetworkPopupWindow.qml
rm modules/bar/components/VolumePopupWindow.qml
```

### Step 3 (optional): Remove empty directories

```bash
rmdir modules/bar/popouts/
rmdir modules/dock/
rmdir modules/notifications/
```

(If any directory is non-empty, skip it and report.)

### Step 4 (optional): Remove stale example directory

```bash
rm -rf example/
```

This directory contains a different project (ArchDots) and will never be used as an example for this config.

**Verify**:
```bash
ls modules/bar/components/*Popup* modules/bar/components/*Popout* 2>&1
```
Expected: `No matches found` (zsh) or similar no-such-file.

```bash
ls -d modules/bar/popouts/ modules/dock/ modules/notifications/ 2>&1
```
Expected: `No such file or directory` for each.

## Test plan

No code behavior changes — these files are dead. Confirm by running the shell:
```bash
quickshell &
sleep 3 && kill %1
```
No crashes expected.

## Done criteria

- [ ] `ls modules/bar/components/*Popup*.qml 2>/dev/null | wc -l` returns 0
- [ ] `ls modules/bar/components/*Popout*.qml 2>/dev/null | wc -l` returns 0
- [ ] `ls -d modules/bar/popouts/ 2>/dev/null` returns nothing (directory removed)
- [ ] `ls -d modules/dock/ 2>/dev/null` returns nothing (directory removed)
- [ ] `ls -d modules/notifications/ 2>/dev/null` returns nothing (directory removed)
- [ ] No files outside the in-scope list are modified (`git diff --stat`)

## STOP conditions

- If any of the listed files IS imported by another file, stop and report (do NOT delete)
- If the `example/` directory contains config symlinks used by the main project, stop and report

## Maintenance notes

If someone is looking for the old popup patterns, they're gone. The canonical pattern for bar popups is now inline panels in `Bar.qml` (lines 500-661) and separate `*Panel.qml` files in `modules/bar/components/`. Document this in AGENTS.md or CLAUDE.md.
