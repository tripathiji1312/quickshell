# QuickShell Configuration

![Qt](https://img.shields.io/badge/Qt-6.10+-41cd52?style=for-the-badge&logo=qt&logoColor=white)
![Wayland](https://img.shields.io/badge/Wayland-Supported-blue?style=for-the-badge&logo=wayland&logoColor=white)
![Hyprland](https://img.shields.io/badge/Hyprland-Optimized-00a4a6?style=for-the-badge&logo=archlinux&logoColor=white)

A modular desktop shell configuration built with [QuickShell](https://quickshell.org/) and QtQuick, designed for Wayland compositors and tuned for Hyprland.

The project focuses on:
- clean component boundaries (`components/`, `modules/`, `services/`)
- dynamic theming via `pywal`
- responsive UI behavior with smooth QML/scenegraph rendering
- practical day-to-day features (OSD, notifications, launcher, dashboard, sidebar)

## Table of Contents

- [Screenshots](#screenshots)
- [Core Capabilities](#core-capabilities)
- [Architecture](#architecture)
- [Requirements](#requirements)
- [Installation](#installation)
- [Running and Reloading](#running-and-reloading)
- [Configuration Reference](#configuration-reference)
- [Hyprland Integration](#hyprland-integration)
- [Project Layout](#project-layout)
- [Troubleshooting](#troubleshooting)
- [Contributing & Code of Conduct](#contributing--code-of-conduct)
- [License](#license)
- [Security](#security)


## Contributing & Code of Conduct

- See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines, PR process, and testing instructions.
- See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) for expected community behavior and reporting guidance.

## Security

- See [SECURITY.md](SECURITY.md) for how to report security vulnerabilities and the project's response process.
- Preferred disclosure path: GitHub Security Advisories. Do not publicly disclose confirmed vulnerabilities until a fix or coordinated disclosure is available.

## Screenshots

| Main Desktop | Control Center + Popups | Notifications |
|:-----------:|:------------------------:|:-------------:|
| ![Desktop](./image_quick/main_config.png) | ![Control Center](./image_quick/bluetooth.png) | ![Notifications](./image_quick/notification.png) |

## Core Capabilities

- Dynamic wallpaper-driven color integration using `pywal`
- Persistent shell modules for bar, OSD, notifications, dashboard, launcher, and sidebar
- Notification server support (configurable) with action/image support
- Service layer for audio, brightness, Bluetooth, network, battery, and player state
- Hardware-accelerated QML transitions and shader-backed visual effects

## Architecture

The shell entry point is `shell.qml`, which wires core services and top-level windows/loaders.

- `components/`: reusable primitives (buttons, elevation, flickable/list wrappers, effects)
- `modules/`: product-level UI areas (bar, control center, dashboard, launcher, notifications, OSD)
- `services/`: system integrations and data providers
- `config/`: typed QML config accessors and appearance tokens
- `shell.json`: user-tunable runtime configuration loaded by `config/Config.qml`

This separation keeps UI concerns, system logic, and user settings independent and easier to maintain.

## Requirements

### Runtime

- QuickShell `v0.2+`
- Qt `6.10+`
- Wayland compositor (Hyprland recommended)

### Core Packages/Services

| Dependency | Purpose |
|---|---|
| `python-pywal` | dynamic theme generation (`~/.cache/wal/colors.json`) |
| `pipewire`, `wireplumber`, `pamixer`, `playerctl` | audio control and media metadata |
| `networkmanager` | network state and controls |
| `bluez`, `bluez-utils` | Bluetooth state and device management |
| `upower`, `power-profiles-daemon` | battery and power profile integration |
| `grim`, `slurp` | Wayland screenshots |
| `brightnessctl` | display brightness control |

## Installation

### 1. Clone into your config path

```bash
cd ~/.config
git clone git@github.com:tripathiji1312/quickshell.git
cd quickshell
```

### 2. Run the setup script (Arch Linux)

The script checks/install missing dependencies, validates QuickShell availability, verifies `pywal`, and appends Hyprland layer config when needed.

```bash
chmod +x setup.sh
./setup.sh
```

### 3. Generate `pywal` colors (first run)

```bash
wal -i /path/to/wallpaper
```

Without this step, theme-dependent colors can appear missing.

## Running and Reloading

Start manually:

```bash
quickshell
```

Reload safely after changes:

```bash
./reload-quickshell.sh
```

The reload script:
- stops existing `quickshell` instances
- force-kills only if needed
- launches a fresh background instance

Autostart with Hyprland:

```hyprlang
exec-once = quickshell
```

## Configuration Reference

The runtime config file is `shell.json`.

### Important keys

- `appearance.fontFamily`, `appearance.materialIconFont`
- `paths.pywalColors`, `paths.screenshotsDir`
- `osd.volumeTimeoutMs`, `osd.brightnessTimeoutMs`
- `notifications.popupWidth`, `notifications.maxVisible`, `notifications.timeoutMs`, `notifications.registerServer`
- `launcher.enabled`, `launcher.width`, `launcher.maxResults`, `launcher.terminalCommand`, `launcher.favorites`
- `sidebar.enabled`, `sidebar.width`, `sidebar.maxHistory`
- `dashboard.enabled`, `dashboard.width`, `dashboard.height`

Changes are watched and reloaded by `config/Config.qml` through `FileView`.

## Hyprland Integration

The setup script can append the following line to your Hyprland config:

```hyprlang
source = ~/.config/quickshell/hyprland-layer-config.conf
```

If you prefer manual setup, add it yourself to `~/.config/hypr/hyprland.conf`.

## Project Layout

```text
~/.config/quickshell/
├── assets/                    # icons, images, shaders
├── components/                # reusable QML primitives and effects
├── config/                    # config singletons and design tokens
├── modules/                   # shell features (bar, OSD, dashboard, etc.)
├── services/                  # system integrations and state providers
├── shell.json                 # user settings
├── shell.qml                  # shell entry point
├── reload-quickshell.sh       # safe shell restart helper
├── setup.sh                   # dependency + environment bootstrap
└── hyprland-layer-config.conf # Hyprland layer-shell behavior tuning
```

## Troubleshooting

### Colors/theme not applied

- run `wal -i /path/to/wallpaper`
- verify file exists: `~/.cache/wal/colors.json`
- confirm `shell.json -> paths.pywalColors` points to the correct file

### Notifications are duplicated or conflicting

- set `notifications.registerServer` in `shell.json`
- disable it if another notification daemon should remain primary

### Bluetooth/network/audio controls are non-responsive

- ensure required services are running:
    - `systemctl --user status wireplumber`
    - `systemctl status NetworkManager`
    - `systemctl status bluetooth`

### Hyprland visual glitches around layer-shell windows

- confirm Hyprland sources `hyprland-layer-config.conf`
- reload Hyprland config after changes

## Development Notes

- Keep module logic in `modules/` and system access in `services/`
- Prefer extending existing reusable controls from `components/`
- Validate config changes through `shell.json` and reload with `./reload-quickshell.sh`

## License

MIT. See [LICENSE](LICENSE).
