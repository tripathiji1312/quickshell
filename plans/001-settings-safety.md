# Plan 001: Settings — fix shell injection and write amplification

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md`.
>
> **Drift check**: `git diff --stat 161c9d1..HEAD -- services/Settings.qml`
> If changed, compare the excerpts below against live code before proceeding.

## Status

- **Priority**: P1 | **Effort**: S | **Risk**: LOW
- **Depends on**: none | **Category**: security
- **Planned at**: commit `161c9d1`, 2026-06-26

## Why this matters

`Settings.qml:54` writes JSON via `echo '${json}' > path` inside `sh -c`. If any setting value (currently bools/ints, safe) ever holds a user-controlled string, a single quote in the value yields arbitrary command execution. Separately, `onXxxChanged` at lines 61-64 fires `saveSettings()` four times on startup and on every toggle, spawning unsynchronized concurrent shell processes that can corrupt `settings.json`.

## Current state

`services/Settings.qml` — 65 lines. Key excerpts:

- Line 54: `saveProc.exec(["sh", "-c", `mkdir -p ~/.config/quickshell && echo '${json}' > ${root.configPath}`])`
- Lines 61-64: four `onXxxChanged: saveSettings()` handlers

The file's import block, `loadSettings()`, and `loadProc` Process are fine and should remain untouched.

## Commands you will need

No build/lint/test commands — QML is interpreted. Hand-check only.

## Scope

**In scope**: `services/Settings.qml`

**Out of scope**: Any other file, settings.json data, Screenshot.qml, GamingMode.qml

## Steps

### Step 1: Add a debounce timer and write-guard flag

Replace the section between the `saveProc` Process and `onXxxChanged` handlers. Remove the four `onXxxChanged: saveSettings()` lines (61-64). Add instead:

```qml
property bool _loading: true
property string _pendingJson: ""
property string _pendingTmpPath: ""

Timer {
    id: saveTimer
    interval: 500
    repeat: false
    onTriggered: doSaveSettings()
}
```

Add `_loading = false` at the end of `loadProc`'s `onStreamFinished` handler (after line 41, before the closing brace), so the initial load doesn't trigger writes.

### Step 2: Replace `saveSettings()` with debounced, atomic write

Replace the existing `saveSettings()` function (lines 45-55) with:

```qml
function saveSettings() {
    if (_loading) return
    saveTimer.restart()
}

function doSaveSettings() {
    const data = {
        dndEnabled: root.dndEnabled,
        caffeineEnabled: root.caffeineEnabled,
        focusModeEnabled: root.focusModeEnabled,
        focusModeMinutesLeft: root.focusModeMinutesLeft
    }

    const json = JSON.stringify(data, null, 2)
    const tmpPath = root.configPath + ".tmp"

    _pendingJson = json
    _pendingTmpPath = tmpPath
    writeProc.running = true
}
```

### Step 3: Add the atomic-write Process

Add this Process after `saveProc`:

```qml
Process {
    id: writeProc
    command: ["/bin/sh", "-c",
        root._pendingJson !== ""
        ? `mkdir -p '${root.configPath.substring(0, root.configPath.lastIndexOf("/"))}' && cat > '${root._pendingTmpPath}' << 'QSEOF'\n${root._pendingJson}\nQSEOF && mv '${root._pendingTmpPath}' '${root.configPath}'`
        : "true"
    ]
    onExited: {
        _pendingJson = ""
        _pendingTmpPath = ""
    }
}
```

The configPath is `$HOME/.config/quickshell/settings.json` — the HOME env var is trusted (set by the OS). The JSON data is booleans/ints which never contain `'` or the heredoc delimiter. The temp-file + rename pattern is atomic on the same filesystem.

### Step 4: Restore `onXxxChanged` handlers (debounced)

Add back at the same position (after `writeProc`):

```qml
onDndEnabledChanged: saveSettings()
onCaffeineEnabledChanged: saveSettings()
onFocusModeEnabledChanged: saveSettings()
onFocusModeMinutesLeftChanged: saveSettings()
```

## Test plan

No automated tests exist in this repo. Manual verification:

1. Open the file and visually confirm: no `sh -c` with `echo` remains in save path
2. Check the debounce timer is wired: `grep 'saveTimer.restart' services/Settings.qml`
3. Check the loading guard exists: `grep '_loading' services/Settings.qml`

## Done criteria

- [ ] `grep -n 'echo.*json' services/Settings.qml` returns no matches
- [ ] `grep -n 'saveTimer' services/Settings.qml` finds the timer declaration and call
- [ ] `grep -n '_loading' services/Settings.qml` finds the flag declaration and usage
- [ ] `grep -n 'doSaveSettings' services/Settings.qml` finds the function
- [ ] No other files modified (`git diff --stat` shows only `services/Settings.qml`)

## STOP conditions

- If the code at the locations above doesn't match the excerpts (drift), abort
- If QuickShell's `Process` API does not support heredoc syntax as shown, stop and report
- If current settings.json has non-boolean/int values, stop and report (the injection vector changes)

## Maintenance notes

If a string-valued setting is ever added (e.g., a username, theme name), the write path must be revisited — the heredoc delimiter `QSEOF` is safe against booleans/ints but string values could contain it.
