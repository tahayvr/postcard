import QtQuick
import QtQuick.Shapes
import qs.Commons
import "../lib/Model.js" as Model

// Annotations live in screenshot pixel coordinates. Ids avoid `layer` and
// `item`: every Item has a `layer` property and Loader exposes `item`, and
// both would shadow an id inside the delegates.
Item {
    id: anno

    property var doc: null
    property Item pixelSource: null
    // The shot with hidden areas already pixelated, for a magnifier to show.
    property Item magnifySource: null
    // The live editor, as against the export or the bar widget's preview.
    property bool interactive: false
    // With the move tool every mark is there to be taken. With a tool that
    // draws, only the one just drawn is, so a press anywhere else still
    // starts a new mark.
    readonly property bool moving: anno.doc !== null && anno.doc.tool === "select"
    // Cropping is about the picture, not the marks on it: the whole surface
    // belongs to the selection being drawn.
    readonly property bool editable: anno.interactive && anno.doc !== null
                                     && anno.doc.tool !== "crop"

    property real viewScale: 1

    // Screen sizes, so they stay put however far the picture is scaled down.
    readonly property real hairline: Math.max(1, 1.5 / anno.viewScale)
    readonly property real handle: 9 / anno.viewScale
    readonly property real slop: 6 / anno.viewScale
    // A selected mark is framed by one screen pixel, set this far out from
    // its edge so the frame never sits on a stroke.
    readonly property real px: 1 / anno.viewScale
    readonly property real frameGap: 2 / anno.viewScale
    // From the edge of the shape to the middle of that frame line, where its
    // corner handles are centred.
    readonly property real frameOut: anno.frameGap + anno.px / 2

    clip: false

    Repeater {
        model: anno.doc ? anno.doc.annotations : null

        delegate: Item {
            id: entry
            // Not `index` as well: a Repeater over this document's ListModel
            // hands every delegate a zero, so a move wrote itself onto the
            // first annotation instead of its own. Rows are found by uid.
            required property var model

            readonly property var a: model
            readonly property bool selected: anno.doc.selectedIds.indexOf(a.uid) !== -1
            // Handles are for one mark at a time.
            readonly property bool alone: entry.selected && anno.doc.selectedIds.length === 1
            // Carried along while another selected mark is dragged.
            readonly property point follow: (entry.selected && anno.doc.groupLeader !== ""
                                             && anno.doc.groupLeader !== a.uid)
                                            ? anno.doc.groupShift : Qt.point(0, 0)
            readonly property bool grabbable: anno.editable && (anno.moving || entry.selected)
            readonly property color ink: (a.color && a.color !== "")
                                         ? a.color : anno.doc.inkColor
            readonly property real stroke: Math.max(1, a.width)
            readonly property bool sizedByContent: a.kind === "text"
            // Everything but a line is selected in a frame with white corners,
            // and where it has sides, resized from anywhere along one.
            readonly property bool framed: a.kind !== "arrow"
            // A lens is framed a little further out than the rest, clear of
            // its ring.
            readonly property real frameGap: a.kind === "magnify" ? 3 / anno.viewScale : anno.frameGap
            readonly property real frameOut: entry.frameGap + anno.px / 2

            // A label is as big as its text, which only this delegate knows:
            // it tells the document, and slides back inside the picture if
            // typing or a new font grows it past an edge.
            onWidthChanged: entry.measured()
            onHeightChanged: entry.measured()
            function measured() {
                if (!entry.sizedByContent || !anno.doc) return;
                anno.doc.setShownSize(entry.a.uid, entry.width, entry.height);
                if (anno.doc.exporting) return;
                var back = Model.keepInside(anno.doc.boundsOf(entry.a), anno.doc.pictureArea);
                if (back.dx !== 0 || back.dy !== 0)
                    anno.doc.updateAnnotation(entry.a.uid, { x: entry.a.x + back.dx, y: entry.a.y + back.dy });
            }
            // Where the mark sits by the model. During a move the item is
            // dragged away from this and the model only catches up on
            // release, so anything placed inside the item measures from here
            // and travels with it.
            readonly property real originX: Math.min(a.x, a.x + a.w)
            readonly property real originY: Math.min(a.y, a.y + a.h)

            x: Math.min(a.x, a.x + a.w) + entry.follow.x
            y: Math.min(a.y, a.y + a.h) + entry.follow.y
            width: sizedByContent ? Math.max(1, body.implicitWidth) : Math.max(1, Math.abs(a.w))
            height: sizedByContent ? Math.max(1, body.implicitHeight) : Math.max(1, Math.abs(a.h))

            // Keeping the sign of w/h, which says which way it was drawn.
            function commit() {
                anno.doc.updateAnnotation(entry.a.uid, {
                    x: entry.x + (entry.a.w < 0 ? -entry.a.w : 0),
                    y: entry.y + (entry.a.h < 0 ? -entry.a.h : 0)
                });
            }

            // Restores what the drag overwrote.
            function rebind() {
                entry.x = Qt.binding(function () { return Math.min(entry.a.x, entry.a.x + entry.a.w) + entry.follow.x; });
                entry.y = Qt.binding(function () { return Math.min(entry.a.y, entry.a.y + entry.a.h) + entry.follow.y; });
            }

            Loader {
                id: body
                anchors.fill: parent
                sourceComponent: {
                    switch (entry.a.kind) {
                    case "arrow":     return arrowComp;
                    case "ellipse":   return ellipseComp;
                    case "redact":    return redactComp;
                    case "highlight": return highlightComp;
                    case "text":      return textComp;
                    case "step":      return stepComp;
                    case "magnify":   return magnifyComp;
                    // The dim is one layer under every annotation, so a
                    // spotlight has nothing of its own to draw here.
                    case "spotlight": return null;
                    }
                    return boxComp;
                }
            }

            Component {
                id: boxComp
                Rectangle {
                    color: "transparent"
                    border.color: entry.ink
                    border.width: entry.stroke
                    radius: entry.stroke * 1.5
                    antialiasing: true
                }
            }

            Component {
                id: highlightComp
                Rectangle {
                    color: Qt.rgba(entry.ink.r, entry.ink.g, entry.ink.b, 0.3)
                    radius: entry.stroke
                }
            }

            Component {
                id: ellipseComp
                Shape {
                    id: ell
                    anchors.fill: parent
                    preferredRendererType: Shape.CurveRenderer
                    ShapePath {
                        strokeColor: entry.ink
                        strokeWidth: entry.stroke
                        fillColor: "transparent"
                        capStyle: ShapePath.RoundCap
                        PathAngleArc {
                            centerX: ell.width / 2
                            centerY: ell.height / 2
                            radiusX: Math.max(1, ell.width / 2 - entry.stroke / 2)
                            radiusY: Math.max(1, ell.height / 2 - entry.stroke / 2)
                            startAngle: 0
                            sweepAngle: 360
                        }
                    }
                }
            }

            Component {
                id: arrowComp
                Shape {
                    id: arw
                    anchors.fill: parent
                    preferredRendererType: Shape.CurveRenderer

                    readonly property real head: Model.arrowHead(entry.stroke)
                    readonly property var g: Model.arrowShape(entry.a.w, entry.a.h,
                                                              entry.a.style, arw.head, entry.a.bend)

                    ShapePath {
                        strokeColor: entry.ink
                        strokeWidth: entry.stroke
                        capStyle: ShapePath.RoundCap
                        fillColor: "transparent"
                        startX: arw.g.sx
                        startY: arw.g.sy
                        // Straight is the same curve with its control point on
                        // the midpoint, so there is only ever one shaft.
                        PathQuad {
                            x: arw.g.ex
                            y: arw.g.ey
                            controlX: arw.g.cx
                            controlY: arw.g.cy
                        }
                    }

                    // A ShapePath cannot be hidden, so a head that is not
                    // wanted is filled with nothing.
                    ShapePath {
                        strokeColor: "transparent"
                        fillColor: arw.g.headEnd ? entry.ink : "transparent"
                        startX: arw.g.tipX
                        startY: arw.g.tipY
                        PathLine {
                            x: arw.g.tipX - Math.cos(arw.g.angEnd - Model.ARROW_SPREAD) * arw.head
                            y: arw.g.tipY - Math.sin(arw.g.angEnd - Model.ARROW_SPREAD) * arw.head
                        }
                        PathLine {
                            x: arw.g.tipX - Math.cos(arw.g.angEnd + Model.ARROW_SPREAD) * arw.head
                            y: arw.g.tipY - Math.sin(arw.g.angEnd + Model.ARROW_SPREAD) * arw.head
                        }
                        PathLine { x: arw.g.tipX; y: arw.g.tipY }
                    }

                    ShapePath {
                        strokeColor: "transparent"
                        fillColor: arw.g.headStart ? entry.ink : "transparent"
                        startX: arw.g.tailX
                        startY: arw.g.tailY
                        PathLine {
                            x: arw.g.tailX - Math.cos(arw.g.angStart - Model.ARROW_SPREAD) * arw.head
                            y: arw.g.tailY - Math.sin(arw.g.angStart - Model.ARROW_SPREAD) * arw.head
                        }
                        PathLine {
                            x: arw.g.tailX - Math.cos(arw.g.angStart + Model.ARROW_SPREAD) * arw.head
                            y: arw.g.tailY - Math.sin(arw.g.angStart + Model.ARROW_SPREAD) * arw.head
                        }
                        PathLine { x: arw.g.tailX; y: arw.g.tailY }
                    }
                }
            }

            Component {
                id: redactComp
                Pixelate {
                    source: anno.pixelSource
                    area: Qt.rect(entry.x, entry.y, entry.width, entry.height)
                    block: entry.a.strength
                }
            }

            // The lens is this item's box; the area it shows and the line to it
            // are drawn outside it. Measured from where the lens is now rather
            // than where the model has it, so while the lens is dragged the
            // area stays put and the line follows.
            Component {
                id: magnifyComp
                Item {
                    id: mag
                    readonly property real lensR: entry.width / 2
                    readonly property real power: Model.magnifyZoom(entry.a.zoom)
                    readonly property real srcR: mag.lensR / mag.power
                    readonly property real srcX: entry.a.sx - entry.x
                    readonly property real srcY: entry.a.sy - entry.y
                    readonly property var link: Model.magnifyLink(mag.lensR, mag.lensR, mag.lensR,
                                                                  mag.srcX, mag.srcY, mag.srcR)

                    Shape {
                        preferredRendererType: Shape.CurveRenderer
                        // A ShapePath cannot be hidden, so a line that is not
                        // wanted is stroked with nothing.
                        ShapePath {
                            strokeColor: mag.link ? entry.ink : "transparent"
                            strokeWidth: entry.stroke
                            capStyle: ShapePath.RoundCap
                            fillColor: "transparent"
                            startX: mag.link ? mag.link.x1 : 0
                            startY: mag.link ? mag.link.y1 : 0
                            PathLine {
                                x: mag.link ? mag.link.x2 : 0
                                y: mag.link ? mag.link.y2 : 0
                            }
                        }
                        ShapePath {
                            strokeColor: entry.ink
                            strokeWidth: entry.stroke
                            fillColor: "transparent"
                            PathAngleArc {
                                centerX: mag.srcX
                                centerY: mag.srcY
                                radiusX: Math.max(1, mag.srcR)
                                radiusY: Math.max(1, mag.srcR)
                                startAngle: 0
                                sweepAngle: 360
                            }
                        }
                    }

                    // One texel per shot pixel, scaled up unsmoothed: each
                    // pixel becomes a clean block rather than a blur.
                    ShaderEffectSource {
                        id: lensTexture
                        visible: false
                        width: entry.width
                        height: entry.height
                        sourceItem: anno.magnifySource
                        sourceRect: Qt.rect(entry.a.sx - mag.srcR, entry.a.sy - mag.srcR,
                                            mag.srcR * 2, mag.srcR * 2)
                        textureSize: Qt.size(Math.max(1, Math.round(mag.srcR * 2)),
                                             Math.max(1, Math.round(mag.srcR * 2)))
                        smooth: false
                        live: true
                    }

                    // assets/shaders/lens.frag stretches the texture over the
                    // lens and cuts the circle. A Shape filled with it mapped
                    // the texture at a scale that followed the layer's
                    // transform, and a layer mask would resample it.
                    ShaderEffect {
                        anchors.fill: parent
                        visible: anno.magnifySource !== null
                        property variant source: lensTexture
                        // About a pixel and a half of fade at the rim.
                        property real edge: Math.min(0.5, 1.5 / Math.max(1, mag.lensR))
                        fragmentShader: Qt.resolvedUrl("../assets/shaders/lens.frag.qsb")
                    }

                    Shape {
                        anchors.fill: parent
                        preferredRendererType: Shape.CurveRenderer
                        ShapePath {
                            strokeColor: entry.ink
                            strokeWidth: entry.stroke
                            fillColor: anno.magnifySource ? "transparent" : "#1a1a1a"
                            PathAngleArc {
                                centerX: mag.lensR
                                centerY: mag.lensR
                                radiusX: Math.max(1, mag.lensR - entry.stroke / 2)
                                radiusY: Math.max(1, mag.lensR - entry.stroke / 2)
                                startAngle: 0
                                sweepAngle: 360
                            }
                        }
                    }
                }
            }

            Component {
                id: textComp
                Item {
                    readonly property real pad: label.font.pixelSize / 6
                    implicitWidth: label.implicitWidth + pad * 2
                    implicitHeight: label.implicitHeight + pad
                    Text {
                        id: label
                        x: parent.pad
                        y: parent.pad / 2
                        readonly property bool placeholder: entry.a.text === ""
                        text: placeholder ? (anno.doc.exporting ? "" : "Type…") : entry.a.text
                        color: entry.ink
                        opacity: placeholder ? 0.55 : 1
                        font.pixelSize: Math.round(Model.textSize(entry.a))
                        font.family: Model.textFamily(entry.a.font)
                        font.bold: true
                        style: Text.Outline
                        styleColor: Qt.rgba(0, 0, 0, 0.55)
                    }
                }
            }

            Component {
                id: stepComp
                Rectangle {
                    radius: width / 2
                    color: entry.ink
                    antialiasing: true
                    Text {
                        anchors.centerIn: parent
                        text: entry.a.index
                        // A white badge had a white number on it.
                        color: Model.textOn(String(entry.ink))
                        font.family: Style.font.family
                        font.bold: true
                        font.pixelSize: Math.round(parent.width * 0.56)
                    }
                }
            }

            // A line is selected along itself, the way design apps show it:
            // a box around it would read as something to resize like a box.
            Rectangle {
                anchors.fill: parent
                anchors.margins: -(entry.frameGap + anno.px)
                visible: anno.editable && entry.selected && !anno.doc.exporting && entry.framed
                color: "transparent"
                border.color: Color.accent
                border.width: anno.px
                radius: 0
            }

            Shape {
                id: trace
                anchors.fill: parent
                visible: anno.editable && entry.selected && !anno.doc.exporting
                         && entry.a.kind === "arrow"
                preferredRendererType: Shape.CurveRenderer
                readonly property var g: entry.a.kind === "arrow"
                    ? Model.arrowShape(entry.a.w, entry.a.h, entry.a.style,
                                       Model.arrowHead(entry.stroke), entry.a.bend)
                    : null
                ShapePath {
                    strokeColor: Color.accent
                    strokeWidth: anno.hairline
                    capStyle: ShapePath.RoundCap
                    fillColor: "transparent"
                    startX: trace.g ? trace.g.tailX : 0
                    startY: trace.g ? trace.g.tailY : 0
                    PathQuad {
                        x: trace.g ? trace.g.tipX : 0
                        y: trace.g ? trace.g.tipY : 0
                        controlX: trace.g ? trace.g.cx : 0
                        controlY: trace.g ? trace.g.cy : 0
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                id: hold
                // A curve bows out of the box it was dragged in, the more so
                // the further it is bent, and all of it has to take a press.
                readonly property real reach: anno.slop
                    + (entry.a.kind === "arrow" ? Model.arrowBulge(entry.a) : 0)
                anchors.margins: -hold.reach
                enabled: anno.interactive
                hoverEnabled: anno.interactive

                // Whether a press here lands on the mark rather than in the
                // hollow middle of it or off the line of an arrow.
                readonly property bool onMark: Model.hitAnnotation(
                    entry.a,
                    entry.originX - hold.reach + hold.mouseX,
                    entry.originY - hold.reach + hold.mouseY,
                    anno.slop, entry.width, entry.height)

                // The cursor promises only what a press will do: a move where
                // one is on offer, and otherwise whatever the surface
                // underneath would have shown.
                cursorShape: (hold.onMark && entry.grabbable) ? Qt.SizeAllCursor
                           : anno.moving ? Qt.ArrowCursor : Qt.CrossCursor
                // Shift-clicking adds a mark to the selection or takes it out,
                // and does not move anything.
                property bool toggling: false
                drag.target: hold.toggling ? null : entry
                drag.threshold: 2

                // A box, an ellipse and an arrow are mostly empty space.
                // Taking the whole bounding box meant whichever was drawn
                // last swallowed every press over what sits inside it, so a
                // press that misses the mark itself is left to the one
                // underneath.
                onPressed: function (e) {
                    var p = mapToItem(anno, e.x, e.y);
                    if (!entry.grabbable
                            || !Model.hitAnnotation(entry.a, p.x, p.y, anno.slop,
                                                    entry.width, entry.height)) {
                        e.accepted = false;
                        return;
                    }
                    hold.toggling = anno.moving && (e.modifiers & Qt.ShiftModifier);
                    if (hold.toggling) {
                        anno.doc.toggleSelected(entry.a.uid);
                        return;
                    }
                    // Taking hold of one of a group moves the group.
                    if (entry.selected) anno.doc.selectMany(anno.doc.selectedIds, entry.a.uid);
                    else anno.doc.selectedId = entry.a.uid;
                    if (anno.doc.selectedIds.length > 1) anno.doc.groupLeader = entry.a.uid;
                }
                // The dim is drawn from the model, so a spotlight has to write
                // its move back as it happens or the hole lags behind the drag.
                onPositionChanged: {
                    if (hold.toggling) return;
                    // The drag puts the mark under the pointer; the selection
                    // as a whole is then held inside the picture.
                    if (hold.pressed) {
                        var d = anno.doc.fitSelectionMove(entry.x - entry.originX - entry.follow.x,
                                                          entry.y - entry.originY - entry.follow.y);
                        entry.x = entry.originX + d.dx;
                        entry.y = entry.originY + d.dy;
                    }
                    if (anno.doc.groupLeader === entry.a.uid)
                        anno.doc.groupShift = Qt.point(entry.x - entry.originX, entry.y - entry.originY);
                    if (entry.a.kind === "spotlight") entry.commit();
                }
                onReleased: {
                    if (hold.toggling) { hold.toggling = false; return; }
                    if (anno.doc.groupLeader === entry.a.uid) {
                        anno.doc.moveSelection(entry.x - entry.originX, entry.y - entry.originY, entry.a.uid);
                        anno.doc.groupLeader = "";
                        anno.doc.groupShift = Qt.point(0, 0);
                    }
                    entry.commit();
                    entry.rebind();
                }
            }

            // A press inside a magnifier's area moves the area, and the lens
            // with it so it stays beside what it shows. Above the handles: the
            // lens is set diagonally from the area, so one of its corners
            // lands on the area, and the area has to win there.
            MouseArea {
                id: sourceGrab
                z: 1
                readonly property real r: entry.a.kind === "magnify"
                                          ? Model.magnifySource(entry.a).r : 0
                // Never too small to take hold of on screen.
                readonly property real reach: Math.max(sourceGrab.r, anno.slop)
                readonly property bool inside: sourceGrab.within(sourceGrab.mouseX, sourceGrab.mouseY)
                function within(x, y) {
                    var dx = x - sourceGrab.reach, dy = y - sourceGrab.reach;
                    return dx * dx + dy * dy <= sourceGrab.reach * sourceGrab.reach;
                }
                visible: entry.a.kind === "magnify"
                enabled: visible && entry.grabbable
                hoverEnabled: enabled
                x: entry.a.sx - entry.x - sourceGrab.reach
                y: entry.a.sy - entry.y - sourceGrab.reach
                width: sourceGrab.reach * 2
                height: sourceGrab.reach * 2
                cursorShape: !sourceGrab.inside ? Qt.ArrowCursor
                           : sourceGrab.pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                property var from: null
                property point at: Qt.point(0, 0)

                onPressed: function (e) {
                    if (!sourceGrab.within(e.x, e.y)) { e.accepted = false; return; }
                    sourceGrab.at = mapToItem(anno, e.x, e.y);
                    sourceGrab.from = { x: entry.a.x, y: entry.a.y, w: entry.a.w, h: entry.a.h,
                                        sx: entry.a.sx, sy: entry.a.sy };
                    anno.doc.selectedId = entry.a.uid;
                }
                onPositionChanged: function (e) {
                    if (!pressed || !sourceGrab.from) return;
                    var p = mapToItem(anno, e.x, e.y);
                    // Whole pixels, so the area still starts on one.
                    anno.doc.updateAnnotation(entry.a.uid, Model.moveMagnifierArea(sourceGrab.from,
                        Math.round(p.x - sourceGrab.at.x), Math.round(p.y - sourceGrab.at.y),
                        anno.doc.pictureArea));
                }
                onReleased: anno.doc.annotationsEdited()
            }

            // A mark's sides are pulled from anywhere along the frame, outside
            // the stroke, which is left to moving it. The corner handles are
            // laid over the ends of these.
            Repeater {
                model: ["t", "r", "b", "l"]
                delegate: MouseArea {
                    id: edge
                    required property string modelData
                    readonly property bool across: edge.modelData === "t" || edge.modelData === "b"
                    readonly property real reach: entry.frameOut + anno.slop / 2
                    property real offX: 0
                    property real offY: 0

                    visible: Model.hasSides(entry.a.kind) && anno.editable && entry.alone
                             && !anno.doc.exporting
                    enabled: edge.visible
                    x: edge.modelData === "r" ? entry.width : edge.modelData === "l" ? -edge.reach : 0
                    y: edge.modelData === "b" ? entry.height : edge.modelData === "t" ? -edge.reach : 0
                    width: edge.across ? entry.width : edge.reach
                    height: edge.across ? edge.reach : entry.height
                    cursorShape: edge.across ? Qt.SizeVerCursor : Qt.SizeHorCursor

                    function edgeSpot() {
                        var all = Model.resizeHandles(entry.a, entry.width, entry.height);
                        for (var i = 0; i < all.length; i++)
                            if (all[i].key === edge.modelData) return all[i];
                        return null;
                    }

                    // Held where it was taken, so the side does not jump to
                    // the pointer.
                    onPressed: function (e) {
                        anno.doc.selectedId = entry.a.uid;
                        var p = mapToItem(anno, e.x, e.y), s = edge.edgeSpot();
                        edge.offX = s ? p.x - s.x : 0;
                        edge.offY = s ? p.y - s.y : 0;
                    }
                    onPositionChanged: function (e) {
                        if (!pressed) return;
                        var p = mapToItem(anno, e.x, e.y);
                        var q = Model.clampToArea(p.x - edge.offX, p.y - edge.offY, anno.doc.pictureArea);
                        anno.doc.updateAnnotation(entry.a.uid,
                            Model.resizeAnnotation(entry.a, edge.modelData, q.x, q.y,
                                                   entry.width, entry.height));
                    }
                    onReleased: anno.doc.annotationsEdited()
                }
            }

            // Corners to pull it by, or the ends and middle of an arrow.
            // A fixed count, so a delegate is never rebuilt out from under a
            // drag. A text label's corners are where its text ends, which
            // only this delegate can measure.
            Repeater {
                model: 8
                delegate: Rectangle {
                    id: knob
                    required property int index
                    readonly property var spot: Model.resizeHandles(entry.a, entry.width, entry.height)[knob.index] || null
                    // The sides are the strips above.
                    readonly property bool side: knob.spot !== null && Model.isSideHandle(knob.spot.key)
                    // A corner sits on the frame, outside the stroke.
                    readonly property real outX: !entry.framed || !knob.spot ? 0
                        : knob.spot.key.indexOf("l") !== -1 ? -entry.frameOut
                        : knob.spot.key.indexOf("r") !== -1 ? entry.frameOut : 0
                    readonly property real outY: !entry.framed || !knob.spot ? 0
                        : knob.spot.key.indexOf("t") !== -1 ? -entry.frameOut
                        : knob.spot.key.indexOf("b") !== -1 ? entry.frameOut : 0
                    property real offX: 0
                    property real offY: 0

                    visible: knob.spot !== null && !knob.side && anno.editable && entry.alone
                             && !anno.doc.exporting
                    x: (knob.spot ? knob.spot.x - entry.originX : 0) + knob.outX - width / 2
                    y: (knob.spot ? knob.spot.y - entry.originY : 0) + knob.outY - height / 2
                    width: anno.handle * 0.9
                    height: anno.handle * 0.9
                    // The ends of a line are points, not corners.
                    radius: entry.a.kind === "arrow" ? width / 2 : 0
                    color: "white"
                    border.width: anno.px
                    border.color: Color.accent

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -anno.slop / 2
                        enabled: knob.visible
                        cursorShape: {
                            var k = knob.spot ? knob.spot.key : "";
                            if (k === "tl" || k === "br") return Qt.SizeFDiagCursor;
                            if (k === "tr" || k === "bl") return Qt.SizeBDiagCursor;
                            return Qt.SizeAllCursor;
                        }

                        // Held where it was taken: a corner set out on the
                        // frame would otherwise jump in by the gap.
                        onPressed: function (e) {
                            anno.doc.selectedId = entry.a.uid;
                            var p = mapToItem(anno, e.x, e.y);
                            knob.offX = knob.spot ? p.x - knob.spot.x : 0;
                            knob.offY = knob.spot ? p.y - knob.spot.y : 0;
                        }
                        onPositionChanged: function (e) {
                            if (!pressed || !knob.spot) return;
                            var p = mapToItem(anno, e.x, e.y);
                            // Held to the picture, wherever the pointer goes.
                            var q = Model.clampToArea(p.x - knob.offX, p.y - knob.offY, anno.doc.pictureArea);
                            // By uid, and through the document, which tells
                            // everything drawn from the model that it moved.
                            anno.doc.updateAnnotation(entry.a.uid,
                                Model.resizeAnnotation(entry.a, knob.spot.key, q.x, q.y,
                                                       entry.width, entry.height));
                            // A curve pulled against an edge flattens to fit.
                            if (entry.a.kind === "arrow")
                                anno.doc.updateAnnotation(entry.a.uid,
                                    { bend: Model.bendInside(entry.a, anno.doc.pictureArea) });
                        }
                        onReleased: {
                            // The next label starts at the size this one was left at.
                            if (entry.a.kind === "text") anno.doc.textSize = entry.a.fontSize;
                            anno.doc.annotationsEdited();
                        }
                    }
                }
            }
        }
    }
}
