# Plan 002: Screenshot — replace shell-piped clipboard writes

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md`.
>
> **Drift check**: `git diff --stat 161c9d1..HEAD -- services/Screenshot.qml`
> If changed, compare the excerpts below against live code before proceeding.

## Status

- **Priority**: P1 | **Effort**: S | **Risk**: LOW
- **Depends on**: none | **Category**: security
- **Planned at**: commit `161c9d1`, 2026-06-26

## Why this matters

`Screenshot.qml:107` and `:187` run `wl-copy < "${lastScreenshotPath}"` inside `sh -c`. If `screenshotsDir` (user-configurable via `shell.json`) contains shell metacharacters (spaces, quotes, $), this yields command injection. The fix removes the `sh -c` wrapper and feeds the file content via `Process` stdin.

## Current state

`services/Screenshot.qml` — 209 lines. Two locations:

- Line 107: `clipboardProc.exec(["sh", "-c", `wl-copy < "${root.lastScreenshotPath}"`])`
- Line 187: `copyProc.exec(["sh", "-c", `wl-copy < "${lastScreenshotPath}"`])`

Both `clipboardProc` and `copyProc` are simple `Process { id: ... }` objects with no configuration.

## Scope

**In scope**: `services/Screenshot.qml`

**Out of scope**: Any other file. `windowGeomProc` at line 47 (`hyprctl | jq | paste`) is a separate concern.

## Steps

### Step 1: Rewrite the `clipboardProc` (lines 107, 121-123)

Replace:

```qml
clipboardProc.exec(["sh", "-c", `wl-copy < "${root.lastScreenshotPath}"`])
```

With:

```qml
const content = root.readFileSync(root.lastScreenshotPath)
clipboardProc.exec(["wl-copy"], content)
```

Wait — QML `Process` doesn't have a stdin-write API exposed in all QuickShell versions. Safer approach: use an `execDetached` with array args for `wl-copy`, piping via a helper.

**Actually**, the most portable QML-safe fix: replace the `sh -c` with array-form `cat` piped in a way that avoids shell interpretation. Use:

```qml
clipboardProc.exec([
    "sh", "-c",
    `exec wl-copy < "${root.lastScreenshotPath}"`
])
```

No — this still uses shell for `<`. Let me think.

The safest approach with the QuickShell Process API: use `Process` with `stdout` being piped into `wl-copy` via stdin. But QuickShell's `Process` doesn't expose stdin writing through a simple API.

The **practical** fix that eliminates the injection vector without changing the architecture: escape the path for shell. But that's whack-a-mole.

Better approach: write the file path via a temp argument that avoids interpretation. Since `wl-copy` can read from stdin, use:

```qml
// Read file content directly into clipboard by running:
// cat filepath | wl-copy
// But as array to avoid shell interpretation of the pipe:
clipboardProc.command = ["/bin/sh", "-c", "exec wl-copy < \"$1\"", "_", root.lastScreenshotPath]
clipboardProc.exec()
```

This uses positional arguments (`$1`) within a quoted string in `sh -c`, which avoids shell interpretation of the filename. Wait, that's fragile too.

The **correct** approach for QuickShell/Process: there is no stdin piping API. So the right fix is:

```qml
var filepath = root.lastScreenshotPath
clipboardProc.exec(["sh", "-c", "wl-copy < \"$1\"", "_", filepath])
```

This passes `filepath` as `$1` to the shell command, and the double-quoted `$1` prevents shell word-splitting and glob expansion. The `filepath` value itself could still contain a command substitution if it has `$()` — but `"$1"` prevents that. Actually, in shell, `"$1"` only prevents word splitting and globbing; command substitution can still happen if `$1` contains `$(...)`. Wait no — `$1` is a shell variable, not subject to further expansion inside double quotes? Actually it IS — `"$1"` expands the variable but does NOT perform word splitting or glob expansion. So if `$1` has value `foo $(echo bar)`, the `$(echo bar)` is NOT re-evaluated because variable expansion happens after quote removal and the result is not re-interpreted for expansions. 

So: `wl-copy < "$1"` with `$1` being the filepath is safe against injection. The filepath would need to contain `"` itself to break out, and those are filtered by `screenshotsDir` path validation (or are rare).

Actually, the simplest truly safe approach: avoid `sh -c` entirely. Use:

```qml
clipboardProc.command = ["wl-copy"]
// Then pipe via reading the file content...
```

But since QuickShell Process doesn't expose stdin, we can't.

Let me just use the array-form with positional argument, which is the standard safe pattern:

```qml
clipboardProc.exec(["sh", "-c", "wl-copy", "sh", "<", root.lastScreenshotPath])
```

No, that's wrong — `<` is a shell redirect, not an argument.

OK, the **simplest** and **truly safe** approach: don't use shell at all. Use a two-step:

```qml
// Read file content manually
clipboardProc.exec(["sh", "-c", "cat \"$1\" | wl-copy", "_", root.lastScreenshotPath])
```

Here, `$1` is inside double quotes inside the single-quoted `sh -c` string... wait, the template literal still expands.

Let me think about this differently. The current code is:
```qml
clipboardProc.exec(["sh", "-c", `wl-copy < "${root.lastScreenshotPath}"`])
```

The fix should be:
```qml
var path = root.lastScreenshotPath
clipboardProc.exec(["sh", "-c", "wl-copy < \"$1\"", "sh", path])
```

Here the `sh -c` command is `wl-copy < "$1"` — this is a hardcoded string with `$1` as a shell parameter. The path is passed as a separate argument. Since `$1` is inside double quotes, it protects against word splitting and glob expansion. Command substitution inside `$1` won't happen because `$1` is a variable and the shell doesn't perform recursive command substitution on expanded variables (variable expansion happens during parameter expansion, and the result is not subject to further expansions).

This is the standard safe pattern used everywhere in shell scripting. Let me use this.

### Step 2: Rewrite the `copyProc` (line 187, 190-192)

Same pattern as step 1.

### Step 3: Remove `import QtQuick.Effects` if it becomes unused

(Not relevant here — Screenshot.qml doesn't import QtQuick.Effects.)

## Steps

### Step 1: Replace the two shell-piped clipboard calls

Replace line 107:
```qml
clipboardProc.exec(["sh", "-c", `wl-copy < "${root.lastScreenshotPath}"`])
```
with:
```qml
var path = root.lastScreenshotPath
clipboardProc.exec(["sh", "-c", "wl-copy < \"$1\"", "sh", path])
```

Replace line 187:
```qml
copyProc.exec(["sh", "-c", `wl-copy < "${lastScreenshotPath}"`])
```
with:
```qml
var path = lastScreenshotPath
copyProc.exec(["sh", "-c", "wl-copy < \"$1\"", "sh", path])
```

**Verify**: 
```bash
grep -n 'sh -c.*wl-copy' services/Screenshot.qml
```
Expected: zero matches (the old inline template literals are gone).

Check the new pattern:
```bash
grep -n '"wl-copy < \\"$1\\""' services/Screenshot.qml
```
Expected: 2 matches (one per location).

## Test plan

Manual verification:
1. Take a screenshot (trigger the `screenshotProc.onExited` path) — the clipboard copy should succeed
2. Call `copyLastScreenshot()` — clipboard copy should succeed
3. Check that a path with spaces still works (set screenshotsDir to a path with spaces)

## Done criteria

- [ ] `grep -c 'sh -c.*wl-copy.*lastScreenshot' services/Screenshot.qml` returns 0
- [ ] `grep -c 'wl-copy < \\"\\$1\\"' services/Screenshot.qml` returns 2
- [ ] No other files modified (`git diff --stat` shows only `services/Screenshot.qml`)

## STOP conditions

- If the code at the cited lines doesn't match the excerpts, stop and report
- If QuickShell doesn't support positional arguments in `sh -c` array form, stop and report

## Maintenance notes

The `windowGeomProc` at line 47 still uses shell (`hyprctl | jq | paste`) — this is a separate concern (the output is parsed, not used as command input). It can be addressed separately if needed.
