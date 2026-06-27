# Plan 015: Extract BatteryMonitor warnLevels state tracking from config

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md`.
>
> **Drift check (run first)**: `git diff --stat 259e77c..HEAD -- modules/BatteryMonitor.qml`
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

`BatteryMonitor.qml:9-13` declares `warnLevels` as a `property list<var>` with
an array literal containing mutable objects. The `.warned` flag is mutated at
runtime (`_resetWarned` sets `false`, `onPercentageChanged` sets `true`).
Mutating objects living inside a QML property binding is fragile — the
mutation may be lost if the engine ever re-evaluates the binding (e.g. due to
property dependency tracking). Additionally, mixing config data (level, title,
message, icon) with runtime state (warned) makes the code harder to reason about.

The fix: split config from state. Keep `warnLevels` as a pure config array
(no `warned` field). Track warned state in a separate `_warnedLevels: Set<number>`
property. This is the same pattern used elsewhere in the codebase for runtime
state tracking (e.g., `services/Hyprland.qml` uses a `Set` for tracked workspaces).

## Current state

```qml
// modules/BatteryMonitor.qml:9-22
property list<var> warnLevels: [
    { level: 20, title: "Battery low", message: "Plug in soon", icon: "battery_alert", warned: false },
    { level: 10, title: "Battery very low", message: "Save your work", icon: "battery_alert", warned: false },
    { level: 5, title: "Battery critical", message: "Plug in now", icon: "battery_alert", warned: false }
]

function _resetWarned(): void {
    for (let i = 0; i < warnLevels.length; i++)
        warnLevels[i].warned = false
}
```

The `onPercentageChanged` handler (line 53-58) creates a shallow copy
(`[...warnLevels]`) and mutates `.warned` on elements, which mutates the
original objects in the property list. `_resetWarned` iterates and sets
`.warned = false` on each element.

## Commands you will need

| Purpose      | Command                   | Expected on success |
|--------------|---------------------------|---------------------|
| Reload QML   | `./reload-quickshell.sh`  | no startup errors   |

## Scope

**In scope** (the only file you should modify):
- `modules/BatteryMonitor.qml`

**Out of scope** (do NOT touch):
- Any other file
- The `criticalLevel`, `criticalActionDelayMs`, `criticalAction` properties
- The `_notify` function or `notifyProc` process

## Git workflow

- Branch: `advisor/015-fix-battery-monitor-warn-levels`
- Commit message: `refactor(battery): split warnLevels config from warned state tracking`
- Do NOT push or open a PR unless instructed.

## Steps

### Step 1: Strip `warned` from warnLevels and add `_warnedLevels` set

Replace the `warnLevels` property declaration and `_resetWarned` function
(lines 9-22) with:

```qml
property list<var> warnLevels: [
    { level: 20, title: "Battery low", message: "Plug in soon", icon: "battery_alert" },
    { level: 10, title: "Battery very low", message: "Save your work", icon: "battery_alert" },
    { level: 5, title: "Battery critical", message: "Plug in now", icon: "battery_alert" }
]

property var _warnedLevels: ({}) as var  // Record<number, boolean>

function _resetWarned(): void {
    _warnedLevels = ({}) as var
}
```

Key changes:
- Removed `warned: false` from each entry
- Added `_warnedLevels` as a plain JS object (used as a set/map)
- `_resetWarned` now creates a fresh empty object instead of iterating

**Verify**: Read lines 9-22 and confirm `warned` is gone from the entries
and `_warnedLevels` exists.

### Step 2: Update the `onPercentageChanged` handler

Replace the warn-level loop (lines 52-58) with:

```qml
// warn levels
const sorted = [...warnLevels].sort((a, b) => b.level - a.level)
for (let i = 0; i < sorted.length; i++) {
    const lvl = sorted[i]
    if (p <= lvl.level && !_warnedLevels[lvl.level]) {
        _warnedLevels[lvl.level] = true
        root._notify(lvl.title, `${lvl.message} (${p}%)`)
    }
}
```

Key change: `!lvl.warned` → `!_warnedLevels[lvl.level]`; `lvl.warned = true`
→ `_warnedLevels[lvl.level] = true`.

**Verify**: Read the updated loop and confirm no `.warned` property access.

## Test plan

No tests exist. Verification:

1. Unplug laptop — as battery drains to 20%, then 10%, then 5%, each should
   trigger exactly one notification (no repeats on subsequent ticks below
   the same threshold)
2. Plug in charger — notifications should be re-enabled (the `onOnBatteryChanged`
   handler calls `_resetWarned` which clears the set)
3. `./reload-quickshell.sh` → no startup errors

## Done criteria

Machine-checkable. ALL must hold:

- [ ] `grep -n "warned" modules/BatteryMonitor.qml` returns zero matches
- [ ] `grep -n "_warnedLevels" modules/BatteryMonitor.qml` matches at least
      the declaration and the two usage sites in the loop
- [ ] No files outside `modules/BatteryMonitor.qml` are modified
- [ ] `plans/README.md` status row updated

## STOP conditions

Stop and report back (do not improvise) if:

- The code at the locations in "Current state" doesn't match the excerpts
  (codebase has drifted since 259e77c)
- Battery notifications fire repeatedly at the same level (the state tracking
  is broken) — revert and report
- The `warnLevels` property binding is referenced from outside the file (grep
  for `BatteryMonitor.*warnLevels` in other files)

## Maintenance notes

- `_warnedLevels` uses level number as key (not object identity), matching
  the uniqueness constraint: each level appears at most once in warnLevels.
- If a new warn level is added to the config, it automatically gets fresh
  tracking (no `warned: false` to forget).
