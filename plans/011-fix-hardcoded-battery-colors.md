# Plan 011: Fix hardcoded hex colors in Battery.qml

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md`.
>
> **Drift check (run first)**: `git diff --stat 259e77c..HEAD -- modules/bar/components/Battery.qml`
> If any in-scope file changed since this plan was written, compare the
> "Current state" excerpts against the live code before proceeding; on a
> mismatch, treat it as a STOP condition.

## Status

- **Priority**: P2
- **Effort**: S
- **Risk**: LOW
- **Depends on**: none
- **Category**: correctness
- **Planned at**: commit `259e77c`, 2026-06-27

## Why this matters

The project convention (documented in AGENTS.md) states: **"Never hardcode hex
colors."** All color tokens should come from `pywal.*` properties so that
theming works consistently when the user changes wallpapers. `Battery.qml`
hardcodes two colors: `#8FDEB4` (charging green) and `#000000` (text on the
expanded charging pill). This causes the battery indicator to ignore the
current pywal theme.

## Current state

The relevant lines in `modules/bar/components/Battery.qml`:

Line 62-63 — charging and liquid colors as hardcoded hex:
```qml
readonly property color chargingColor: "#8FDEB4"
readonly property color liquidColor: Qt.lighter("#8FDEB4", 1.2)
```

Line 301 — text color on the expanded charging pill as hardcoded black:
```qml
color: "#000000"
```

The rest of the file correctly uses `pywal.*` properties (e.g., line 56 uses
`pywal.error`, line 57 uses `pywal.warning`, lines 58-59 use
`pywal.foreground`). The file already imports the `pywal` service at line 17:
`readonly property var pywal: QsServices.Pywal`.

## Commands you will need

| Purpose   | Command                                           | Expected on success |
|-----------|---------------------------------------------------|---------------------|
| Check refs | `grep -n "#[0-9A-Fa-f]\{6\}" modules/bar/components/Battery.qml` | only comments or false positives remain |

## Scope

**In scope** (the only files you should modify):
- `modules/bar/components/Battery.qml`

**Out of scope** (do NOT touch):
- Any other `.qml` file — each may have its own color issues, but this plan
  is scoped to one file
- The `normalColor` property (line 55-60) — already uses `pywal.*` correctly

## Git workflow

- Branch: `advisor/011-fix-hardcoded-battery-colors`
- Commit message: `fix(battery): replace hardcoded hex colors with pywal tokens`
- Do NOT push or open a PR unless instructed.

## Steps

### Step 1: Replace `chargingColor` with `pywal.success`

Find line 62:
```qml
readonly property color chargingColor: "#8FDEB4"
```
Replace with:
```qml
readonly property color chargingColor: pywal.success
```

**Verify**: `grep "chargingColor" modules/bar/components/Battery.qml` shows the
new definition with `pywal.success`.

### Step 2: Replace `liquidColor` with `Qt.lighter(pywal.success, ...)`

Find line 63:
```qml
readonly property color liquidColor: Qt.lighter("#8FDEB4", 1.2)
```
Replace with:
```qml
readonly property color liquidColor: Qt.lighter(pywal.success, 1.2)
```

**Verify**: `grep "liquidColor" modules/bar/components/Battery.qml` shows
`Qt.lighter(pywal.success, 1.2)`.

### Step 3: Replace hardcoded `#000000` text color

Find line 301 (inside the `expandedPill`'s percentage `Text` element):
```qml
color: "#000000"
```
Replace with:
```qml
color: pywal.foreground
```

**Verify**: Read line ~301: `grep -n "foreground" modules/bar/components/Battery.qml`
should show the new reference.

### Step 4: Verify no remaining hardcoded hex in the file

**Verify**: `grep -n '"#[0-9A-Fa-f]\{6\}"' modules/bar/components/Battery.qml`
should return no matches (the only hex values are in comments or as part of
`Qt.rgba()` calls, which are not bare hex color strings).

## Test plan

No tests exist in this repo. After the change, the battery indicator should:
- Show `pywal.success` (green from pywal) when charging instead of hardcoded green
- Show `pywal.foreground` text on the expanded pill instead of black
- Survive a `quickshell` reload without errors

## Done criteria

Machine-checkable. ALL must hold:

- [ ] `grep -n 'chargingColor:' modules/bar/components/Battery.qml` contains `pywal.success`
- [ ] `grep -n 'liquidColor:' modules/bar/components/Battery.qml` contains `Qt.lighter(pywal.success, 1.2)`
- [ ] `grep -n '"#[0-9A-Fa-f]\{6\}"' modules/bar/components/Battery.qml` returns no matches
- [ ] No files outside `modules/bar/components/Battery.qml` are modified
- [ ] `plans/README.md` status row updated

## STOP conditions

Stop and report back (do not improvise) if:

- The code at the locations in "Current state" doesn't match the excerpts
  (drift from commit 259e77c)
- `pywal.success` doesn't exist in `services/Pywal.qml` — it does (line 75),
  but verify if unsure
- The hardcoded colors are no longer present (someone already fixed them)

## Maintenance notes

- If new visual indicators are added to `Battery.qml`, they should use
  `pywal.*` tokens, not hardcoded hex.
- The `pywal.success` token is defined in `services/Pywal.qml:75` and maps to
  `color2` (green). If the user prefers a different shade for charging, they
  could add a dedicated `pywal.charging` token in the future — that's out of
  scope here.
