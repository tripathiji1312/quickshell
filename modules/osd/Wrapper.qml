import Quickshell
import QtQuick

Scope {
    id: root
    
    required property var pywal
    
    VolumeOSD {
        pywal: root.pywal
    }
    
    BrightnessOSD {
        pywal: root.pywal
    }
}
