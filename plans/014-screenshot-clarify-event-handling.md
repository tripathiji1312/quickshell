# Plan 014: Simplify screenshot event handlers for clarity and ordering independence

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md`.
>
> **Drift check (run first)**: `git diff --stat 259e77c..HEAD -- services/Screenshot.qml`
> If any in-scope file changed since this plan was written, compare the
> "Current state" excerpts against the live code before proceeding; on a
> mismatch, treat it as a STOP condition.

## Status

- **Priority**: P3
- **Effort**: S
- **Risk**: LOW
- **Depends on**: none
- **Category**: tech-debt
- **Planned at**: commit `259e77c`, 2026-06-27

## Why this matters

The `slurpProc` and `windowGeomProc` Process objects in Screenshot.qml use a
fragile two-step pattern: stdout is captured in `StdioCollector.onStreamFinished`
(stored to a temp property), then read in `onExited`. The handlers use deep
nesting with a shared mutable property (`_slurpGeometry`, `_windowGeomText`),
making the flow hard to follow and resilient only if `onStreamFinished`
always fires before `onExited` (which is guaranteed by Qt/QuickShell today,
but is an internal detail the code shouldn't rely on for correctness).

Refactoring both handlers to use early-exit guard clauses and self-contained
logic makes the code more readable and robust.

## Current state

Two Process objects use the same fragile pattern in
`services/Screenshot.qml`:

`slurpProc` (lines 52-72):
```qml
Process {
    id: slurpProc
    stdout: StdioCollector {
        onStreamFinished: root._slurpGeometry = text.trim()
    }
    onExited: code => {
        const geometry = root._slurpGeometry
        root._slurpGeometry = ""
        if (code === 0 && geometry !== "") {
            // ... generate filename, call grim
        } else if (code !== 0) {
            QsServices.Logger.error("Screenshot", `slurp failed with code: ${code}`)
        }
    }
}
```

`windowGeomProc` (lines 75-98) — identical pattern with `_windowGeomText`:
```qml
Process {
    id: windowGeomProc
    stdout: StdioCollector {
        onStreamFinished: root._windowGeomText = text.trim()
    }
    onExited: code => {
        const out = root._windowGeomText
        root._windowGeomText = ""
        if (code === 0 && out !== "") {
            // ... parse geometry, call grim
        } else if (code !== 0) {
            QsServices.Logger.error("Screenshot", `window geometry failed with code: ${code}`)
        }
    }
}
```

Both templates use a shared property to bridge stdout → exit handler, and
mix error handling with business logic in a nested if/else.

The project convention (from AGENTS.md) is to use early returns and clear
guard clauses. The existing `Screenshot.qml` file uses this convention for
other functions (e.g., `stopRecording()` returns early if not recording).

## Commands you will need

| Purpose      | Command                   | Expected on success |
|--------------|---------------------------|---------------------|
| Reload QML   | `./reload-quickshell.sh`  | no startup errors   |

## Scope

**In scope** (the only files you should modify):
- `services/Screenshot.qml`

**Out of scope** (do NOT touch):
- The `screenshotProc` and `clipboardProc` — they use a different pattern
- The `_slurpGeometry` and `_windowGeomText` property declarations

## Git workflow

- Branch: `advisor/014-screenshot-clarify-event-handling`
- Commit message: `refactor(screenshot): simplify slurp/window-geom handlers with early returns`
- Do NOT push or open a PR unless instructed.

## Steps

### Step 1: Refactor `slurpProc` to use early-return guards

Replace the body of `slurpProc` (lines 52-72) with:

```qml
Process {
    id: slurpProc
    stdout: StdioCollector {
        onStreamFinished: root._slurpGeometry = text.trim()
    }
    onExited: code => {
        const geometry = root._slurpGeometry
        root._slurpGeometry = ""

        if (code !== 0) {
            QsServices.Logger.error("Screenshot", `slurp failed with code: ${code}`)
            return
        }
        if (geometry === "") {
            return
        }

        const timestamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 19)
        const filename = `screenshot-${timestamp}.png`
        const filepath = `${root.screenshotsDir}/${filename}`

        QsServices.Logger.debug("Screenshot", `Capturing region: ${geometry}`)
        screenshotProc.exec(["grim", "-g", geometry, filepath])
        root.lastScreenshotPath = filepath
    }
}
```

Key changes:
- Exit code check is now an early return guard (cleaner than nested if/else)
- Empty geometry check is a separate early return
- Business logic (capturing) follows at the top level

**Verify**: Read lines ~52-71 of the file and confirm the `onExited` handler
uses early returns (no nested `if (code === 0 && geometry !== "")`).

### Step 2: Refactor `windowGeomProc` to use early-return guards

Replace the body of `windowGeomProc` (lines 75-98) with:

```qml
Process {
    id: windowGeomProc
    stdout: StdioCollector {
        onStreamFinished: root._windowGeomText = text.trim()
    }
    onExited: code => {
        const out = root._windowGeomText
        root._windowGeomText = ""

        if (code !== 0) {
            QsServices.Logger.error("Screenshot", `window geometry failed with code: ${code}`)
            return
        }
        if (out === "") {
            return
        }

        const parts = out.split(' ')
        if (parts.length !== 4) {
            QsServices.Logger.warn("Screenshot", `Unexpected window geometry format: ${out}`)
            return
        }

        const timestamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 19)
        const filename = `screenshot-${timestamp}.png`
        const filepath = `${root.screenshotsDir}/${filename}`
        const geometry = `${parts[0]},${parts[1]} ${parts[2]}x${parts[3]}`

        QsServices.Logger.debug("Screenshot", `Capturing window: ${geometry}`)
        screenshotProc.exec(["grim", "-g", geometry, filepath])
        root.lastScreenshotPath = filepath
    }
}
```

Key changes:
- Same early-return pattern as step 1
- Added a guard for unexpected geometry format (`parts.length !== 4`)
- Business logic at the top level

**Verify**: Read lines ~75-98 and confirm early-return guards.

## Test plan

No tests exist. Verification:

1. Full-screen screenshot: click the Screenshot toggle in Control Center →
   should capture and save
2. Window screenshot: `Screenshot.takeScreenshot("window")` from the
   JavaScript console or via any trigger → should capture active window
3. Region screenshot: `Screenshot.takeScreenshot("region")` → should prompt
   slurp, then capture selection
4. `./reload-quickshell.sh` → no startup errors

## Done criteria

Machine-checkable. ALL must hold:

- [ ] `grep "if (code === 0 &&" services/Screenshot.qml` returns no matches
      (the old nested-if pattern is gone)
- [ ] Both `slurpProc` and `windowGeomProc` handlers use `if (code !== 0)`
      as an early return
- [ ] No files outside `services/Screenshot.qml` are modified
- [ ] `plans/README.md` status row updated

## STOP conditions

Stop and report back (do not improvise) if:

- The code at the locations in "Current state" doesn't match the excerpts
  (codebase has drifted since 259e77c)
- The early-return refactor causes a screenshot mode to stop working —
  revert that handler and report
- A new Process with the same two-handler pattern exists in the file that
  wasn't listed in scope

## Maintenance notes

- Future Process objects that read stdout and process on exit should use
  the same early-return pattern: error guard first, then empty-data guard,
  then business logic.
- The `_slurpGeometry`/`_windowGeomText` temp properties are still needed
  to bridge `StdioCollector` → `onExited` in QML's Process API. This is
  the standard QML pattern for two-handler Process objects.
