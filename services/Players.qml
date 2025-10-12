pragma Singleton

import Quickshell
import Quickshell.Services.Mpris
import QtQuick 6.10

Singleton {
    id: root

    readonly property var list: Mpris.players.values
    readonly property var active: list[0] ?? null

    function getIdentity(player: var): string {
        return player?.identity ?? "Unknown";
    }
}
