import QtQuick
import qs.Commons
import "controls"

Item {
    id: rail
    property var doc
    signal status(string text)

    readonly property int annotationCount: rail.doc ? rail.doc.annotations.count : 0

    readonly property var tools: [
        { key: "select",    glyph: "\u{F01BF}", name: "Move",      hint: "V" },
        { key: "arrow",     glyph: "\u{F005C}", name: "Arrow",     hint: "A" },
        { key: "box",       glyph: "\u{F0763}", name: "Box",       hint: "R" },
        { key: "ellipse",   glyph: "\u{F0766}", name: "Ellipse",   hint: "O" },
        { key: "text",      glyph: "\u{F0284}", name: "Text",      hint: "T" },
        { key: "step",      glyph: "\u{F0CA1}", name: "Step",      hint: "S" },
        { key: "highlight", glyph: "\u{F0652}", name: "Highlight", hint: "H" },
        { key: "redact",    glyph: "\u{F00B5}", name: "Hide",      hint: "B" },
        { key: "spotlight", glyph: "\u{F05DD}", name: "Spotlight", hint: "L" },
        { key: "magnify",   glyph: "\uf00e", name: "Magnify", hint: "M" },
        { key: "crop",      glyph: "\uf125", name: "Crop",  hint: "C", shotOnly: true }
    ]

    // A code card is drawn from its text, so there is nothing to cut down.
    readonly property var offered: rail.tools.filter(function (t) {
        return !t.shotOnly || (rail.doc && rail.doc.kind === "shot");
    })

    implicitWidth: Ui.button + Ui.row * 2

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Ui.row
        spacing: Ui.gap

        Repeater {
            model: rail.offered
            IconButton {
                required property var modelData
                glyph: modelData.glyph
                active: rail.doc.tool === modelData.key
                tip: modelData.name
                onClicked: {
                    rail.doc.tool = modelData.key;
                    rail.doc.selectedId = "";
                }

                Text {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 3
                    text: parent.modelData.hint
                    color: Ui.textFaint
                    font.family: Style.font.family
                    font.pixelSize: Style.font.caption * 0.8
                }
            }
        }
    }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Ui.row
        spacing: Ui.gap

        // Each is a no-op with nothing to act on, so they say so instead of
        // looking like a button that does nothing.
        IconButton {
            glyph: "\u{F054D}"
            flat: true
            enabled: rail.doc !== null && rail.doc.canUndo
            tip: "Undo (Ctrl+Z)"
            onClicked: if (rail.doc.undo()) rail.status("Undone")
        }
        IconButton {
            glyph: "\u{F044F}"
            flat: true
            enabled: rail.doc !== null && rail.doc.canRedo
            tip: "Redo (Ctrl+Shift+Z)"
            onClicked: if (rail.doc.redo()) rail.status("Redone")
        }
        IconButton {
            glyph: "\u{F01FE}"
            flat: true
            enabled: rail.annotationCount > 0
            tip: "Clear every annotation"
            onClicked: {
                var n = rail.annotationCount;
                rail.doc.clearAnnotations();
                rail.status("Cleared " + n + (n === 1 ? " annotation" : " annotations"));
            }
        }
    }
}
