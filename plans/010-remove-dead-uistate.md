# Plan 010: Remove dead UIState.qml singleton

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md`.
>
> **Drift check (run first)**: `git diff --stat 259e77c..HEAD -- services/UIState.qml services/qmldir`
> If any in-scope file changed since this plan was written, compare the
> "Current state" excerpts against the live code before proceeding; on a
> mismatch, treat it as a STOP condition.

## Status

- **Priority**: P2
- **Effort**: S
- **Risk**: LOW
- **Depends on**: none
- **Category**: tech-debt
- **Planned at**: commit `259e77c`, 2026-06-27

## Why this matters

`UIState.qml` is a 76-line registered singleton that is never imported by any
other file in the codebase (confirmed by `grep`). Its `PersistentProperties`
(`dndMode`, `powerProfile`) are stale — DND state is now managed by `Notifs.qml`
and power profiles by `PowerProfiles.qml`. Dead code wastes maintenance:
anyone modifying it assumes it has consumers, and the stale properties mislead
developers about where state lives.

## Current state

- `services/UIState.qml` — 76-line singleton with panel visibility state,
  popup tracking, and stale property aliases. **Never imported anywhere.**
- `services/qmldir:17` — line `singleton UIState UIState.qml`

The last line of `services/qmldir` as it exists today:
```qml
singleton UIState UIState.qml
```

This project's convention for singletons is registration in `services/qmldir`
with the pattern `singleton <Name> <Name>.qml`. No other file imports UIState.

## Commands you will need

| Purpose   | Command                                  | Expected on success |
|-----------|------------------------------------------|---------------------|
| Find refs | `grep -rn "UIState" --include="*.qml" .` | only results in `services/UIState.qml` and (after removal) no matches |

## Scope

**In scope** (the only files you should modify):
- `services/UIState.qml` — delete
- `services/qmldir` — remove the UIState line

**Out of scope** (do NOT touch, even though they look related):
- Any other service file — they all have live consumers
- `services/Logger.qml:74` — contains `QsServices.Logger.debug("UIState", ...)`;
  this is inside UIState itself, so it goes away with the file

## Git workflow

- Branch: `advisor/010-remove-dead-uistate`
- Commit message: `chore: remove dead UIState.qml singleton (unused)`
- Do NOT push or open a PR unless instructed.

## Steps

### Step 1: Remove `services/UIState.qml`

Delete the file `services/UIState.qml`.

**Verify**: `ls services/UIState.qml` → `ls: cannot access ... No such file or directory`

### Step 2: Remove the UIState line from `services/qmldir`

Open `services/qmldir` and delete the line `singleton UIState UIState.qml`.

After the change, the file should have 17 lines (was 18) and end with:
```qml
singleton Logger Logger.qml
singleton Bluetooth Bluetooth.qml
```

**Verify**: `grep -n "UIState" services/qmldir` → no output

### Step 3: Confirm no remaining references

**Verify**: `grep -rn "UIState" --include="*.qml" .` → no output

## Test plan

No tests exist in this repo (QML shell). Verification is done via the grep
commands above. After the deletion, a manual `quickshell` reload should still
start without error.

## Done criteria

Machine-checkable. ALL must hold:

- [ ] `ls services/UIState.qml` fails (file deleted)
- [ ] `grep -n "UIState" services/qmldir` returns no matches
- [ ] `grep -rn "UIState" --include="*.qml" .` returns no matches
- [ ] No files outside `services/UIState.qml` and `services/qmldir` are modified
      (`git status` shows only those two)
- [ ] `plans/README.md` status row updated

## STOP conditions

Stop and report back (do not improvise) if:

- Any file imports `QsServices.UIState` or otherwise references UIState —
  if so, the finding it's dead code is wrong; stop.
- The code at the locations in "Current state" doesn't match the excerpts
  (the codebase has drifted since this plan was written).

## Maintenance notes

- If a future developer adds a new central UI state singleton, they should
  put it in `services/`. The `UIState.qml` file name is now available.
- No follow-up required.
