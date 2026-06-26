# QuickShell Config — Agent Guide

## Architecture

QML-only desktop shell for Hyprland/Wayland using QuickShell v0.2+ / Qt 6.10.

```
shell.qml → BarWrapper.qml (panel per monitor) → Bar.qml
          → ControlCenterWindow.qml
          → LauncherWindow.qml
          → SidebarWindow.qml
          → DashboardWindow.qml
          → NotificationPopups.qml
          → OSD (VolumeOSD + BrightnessOSD)
          → BatteryMonitor.qml
```

## Module imports

| Path | Module name | Usage |
|------|-------------|-------|
| `services/` | `import "../../services" as QsServices` | 18 singletons |
| `config/` | `import "../../config" as QsConfig` | Config, AppearanceConfig |
| `components/` | `import "../../components"` | Reusable UI primitives |
| `components/effects/` | `import "../../components/effects"` | Material3Anim |

## Service pattern

All services are QML `pragma Singleton` with `Process` objects for CLI calls.
Services use `Timer`-based polling or `Connections` for event-driven updates.

```qml
// services/Foo.qml
pragma Singleton
import Quickshell
import Quickshell.Io
Singleton {
    id: root
    property bool active: true  // consumer visibility control
    Timer {
        interval: 2000
        running: root.active
        repeat: true
        onTriggered: pollProc.running = true
    }
    Process {
        id: pollProc
        command: ["some-cli", "--arg"]
        stdout: StdioCollector { onStreamFinished: { /* parse */ } }
    }
}
```

## Config

- `shell.json` — user config, hot-reloaded via `FileView` in `Config.qml`
- `settings.json` — persisted toggle states via `Settings.qml` (debounced atomic write)
- `AppearanceConfig.qml` — design tokens (not hot-reloadable)
- Colors come from `Pywal.qml` (reads `~/.cache/wal/colors.json`)

## Color tokens

Use `pywal.primary`, `pywal.surfaceContainerHigh`, `pywal.outlineVariant`, etc.
Never hardcode hex colors.

## Theming

All colors and material tokens come exclusively from `pywal`:
- `pywal.surfaceContainerHighest` — main surface
- `pywal.primary` — accent
- `pywal.foreground` — text
- `pywal.outlineVariant` — borders
- `pywal.error`, `pywal.warning`, `pywal.success`, `pywal.info` — semantic

## Error handling

Use `QsServices.Logger.debug/info/warn/error(name, message)` from any file.
Debug output requires `QS_DEBUG=1` env var.

## Style conventions

- All QML files: `import QtQuick 6.10`
- Properties: camelCase (e.g., `shouldShow`, `closeSidebar`)
- Components: PascalCase filenames (e.g., `AuroraSurface.qml`, `IconButton.qml`)
- Services: PascalCase matching export name (e.g., `Audio.qml`, `Network.qml`)
- Use `??` for defaults, `?.` for optional chaining
- Use `Loader` with `asynchronous: true` for lazy loading
- Avoid `sh -c` with template literals for shell commands — use positional args

## Shell command safety

DANGEROUS — DO NOT use:
```qml
proc.exec(["sh", "-c", `echo '${userData}' > /path`])  // injection if userData contains '
```

SAFE pattern:
```qml
proc.exec(["sh", "-c", "printf '%s' \"$1\" > \"$2\"", "sh", userData, path])
```
