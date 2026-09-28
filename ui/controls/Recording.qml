pragma Singleton
import QtQuick

// Shared by the overlay and every instance of the bar widget.
QtObject {
    property string state: "idle"
    property int remaining: 0
    property double startedAt: 0
    property string lastSaved: ""
    property string error: ""
    readonly property bool active: ["selecting", "countdown", "starting", "recording", "stopping"].indexOf(state) !== -1
    signal stopRequested()

    function elapsed(now) {
        var seconds = Math.max(0, Math.floor((now - startedAt) / 1000));
        return Math.floor(seconds / 60) + ":" + (seconds % 60 < 10 ? "0" : "") + seconds % 60;
    }
}
