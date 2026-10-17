import QtQuick

// One sample of the source per block: destroyed, not blurred. Shared by the
// hide tool and by the copy of the shot a magnifying spotlight looks
// through, so one over a hidden area shows the same blocks and never what
// is under them. Solid is the other way to hide: a flat block that leaks
// nothing, not even the shape of a word.
Item {
    id: pix
    property Item source: null
    property rect area: Qt.rect(0, 0, 0, 0)     // in the source's pixels
    property real block: 14
    property bool solid: false

    clip: true

    ShaderEffectSource {
        anchors.fill: parent
        visible: pix.source !== null && !pix.solid
        sourceItem: pix.source
        sourceRect: pix.area
        textureSize: Qt.size(
            Math.max(1, Math.round(pix.area.width / Math.max(2, pix.block))),
            Math.max(1, Math.round(pix.area.height / Math.max(2, pix.block))))
        smooth: false
        live: true
    }
    Rectangle {
        anchors.fill: parent
        visible: pix.source === null || pix.solid
        color: "#111111"
    }
}
