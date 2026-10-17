import QtQuick
import QtQuick.Shapes
import "../lib/Model.js" as Model

// The picture dimmed everywhere a spotlight is not, and a ring around each
// one if asked for. It covers the card below the title bar rather than the
// screenshot alone, so an inset band dims with the picture it extends; the
// padding and the background never do.
Item {
    id: spot

    property var doc: null
    property real holeOffset: 0            // the inset, between card and shot
    property real topRadius: 0
    property real bottomRadius: 0
    // With several shots, each card's part of the area (Model.spotlightOutlines);
    // null for one.
    property var outlines: null

    readonly property real amount: doc ? Model.clamp(doc.spotDim / 100, 0, 1) : 0
    readonly property bool ring: doc !== null && doc.spotRing
    visible: doc !== null && doc.spotlightCount > 0 && (amount > 0 || ring)

    readonly property var cards: spot.outlines
        ? spot.outlines
        : [{ x: 0, y: 0, w: spot.width, h: spot.height, top: spot.topRadius, bottom: spot.bottomRadius }]
    readonly property var holes: {
        if (!spot.doc)
            return [];
        // Read for the dependency alone: a ListModel notifies nothing a
        // binding can follow, so every edit bumps this.
        spot.doc.annotationRevision;
        return Model.spotlightHoles(spot.doc.annotations, spot.holeOffset, spot.doc.spotShape);
    }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            fillRule: ShapePath.OddEvenFill
            fillColor: Qt.rgba(0, 0, 0, spot.amount)
            strokeWidth: -1
            PathSvg { path: Model.spotlightPathIn(spot.cards, spot.holes) }
        }
        // Over the dim, so it reads the same however dark the rest goes.
        ShapePath {
            fillColor: "transparent"
            strokeColor: spot.ring ? "white" : "transparent"
            strokeWidth: spot.ring && spot.doc ? Model.spotRingWidth(spot.doc.shotWidth, spot.doc.shotHeight) : -1
            PathSvg { path: spot.ring ? Model.spotlightHolesPath(spot.cards, spot.holes) : "" }
        }
    }
}
