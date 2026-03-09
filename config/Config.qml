pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import "../services" as QsServices

Singleton {
    id: root

    Component.onCompleted: file.reload()

    property var data: ({})

    function _expandHome(p) {
        if (!p || typeof p !== "string") return p
        if (p.startsWith("~/")) return `${Quickshell.env("HOME")}/${p.slice(2)}`
        return p
    }

    readonly property var appearance: ({
        fontFamily: data.appearance?.fontFamily ?? "Inter",
        materialIconFont: data.appearance?.materialIconFont ?? "Material Design Icons"
    })

    readonly property var paths: ({
        pywalColors: _expandHome(data.paths?.pywalColors ?? "~/.cache/wal/colors.json"),
        screenshotsDir: _expandHome(data.paths?.screenshotsDir ?? "~/Pictures/Screenshots")
    })

    readonly property var osd: ({
        volumeTimeoutMs: data.osd?.volumeTimeoutMs ?? 2000,
        brightnessTimeoutMs: data.osd?.brightnessTimeoutMs ?? 2000
    })

    readonly property var notifications: ({
        popupWidth: data.notifications?.popupWidth ?? 340,
        maxVisible: data.notifications?.maxVisible ?? 5,
        timeoutMs: data.notifications?.timeoutMs ?? 7000,
        registerServer: data.notifications?.registerServer ?? true,
        spacing: data.notifications?.spacing ?? 8,
        margin: data.notifications?.margin ?? 8
    })

    readonly property var launcher: ({
        enabled: data.launcher?.enabled ?? true,
        width: data.launcher?.width ?? 720,
        maxResults: data.launcher?.maxResults ?? 8,
        terminalCommand: data.launcher?.terminalCommand ?? ["foot"],
        favorites: data.launcher?.favorites ?? [
            "org.wezfurlong.wezterm",
            "kitty",
            "Alacritty",
            "firefox",
            "zen-browser",
            "thunar",
            "org.gnome.Nautilus",
            "code",
            "Code"
        ]
    })

    readonly property var sidebar: ({
        enabled: data.sidebar?.enabled ?? true,
        width: data.sidebar?.width ?? 420,
        margin: data.sidebar?.margin ?? 12,
        maxHistory: data.sidebar?.maxHistory ?? 80
    })

    readonly property var dashboard: ({
        enabled: data.dashboard?.enabled ?? true,
        width: data.dashboard?.width ?? 860,
        height: data.dashboard?.height ?? 640,
        margin: data.dashboard?.margin ?? 18
    })

    readonly property BarConfig bar: BarConfig {}
    readonly property AppearanceConfig appearanceTokens: AppearanceConfig {}

    FileView {
        id: file
        path: {
            const home = Quickshell.env("HOME")
            const xdg = Quickshell.env("XDG_CONFIG_HOME")
            const cfgHome = (xdg && xdg.length > 0) ? xdg : `${home}/.config`
            return `${cfgHome}/quickshell/shell.json`
        }
        watchChanges: true

        onLoaded: {
            try {
                const parsed = JSON.parse(text())
                root.data = parsed
                QsServices.Logger.debug("Config", "shell.json loaded")
            } catch (e) {
                QsServices.Logger.warn("Config", `Failed to parse shell.json: ${e?.message ?? e}`)
            }
        }

        onFileChanged: {
            file.reload()
        }

        onLoadFailed: err => {
            if (err !== FileViewError.FileNotFound)
                QsServices.Logger.warn("Config", `Failed to read shell.json: ${FileViewError.toString(err)}`)
        }
    }

    // Backwards-compatible aliases used across the repo
    readonly property var controlCenter: ({
        width: 700,
        maxHeight: 1000,
        padding: 16,
        spacing: 12,
        margin: 4,
        cornerRadius: 24
    })

    readonly property var popups: ({
        width: 280,
        minHeight: 100,
        maxHeight: 400,
        hoverDelay: 300,
        margin: 6
    })
}
