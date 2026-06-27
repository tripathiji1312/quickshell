# Plan 012: Consolidate SystemUsage shell processes

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md`.
>
> **Drift check (run first)**: `git diff --stat 259e77c..HEAD -- services/SystemUsage.qml`
> If any in-scope file changed since this plan was written, compare the
> "Current state" excerpts against the live code before proceeding; on a
> mismatch, treat it as a STOP condition.

## Status

- **Priority**: P3
- **Effort**: M
- **Risk**: MED
- **Depends on**: none
- **Category**: perf
- **Planned at**: commit `259e77c`, 2026-06-27

## Why this matters

`SystemUsage.qml` launches 5+ independent shell processes every 2 seconds:
CPU (`cat /proc/stat | grep`), memory (`free -b | grep`), network
(`cat /proc/net/dev | awk`), disk (`df -B1 | tail`), GPU detection/monitoring,
and top processes (`ps aux`). Each Process object spawns a new `/bin/sh`
process. This adds up to ~10 shell spawns per second on a system that's always
monitoring these metrics in the bar and dashboard. Consolidating the three
`/proc`-based reads (CPU, memory, network) into a single pipeline cuts the
process count by ~40% with minimal code change.

## Current state

Three separate Process objects in `services/SystemUsage.qml` that all run
every tick (every 2 seconds):

Lines 100-129 — `cpuProcess`:
```qml
Process {
    id: cpuProcess
    command: ["/bin/sh", "-c", "cat /proc/stat | grep '^cpu '"]
    running: false
    stdout: SplitParser {
        onRead: data => {
            const parts = data.trim().split(/\s+/)
            if (parts.length >= 5) {
                // ... parses user/nice/system/idle, computes cpuPerc
            }
        }
    }
}
```

Lines 131-146 — `memProcess`:
```qml
Process {
    id: memProcess
    command: ["/bin/sh", "-c", "free -b | grep Mem"]
    // ... parses into memTotal, memUsed
}
```

Lines 165-199 — `networkProcess`:
```qml
Process {
    id: networkProcess
    command: ["/bin/sh", "-c", "cat /proc/net/dev | tail -n +3 | awk '{rx+=$2; tx+=$10} END {print rx\" \"tx}'"]
    // ... parses rxBytes, txBytes, computes downloadSpeed/uploadSpeed
}
```

Three separate functions trigger them (lines 59-73):
```qml
function updateCpu()     { cpuProcess.running = true }
function updateMemory()   { memProcess.running = true }
function updateNetwork()  { networkProcess.running = true }
```

All three called on every timer tick (lines 317-320):
```qml
onTriggered: {
    tickCount++
    updateCpu()
    updateMemory()
    updateNetwork()
    // ... disk, gpu, top processes
}
```

The `diskProcess`, GPU processes (`gpuDetectProc`, `nvidiaGpuProc`,
`amdGpuProc`, `intelGpuProc`), and `topProcessesProc` are out of scope —
they run on staggered schedules (every 6–10s) and use different CLI tools
that don't share a `/proc` source.

## Commands you will need

| Purpose      | Command                                                         | Expected on success  |
|--------------|-----------------------------------------------------------------|----------------------|
| Check syntax | `quickshell` (manual reload with `./reload-quickshell.sh`)       | no errors            |

(No build/typecheck — this is QML loaded at runtime.)

## Scope

**In scope** (the only files you should modify):
- `services/SystemUsage.qml`

**Out of scope** (do NOT touch):
- The `diskProcess`, GPU processes, and `topProcessesProc` — they have
  different CLI patterns and run less frequently
- The `formatBytes()` helper
- The `networkHistory` tracking (speed history for the graph is used by
  `NetworkGraph.qml` in components/)
- Any consumer of SystemUsage properties (`cpuPerc`, `memPerc`, etc.) —
  property names and types must remain identical

## Git workflow

- Branch: `advisor/012-consolidate-systemusage-processes`
- Commit message: `perf(systemusage): consolidate CPU/memory/network into one shell pipeline`
- Do NOT push or open a PR unless instructed.

## Steps

### Step 1: Replace the three separate processes with one combined process

Delete the three Process objects:
- `cpuProcess` (lines 100-129)
- `memProcess` (lines 131-146)
- `networkProcess` (lines 165-199)

Insert a single `sysStatsProcess` in their place (after the `formatBytes()`
function, before the `gpuDetectProc`). Use a shell pipeline that outputs all
three data sets separated by sentinel markers:

```qml
Process {
    id: sysStatsProcess
    command: ["/bin/sh", "-c", "cat /proc/stat | grep '^cpu ' && echo '---MEM---' && free -b | grep Mem && echo '---NET---' && cat /proc/net/dev | tail -n +3 | awk '{rx+=$2; tx+=$10} END {print rx\" \"tx}'"]
    running: false

    stdout: StdioCollector {
        onStreamFinished: {
            const sections = text.split('---MEM---\n')
            if (sections.length < 2) return

            // --- Parse CPU (first section) ---
            const cpuData = sections[0].trim()
            const cpuParts = cpuData.split(/\s+/)
            if (cpuParts.length >= 5) {
                const user = parseInt(cpuParts[1])
                const nice = parseInt(cpuParts[2])
                const system = parseInt(cpuParts[3])
                const idle = parseInt(cpuParts[4])
                const total = user + nice + system + idle

                if (root.lastCpuTotal > 0) {
                    const totalDiff = total - root.lastCpuTotal
                    const idleDiff = idle - root.lastCpuIdle
                    if (totalDiff > 0) {
                        root.cpuPerc = 1 - (idleDiff / totalDiff)
                    }
                }

                root.lastCpuIdle = idle
                root.lastCpuTotal = total
            }

            // --- Parse memory (between ---MEM--- and ---NET---) ---
            const memAndNet = sections[1].split('---NET---\n')
            const memData = memAndNet[0].trim()
            const memParts = memData.split(/\s+/)
            if (memParts.length >= 3) {
                root.memTotal = parseInt(memParts[1])
                root.memUsed = parseInt(memParts[2])
            }

            // --- Parse network (after ---NET---) ---
            if (memAndNet.length >= 2) {
                const netData = memAndNet[1].trim()
                const netParts = netData.split(/\s+/)
                if (netParts.length >= 2) {
                    const rxBytes = parseInt(netParts[0])
                    const txBytes = parseInt(netParts[1])
                    const currentTime = Date.now() / 1000

                    if (root.lastNetTime > 0) {
                        const timeDiff = currentTime - root.lastNetTime
                        if (timeDiff > 0) {
                            root.downloadSpeed = (rxBytes - root.lastRxBytes) / timeDiff
                            root.uploadSpeed = (txBytes - root.lastTxBytes) / timeDiff

                            root.networkHistory.push({download: root.downloadSpeed, upload: root.uploadSpeed})
                            if (root.networkHistory.length > 30) {
                                root.networkHistory.shift()
                            }
                            root.networkHistoryChanged()
                        }
                    }

                    root.lastRxBytes = rxBytes
                    root.lastTxBytes = txBytes
                    root.lastNetTime = currentTime
                }
            }
        }
    }
}
```

**Verify**: The file should have one Process object named `sysStatsProcess`
instead of three separate objects named `cpuProcess`, `memProcess`, and
`networkProcess`.

### Step 2: Update the trigger functions

Replace `updateCpu()`, `updateMemory()`, and `updateNetwork()` with a single
`updateSysStats()`:

```qml
function updateSysStats() {
    if (!sysStatsProcess.running)
        sysStatsProcess.running = true
}
```

Delete these three functions:
- `function updateCpu()     { cpuProcess.running = true }`
- `function updateMemory()   { memProcess.running = true }`
- `function updateNetwork()  { networkProcess.running = true }`

**Verify**: `grep -n "updateCpu\|updateMemory\|updateNetwork" services/SystemUsage.qml`
should return no matches.

### Step 3: Update the timer's onTriggered

Replace the three calls in `onTriggered` (lines 317-320):
```qml
updateCpu()
updateMemory()
updateNetwork()
```
With a single call:
```qml
updateSysStats()
```

**Verify**: Read lines ~314-336 of the file. The first three lines of
`onTriggered` after `tickCount++` should be a single `updateSysStats()` call.

### Step 4: Clean up `Component.onCompleted`

Replace the three calls in `Component.onCompleted` (lines 48-53):
```qml
updateCpu()
updateMemory()
updateNetwork()
```
With:
```qml
updateSysStats()
```

**Verify**: `grep -n "updateSysStats\|updateCpu\|updateMemory\|updateNetwork" services/SystemUsage.qml`
should show only `updateSysStats` and no references to the old function names.

## Test plan

No tests exist in this repo. Verification is done by:
1. Manual QML reload: `./reload-quickshell.sh` — no startup errors
2. Observing that `cpuPerc`, `memPerc`, and `downloadSpeed`/`uploadSpeed`
   in the bar (SystemUsage bar component) and dashboard update correctly
3. The `networkHistory` array should still populate correctly for the
   NetworkGraph component

## Done criteria

Machine-checkable. ALL must hold:

- [ ] `grep -n "cpuProcess\|memProcess\|networkProcess" services/SystemUsage.qml` returns no matches
- [ ] `grep -n "updateCpu\|updateMemory\|updateNetwork" services/SystemUsage.qml` returns no matches
- [ ] `grep -n "sysStatsProcess" services/SystemUsage.qml` matches the new Process definition
- [ ] `grep -n "updateSysStats" services/SystemUsage.qml` matches the new function
- [ ] No files outside `services/SystemUsage.qml` are modified
- [ ] `plans/README.md` status row updated

## STOP conditions

Stop and report back (do not improvise) if:

- The code at the locations in "Current state" doesn't match the excerpts
  (codebase has drifted since 259e77c)
- The combined shell command fails when tested manually:
  ```bash
  bash -c "cat /proc/stat | grep '^cpu ' && echo '---MEM---' && free -b | grep Mem && echo '---NET---' && cat /proc/net/dev | tail -n +3 | awk '{rx+=\$2; tx+=\$10} END {print rx\" \"tx}'"
  ```
  (Run this in a terminal to verify the pipeline produces correct output.)
- The network speed tracking breaks (check that `downloadSpeed`/`uploadSpeed`
  still have non-zero values when network activity exists)
- Any SystemUsage consumer incorrectly shows `0` or `NaN` values after the change

## Maintenance notes

- If a new `/proc`-based metric is added (e.g., network interface-specific
  stats, per-process memory), it should be added to the combined pipeline
  with its own sentinel marker rather than creating a new Process object.
- The `running: false` guard in `updateSysStats()` prevents queueing a second
  request if the first is still running — important since the single pipeline
  takes slightly longer than any individual command.
- The sentinel markers `---MEM---` and `---NET---` must not appear in the
  actual output of the preceding commands (they won't, since /proc files
  don't contain these strings).
- The existing `diskProcess`, GPU processes, and `topProcessesProc` remain
  unchanged. They could be consolidated in a future plan, but their staggered
  schedules make the benefit marginal.
