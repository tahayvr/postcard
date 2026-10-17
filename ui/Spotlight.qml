import QtQuick
import QtQuick.Shapes
import "../lib/Model.js" as Model

// The picture dimmed everywhere a spotlight is not, what is under each one
// magnified in its place if asked for, and a ring around each one. It covers
// the card below the title bar rather than the screenshot alone, so an inset
// band dims with the picture it extends; the padding and the background
// never do.
Item {
    id: spot

    property var doc: null
    property real holeOffset: 0            // the inset, between card and shot
    property real topRadius: 0
    property real bottomRadius: 0
    // With several shots, each card's part of the area (Model.spotlightOutlines);
    // null for one.
    property var outlines: null
    // The shot with every hidden area already pixelated, in shot pixels: a
    // magnifying spotlight over one shows the blocks, not what they cover.
    property Item lensSource: null

    readonly property real amount: doc ? Model.clamp(doc.spotDim / 100, 0, 1) : 0
    readonly property bool ring: doc !== null && doc.spotRing
    readonly property int zoom: doc ? Model.spotZoom(doc.spotZoom) : 1
    visible: doc !== null && doc.spotlightCount > 0 && (amount > 0 || ring || zoom > 1)

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
    readonly property var boxes: Model.spotlightHoleBoxes(spot.cards, spot.holes)

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            fillRule: ShapePath.OddEvenFill
            fillColor: Qt.rgba(0, 0, 0, spot.amount)
            strokeWidth: -1
            PathSvg { path: Model.spotlightPathIn(spot.cards, spot.holes) }
        }
    }

    Repeater {
        model: spot.zoom > 1 && spot.lensSource ? spot.boxes : []
        Item {
            id: lens
            required property var modelData
            readonly property var area: Model.spotLensArea(lens.modelData.x - spot.holeOffset,
                                                           lens.modelData.y - spot.holeOffset,
                                                           lens.modelData.w, lens.modelData.h, spot.zoom)
            x: lens.modelData.x
            y: lens.modelData.y
            width: lens.modelData.w
            height: lens.modelData.h

            // One texel per shot pixel, scaled up unsmoothed: each pixel
            // becomes a clean block rather than a blur.
            ShaderEffectSource {
                id: lensTexture
                visible: false
                anchors.fill: parent
                sourceItem: spot.lensSource
                sourceRect: Qt.rect(lens.area.x, lens.area.y, lens.area.w, lens.area.h)
                textureSize: Qt.size(lens.area.w, lens.area.h)
                smooth: false
                live: true
            }

            // assets/shaders/lens.frag stretches the texture over the hole
            // and cuts it to the hole's shape. A Shape filled with it mapped
            // the texture at a scale that followed the layer's transform, and
            // a layer mask would resample it.
            ShaderEffect {
                anchors.fill: parent
                property variant source: lensTexture
                property size size: Qt.size(lens.width, lens.height)
                property vector4d radii: Qt.vector4d(lens.modelData.tl, lens.modelData.tr,
                                                     lens.modelData.br, lens.modelData.bl)
                property real ellipse: lens.modelData.shape === "ellipse" ? 1 : 0
                fragmentShader: Qt.resolvedUrl("../assets/shaders/lens.frag.qsb")
            }
        }
    }

    // Over the dim and the magnified area, so it reads the same however dark
    // the rest goes.
    Shape {
        anchors.fill: parent
        visible: spot.ring
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            fillColor: "transparent"
            strokeColor: "white"
            strokeWidth: spot.doc ? Model.spotRingWidth(spot.doc.shotWidth, spot.doc.shotHeight) : 2
            PathSvg { path: spot.ring ? Model.spotlightHolesPath(spot.cards, spot.holes) : "" }
        }
    }
}
