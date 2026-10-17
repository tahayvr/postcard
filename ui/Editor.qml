import QtQuick
import qs.Commons
import "controls"
import "../lib/Model.js" as Model

Rectangle {
    id: editor

    property var doc
    property var systemThemes: []
    property string saveDir: ""
    property bool hasLastRegion: false
    property string statusText: ""
    property bool busy: false
    // The last few cards, newest first, offered by the empty state.
    property var recents: []
    signal recentRequested(string id)
    signal forgetRecentRequested(string id)

    signal captureRequested(string mode)
    signal codeRequested()
    signal copyRequested()
    signal dragOutRequested()
    signal logoRequested()
    signal addShotRequested(string how)
    signal shotRequested(string action, string id)
    signal saveRequested()
    signal saveAsRequested()
    signal openRequested()
    signal closeRequested()
    signal autoRedactRequested()
    signal copyTextRequested()
    signal eyedropRequested(var done)
    signal cropRequested()
    signal uncropRequested()
    // A highlight was just drawn: the overlay reads the picture for the line
    // of text under its middle and, finding one, gives it that line's height.
    signal snapRequested(string uid, real x, real y)

    // Whether a pointer event's modifiers can be believed. A binding with a
    // modifier in it, like the README's SUPER+SHIFT+PRINT, leaves that
    // modifier reported held once the overlay takes focus, because its
    // release went to the compositor: the first box after a hotkey capture
    // came out square. Trusted from the first key event the overlay sees.
    property bool modifiersTrusted: false

    function shiftHeld(mods) { return editor.modifiersTrusted && (mods & Qt.ShiftModifier) !== 0; }
    function altHeld(mods) { return editor.modifiersTrusted && (mods & Qt.AltModifier) !== 0; }

    // The drawing surface hovers as well as drags, so `held` says whether the
    // button is actually down. Every tool but crop had an annotation started
    // on press to check instead; crop had nothing, and its selection followed
    // the bare pointer around the picture. Callable, so the harness can hold
    // that behaviour down without a mouse; `mods` are the pointer's modifiers,
    // already trusted.
    function drawMove(px, py, held, mods) {
        if (!held) return;
        mods = mods || 0;
        var shift = (mods & Qt.ShiftModifier) !== 0, alt = (mods & Qt.AltModifier) !== 0;

        if (doc.tool === "crop") {
            var cw = px - draw.ox, ch = py - draw.oy;
            if (shift) { var cc = Model.constrainDrag("box", cw, ch); cw = cc.w; ch = cc.h; }
            var r = Model.cropRect(draw.ox, draw.oy, cw, ch, doc.shotWidth, doc.shotHeight);
            doc.cropRect = Qt.rect(r.x, r.y, r.w, r.h);
            return;
        }

        if (draw.activeId === "") return;
        var i = doc.indexOfId(draw.activeId);
        if (i < 0) return;
        var kind = doc.annotations.get(i).kind;
        // A label dragged out takes a width to wrap at, nothing more.
        if (kind === "text") {
            doc.annotations.setProperty(i, "w", Math.max(0, px - draw.ox));
            return;
        }
        // A mark is drawn inside the picture, whatever the pointer does.
        var q = Model.clampToArea(px, py, doc.pictureArea);
        var w = q.x - draw.ox, h = q.y - draw.oy;
        // Shift squares it up, or holds an arrow to 45 degrees; squared again
        // after the clamp, which only ever shrinks it, so it stays inside.
        if (shift) {
            var c = Model.constrainDrag(kind, w, h);
            var cq = Model.clampToArea(draw.ox + c.w, draw.oy + c.h, doc.pictureArea);
            c = Model.constrainDrag(kind, cq.x - draw.ox, cq.y - draw.oy);
            w = c.w; h = c.h;
        }
        if (alt && Model.drawsFromCentre(kind)) {
            var m = Model.centredDrag(draw.ox, draw.oy, w, h, doc.pictureArea);
            doc.annotations.setProperty(i, "x", m.x);
            doc.annotations.setProperty(i, "y", m.y);
            w = m.w; h = m.h;
        } else {
            doc.annotations.setProperty(i, "x", draw.ox);
            doc.annotations.setProperty(i, "y", draw.oy);
        }
        doc.annotations.setProperty(i, "w", w);
        doc.annotations.setProperty(i, "h", h);
        if (doc.tool === "arrow") {
            var a = doc.annotations.get(i);
            doc.annotations.setProperty(i, "bend", Model.bendInside(a, doc.pictureArea));
        }
        // Every other tool draws itself from the delegate, which follows the
        // model on its own. The dim is one layer over the picture, so it only
        // redraws when the document says something changed.
        if (doc.tool === "spotlight") doc.annotationsEdited();
    }

    // Modifiers as the drawing surface should read them.
    function drawMods(mods) {
        return (editor.shiftHeld(mods) ? Qt.ShiftModifier : 0) | (editor.altHeld(mods) ? Qt.AltModifier : 0);
    }

    // The start of a drag, in shot pixels, apart from the mouse so the
    // harness can call it: a crop starts a selection, a step and a label are
    // placed at once, anything else starts a mark that drawMove sizes.
    // Returns the uid of the mark in hand, or "" when nothing follows.
    function beginDraw(px, py) {
        var p = Qt.point(px, py);
        // Pressed in the space around the picture, a mark still starts
        // inside it; a crop is about the shot alone.
        if (doc.tool !== "crop") {
            var q = Model.clampToArea(p.x, p.y, doc.pictureArea);
            p = Qt.point(q.x, q.y);
        }
        draw.ox = p.x; draw.oy = p.y;

        if (doc.tool === "crop") {
            doc.selectedId = "";
            doc.cropRect = Qt.rect(0, 0, 0, 0);
            draw.activeId = "";
            return "";
        }

        var a = Model.newAnnotation(doc.tool, p.x, p.y);
        a.color = String(doc.inkColor);
        a.width = doc.inkWidth;
        if (doc.tool === "arrow") a.style = String(doc.arrowStyle);
        if (doc.tool === "redact") a.style = String(doc.redactStyle);
        if (doc.tool === "box" || doc.tool === "ellipse") a.fill = doc.shapeFill;
        if (doc.tool === "box") a.corner = doc.shapeCorner;

        if (doc.tool === "step") {
            var size = Math.max(22, Math.round(doc.inkWidth * 9));
            doc.stepCounter += 1;
            a.index = doc.stepCounter;
            a.x = p.x - size / 2; a.y = p.y - size / 2;
            a.w = size; a.h = size;
            // Placed whole in one click, so all of it goes inside.
            var back = Model.keepInside({ x: a.x, y: a.y, w: size, h: size }, doc.pictureArea);
            a.x += back.dx; a.y += back.dy;
            doc.addAnnotation(a);
            draw.activeId = "";
            return "";
        }
        if (doc.tool === "text") {
            // Placed on press; a drag from here gives it a width to wrap
            // at, and the release settles which it was.
            a.w = 0; a.h = 0;
            a.text = "";
            a.font = doc.textFont;
            a.textStyle = doc.textStyle;
            a.fontSize = doc.textSize > 0 ? doc.textSize
                       : Model.defaultTextSize(doc.shotWidth, doc.shotHeight);
            doc.addAnnotation(a);
            draw.activeId = a.uid;
            return a.uid;
        }
        a.strength = Math.max(6, Math.round(doc.geo.shotW / 90));
        doc.addAnnotation(a);
        draw.activeId = a.uid;
        return a.uid;
    }

    // The end of a drag, apart from the mouse so the harness can call it: a
    // stray click leaves nothing, a label settles into a line or a wrapping
    // box, and a highlight asks for the text row under it.
    function finishDraw(uid) {
        var i = doc.indexOfId(uid);
        if (i < 0) return;
        var a = doc.annotations.get(i);
        if (a.kind === "text") {
            // Narrower than a word's worth and it was a click.
            if (a.w < Model.MIN_TEXT_WRAP) doc.annotations.setProperty(i, "w", 0);
            doc.annotationsEdited();
            doc.tool = "select";
            editor.statusText = "Type the label, then press Enter";
            return;
        }
        if (Math.abs(a.w) < 4 && Math.abs(a.h) < 4) {
            doc.removeAnnotation(uid);
            return;
        }
        doc.annotationsEdited();
        if (a.kind === "highlight" && doc.highlightSnap && doc.kind === "shot")
            editor.snapRequested(uid, a.x + a.w / 2, a.y + a.h / 2);
    }

    readonly property Item exportTarget: grabRoot
    // The view's magnification over the fit, 1 when the whole picture shows.
    readonly property real zoom: viewport.zoom
    readonly property point scroll: Qt.point(flick.contentX, flick.contentY)
    function zoomStep(dir) { viewport.zoomStep(dir); }
    function zoomReset() { viewport.zoomReset(); }
    // Zoom to `z` with the viewport point (vx, vy) held in place.
    function zoomAt(z, vx, vy) { viewport.zoomAt(z, vx, vy); }
    function pan(dx, dy) { viewport.pan(dx, dy); }
    // The shot point under a viewport point, for the harness.
    function shotAt(vx, vy) {
        return draw.toShot(vx - (holder.x - flick.contentX), vy - (holder.y - flick.contentY));
    }
    property var manifest: null
    // "settings" or "about" take the inspector's place while they are open.
    property string panel: ""
    readonly property Item sidePanel: settingsPanel.visible ? settingsPanel
                                    : aboutPanel.visible ? aboutPanel
                                    : inspector.visible ? inspector : null
    // True from the moment the picture is ready until the drag ends: the
    // backdrop goes first, and the drag starts once it has.
    property bool draggingOut: false
    readonly property bool dragActive: dragOut.Drag.active

    // Called once the picture is on disk. A drag can only start while the
    // button is still held: Wayland ties it to that press.
    function startDragOut(path) {
        if (!dragOut.held) {
            editor.statusText = "Hold the button and drag it into another window";
            return;
        }
        var url = "file://" + path;
        dragOut.Drag.mimeData = { "text/uri-list": url + "\r\n" };
        dragOut.Drag.imageSource = url;
        editor.draggingOut = true;
        dragStart.restart();
    }

    Timer {
        id: dragStart
        interval: 150
        onTriggered: {
            if (!dragOut.held) { editor.draggingOut = false; return; }
            dragOut.Drag.active = true;
        }
    }

    color: Color.menu && Color.menu.background ? Color.menu.background : Color.background
    border.width: 1
    border.color: Color.menu && Color.menu.border ? Color.menu.border : Ui.hairline

    // Under everything: catches clicks that would otherwise reach the scrim
    // and close the editor, and takes focus back from text fields.
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        onPressed: editor.forceActiveFocus()
    }

    Item {
        id: header
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: Ui.button + Ui.pad

        Row {
            anchors.left: parent.left
            anchors.leftMargin: Ui.pad
            anchors.verticalCenter: parent.verticalCenter
            spacing: Ui.row

            Wordmark {
                anchors.verticalCenter: parent.verticalCenter
                markHeight: Style.font.bodySmall * 1.5
                tint: Ui.text
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: doc.kind === "code" && doc.hasContent ? doc.frameTitle
                      : doc.shotCount > 1 ? doc.slots[0].name + "  +" + (doc.shotCount - 1)
                      : doc.shotName ? doc.shotName : "No screenshot yet"
                color: Ui.textMuted
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
                elide: Text.ElideMiddle
                width: Math.min(implicitWidth, Style.space(150))
            }
        }

        ToolOptions {
            anchors.centerIn: parent
            doc: editor.doc
            hasLastRegion: editor.hasLastRegion
            onCaptureRequested: function (mode) { editor.captureRequested(mode); }
            onCodeRequested: editor.codeRequested()
            onOpenRequested: editor.openRequested()
            onAutoRedactRequested: editor.autoRedactRequested()
            onCropRequested: editor.cropRequested()
            onUncropRequested: editor.uncropRequested()
            onEyedropRequested: function (done) { editor.eyedropRequested(done); }
            onAddShotRequested: function (how) { editor.addShotRequested(how); }
        }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: Ui.pad / 2
            anchors.verticalCenter: parent.verticalCenter
            spacing: Ui.gap

            IconButton {
                glyph: "\uf013"
                flat: true
                active: editor.panel === "settings"
                tip: "Settings"
                onClicked: editor.panel = editor.panel === "settings" ? "" : "settings"
            }
            IconButton {
                glyph: "\uf05a"
                flat: true
                active: editor.panel === "about"
                tip: "About, help and keys"
                onClicked: editor.panel = editor.panel === "about" ? "" : "about"
            }
            IconButton {
                glyph: "\u{F0156}"
                flat: true
                tip: "Close (Esc)"
                onClicked: editor.closeRequested()
            }
        }

        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color: Ui.hairline
        }
    }

    ToolRail {
        id: rail
        doc: editor.doc
        anchors { top: header.bottom; bottom: footer.top; left: parent.left }
        width: implicitWidth
        visible: doc.hasContent
        onStatus: function (text) { editor.statusText = text; }
    }

    Item {
        id: viewport
        anchors {
            top: header.bottom
            bottom: footer.top
            left: rail.visible ? rail.right : parent.left
            right: editor.sidePanel ? editor.sidePanel.left : parent.right
        }
        clip: true

        // Sees every press on the picture without taking it from the marks,
        // so the undo history knows to wait for the release. It has to sit
        // on top: a handler on the viewport itself never saw a press that a
        // mark or the drawing surface took.
        Item {
            anchors.fill: parent
            z: 100
            PointHandler {
                id: press
                acceptedButtons: Qt.LeftButton
            }
        }
        Binding {
            target: editor.doc
            property: "pressing"
            value: press.active
        }

        readonly property real margin: Ui.pad * 2
        // The stage is laid out in screen units, so a fit of 1 shows the shot
        // life-size, pixel for pixel; the fit never magnifies, the zoom does.
        readonly property real fit: doc.hasContent
            ? Math.min((width - margin * 2) / Math.max(1, stage.width),
                       (height - margin * 2) / Math.max(1, stage.height), 1)
            : 1
        // Magnification over the fit, up to one shot pixel per four screen
        // pixels (Model.zoomMax). Display only: it scales grabRoot, and
        // grabToImage renders that at its own size whatever its scale.
        property real zoom: 1
        readonly property real zoomMax: Model.zoomMax(fit)
        readonly property real viewScale: fit * zoom
        readonly property var content: Model.viewContent(width, height, stage.width, stage.height,
                                                         viewScale, margin)
        onZoomMaxChanged: if (zoom > zoomMax) zoom = zoomMax

        // Zoom to `z` keeping the stage point under (px, py) where it is.
        function zoomAt(z, px, py) {
            z = Model.clamp(z, 1, zoomMax);
            if (z === zoom) return;
            var to = Model.zoomAbout(width, height, stage.width, stage.height, margin,
                                     viewScale, fit * z, px, py, flick.contentX, flick.contentY);
            zoom = z;
            flick.contentX = to.x;
            flick.contentY = to.y;
        }
        function zoomStep(dir) { zoomAt(Model.zoomStep(zoom, dir, zoomMax), width / 2, height / 2); }
        function zoomReset() { zoom = 1; pan(0, 0); }
        function pan(dx, dy) {
            var to = Model.clampScroll(flick.contentX + dx, flick.contentY + dy, content, width, height);
            flick.contentX = to.x;
            flick.contentY = to.y;
        }

        Connections {
            target: editor.doc
            function onHistoryReset() { viewport.zoomReset(); }
        }

        // A middle-button drag scrolls a zoomed view. It sits under the
        // Flickable, where only the presses nothing on the picture takes
        // arrive, and no mark takes the middle button.
        MouseArea {
            id: panDrag
            anchors.fill: parent
            acceptedButtons: Qt.MiddleButton
            enabled: doc.hasContent
            cursorShape: pressed ? Qt.ClosedHandCursor : Qt.ArrowCursor
            property point from: Qt.point(0, 0)
            property point scrolled: Qt.point(0, 0)
            onPressed: function (e) {
                panDrag.from = Qt.point(e.x, e.y);
                panDrag.scrolled = Qt.point(flick.contentX, flick.contentY);
            }
            onPositionChanged: function (e) {
                if (!pressed) return;
                viewport.pan(panDrag.scrolled.x - (e.x - panDrag.from.x) - flick.contentX,
                             panDrag.scrolled.y - (e.y - panDrag.from.y) - flick.contentY);
            }
        }

        // Ctrl+wheel zooms about the pointer; a plain wheel scrolls a zoomed
        // view, sideways with Shift. Nothing on the picture wants the wheel.
        WheelHandler {
            target: null
            onWheel: function (e) {
                if (e.modifiers & Qt.ControlModifier)
                    viewport.zoomAt(Model.zoomWheel(viewport.zoom, e.angleDelta.y, viewport.zoomMax), e.x, e.y);
                else if (editor.shiftHeld(e.modifiers))
                    viewport.pan(-e.angleDelta.y / 2, 0);
                else
                    viewport.pan(-e.angleDelta.x / 2, -e.angleDelta.y / 2);
            }
        }

        // Scrolled from here only: interactive, it would take the marks'
        // presses and flick the picture out from under a drag.
        Flickable {
            id: flick
            anchors.fill: parent
            interactive: false
            contentWidth: viewport.content.w
            contentHeight: viewport.content.h
            // A view that shrinks leaves the scroll past its end.
            onContentWidthChanged: viewport.pan(0, 0)
            onContentHeightChanged: viewport.pan(0, 0)
            onWidthChanged: viewport.pan(0, 0)
            onHeightChanged: viewport.pan(0, 0)

            // Checkerboard behind (never inside) the stage for a transparent
            // background. A tiled image, not a Canvas: a Canvas can skip its
            // paint when the window is re-mapped, which left the frame looking
            // see-through.
            Rectangle {
                anchors.fill: holder
                anchors.margins: -1
                visible: doc.bgMode === "none" && doc.hasContent
                color: "transparent"
                border.width: 1
                border.color: Ui.hairline
                Image {
                    anchors.fill: parent
                    anchors.margins: 1
                    fillMode: Image.Tile
                    smooth: false
                    source: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAIAAACQkWg2AAAAIGNIUk0AAHomAACAhAAA+gAAAIDoAAB1MAAA6mAAADqYAAAXcJy6UTwAAAAGYktHRAD/AP8A/6C9p5MAAAAHdElNRQfqCRMRCizhZEVqAAAAJXRFWHRkYXRlOmNyZWF0ZQAyMDI2LTA5LTE5VDE3OjEwOjQ0KzAwOjAwqwR2NQAAACV0RVh0ZGF0ZTptb2RpZnkAMjAyNi0wOS0xOVQxNzoxMDo0NCswMDowMNpZzokAAAAodEVYdGRhdGU6dGltZXN0YW1wADIwMjYtMDktMTlUMTc6MTA6NDQrMDA6MDCNTO9WAAAAEGNhTnYAAAAIAAAACAAAAAAAAAAAsu1W2QAAAChJREFUKM9jtLJ3YcAGBIWEsYozMZAIRjUQA1hwhff7d2+Hih+GgwYAZ8cEFYSK+YEAAAAASUVORK5CYII="
                }
            }

            Item {
                id: holder
                x: viewport.content.x
                y: viewport.content.y
                width: stage.width * viewport.viewScale
                height: stage.height * viewport.viewScale
                visible: doc.hasContent

                // With the move tool, a press on nothing clears the selection and
                // a drag from there draws a box that selects whatever it touches;
                // with Shift it adds to what is already selected.
                MouseArea {
                    id: marquee
                    anchors.fill: parent
                    enabled: doc.tool === "select"
                    property point from: Qt.point(0, 0)
                    property bool adding: false
                    property bool boxing: false

                    onPressed: function (e) {
                        marquee.from = Qt.point(e.x, e.y);
                        marquee.adding = (e.modifiers & Qt.ShiftModifier) !== 0;
                        marquee.boxing = false;
                        if (!marquee.adding) doc.selectedId = "";
                    }
                    onPositionChanged: function (e) {
                        if (!pressed) return;
                        if (Math.abs(e.x - marquee.from.x) + Math.abs(e.y - marquee.from.y) > 4)
                            marquee.boxing = true;
                        band.x = Math.min(e.x, marquee.from.x);
                        band.y = Math.min(e.y, marquee.from.y);
                        band.width = Math.abs(e.x - marquee.from.x);
                        band.height = Math.abs(e.y - marquee.from.y);
                    }
                    onReleased: {
                        if (!marquee.boxing) return;
                        marquee.boxing = false;
                        var a = draw.toShot(band.x, band.y);
                        var b = draw.toShot(band.x + band.width, band.y + band.height);
                        doc.selectInBox(a.x, a.y, b.x - a.x, b.y - a.y, marquee.adding);
                    }
                }

                Rectangle {
                    id: band
                    z: 2
                    visible: marquee.boxing
                    color: Qt.rgba(Color.accent.r, Color.accent.g, Color.accent.b, 0.12)
                    border.width: 1
                    border.color: Color.accent
                }

                // What the export grabs, rather than the stage itself: padded up
                // to a whole number of device pixels so grabToImage renders at
                // exactly 1:1 (see Model.grabSize), then cropped by postcard-deliver.
                Item {
                    id: grabRoot
                    // Over the drawing surface below, so the crop handles can
                    // take a press; everything else in the stage ignores the
                    // mouse while a tool is in hand, and falls through to it.
                    z: 1
                    readonly property var fit: Model.grabSize(stage.width, stage.height, stage.dpr)
                    width: grabRoot.fit.w
                    height: grabRoot.fit.h
                    transformOrigin: Item.TopLeft
                    scale: viewport.viewScale

                    Stage {
                        id: stage
                        doc: editor.doc
                        interactive: true
                        viewScale: viewport.viewScale
                        modifiersTrusted: editor.modifiersTrusted
                    }
                }

                // Drawing surface; off in select mode so presses reach the annotations.
                MouseArea {
                    id: draw
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: doc.hasContent && doc.tool !== "select"
                    acceptedButtons: Qt.LeftButton
                    cursorShape: doc.tool === "select" ? Qt.ArrowCursor : Qt.CrossCursor

                    property string activeId: ""
                    property real ox: 0
                    property real oy: 0

                    function toShot(px, py) {
                        var k = viewport.viewScale * stage.unit;
                        return Qt.point(px / k - doc.geo.cardX - doc.geo.inset,
                                        py / k - doc.geo.cardY - doc.geo.chromeH - doc.geo.inset);
                    }

                    onPressed: function (e) {
                        if (doc.tool === "select") { doc.selectedId = ""; return; }
                        var p = toShot(e.x, e.y);
                        editor.beginDraw(p.x, p.y);
                    }

                    onPositionChanged: function (e) {
                        var p = toShot(e.x, e.y);
                        editor.drawMove(p.x, p.y, draw.pressed, editor.drawMods(e.modifiers));
                    }

                    onReleased: function () {
                        if (doc.tool === "crop") {
                            if (!doc.cropUsable) doc.cropRect = Qt.rect(0, 0, 0, 0);
                            return;
                        }
                        if (activeId === "") return;
                        editor.finishDraw(activeId);
                        activeId = "";
                    }
                }

            }
        }

        Column {
            anchors.centerIn: parent
            spacing: Ui.pad
            visible: !doc.hasContent
            width: Math.min(parent.width - Ui.pad * 4, Style.space(380))

            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: "Take a shot to start"
                color: Ui.text
                font.family: Style.font.family
                font.pixelSize: Style.font.body
                font.bold: true
                font.capitalization: Font.AllUppercase
                font.letterSpacing: 1
            }
            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                text: "Grab a region, a window or the screen, or turn selected text into a code card."
                color: Ui.textMuted
                font.family: Style.font.family
                font.pixelSize: Style.font.bodySmall
                lineHeight: 1.35
            }
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Ui.gap
                IconButton { glyph: "\u{F0489}"; label: "Capture a region"; onClicked: editor.captureRequested("region") }
                IconButton { glyph: "\uf121"; label: "Code from selection"; onClicked: editor.codeRequested() }
                IconButton { glyph: "\uf1c5"; label: "Open a file"; onClicked: editor.openRequested() }
            }

            // The last few cards, each as it was last seen, to pick up again.
            Column {
                width: parent.width
                spacing: Ui.row
                visible: editor.recents.length > 0

                Text {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: "Recent"
                    color: Ui.textMuted
                    font.family: Style.font.family
                    font.pixelSize: Style.font.caption
                    font.capitalization: Font.AllUppercase
                    font.letterSpacing: 1
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: Ui.gap
                    Repeater {
                        model: editor.recents
                        Rectangle {
                            id: card
                            required property var modelData
                            width: Style.space(64)
                            height: Style.space(48)
                            color: Ui.fill
                            border.width: 1
                            border.color: cardHover.hovered ? Ui.borderActive : Ui.hairline

                            Image {
                                anchors.fill: parent
                                anchors.margins: 1
                                visible: card.modelData.thumb !== ""
                                source: card.modelData.thumb !== "" ? "file://" + card.modelData.thumb : ""
                                sourceSize.width: Style.space(128)
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                cache: false
                            }
                            // A code card recorded before it was ever exported
                            // has no picture yet.
                            Text {
                                anchors.centerIn: parent
                                visible: card.modelData.thumb === ""
                                text: card.modelData.kind === "code" ? "\uf121" : "\uf03e"
                                color: Ui.textMuted
                                font.family: Style.font.family
                                font.pixelSize: Style.font.icon
                            }

                            HoverHandler {
                                id: cardHover
                                cursorShape: Qt.PointingHandCursor
                            }
                            TapHandler {
                                acceptedButtons: Qt.LeftButton
                                onTapped: editor.recentRequested(card.modelData.id)
                            }
                            TapHandler {
                                acceptedButtons: Qt.MiddleButton
                                onTapped: editor.forgetRecentRequested(card.modelData.id)
                            }
                            Tooltip {
                                target: card
                                text: card.modelData.title + (card.modelData.marks.length
                                      ? "  \u00b7  " + Model.plural(card.modelData.marks.length, "mark") : "")
                                      + "  \u00b7  click to reopen, middle-click to forget"
                                show: cardHover.hovered
                            }
                        }
                    }
                }
            }
        }
    }

    Inspector {
        id: inspector
        doc: editor.doc
        systemThemes: editor.systemThemes
        anchors { top: header.bottom; bottom: footer.top; right: parent.right }
        width: Style.space(300)
        visible: doc.hasContent && editor.panel === ""
        onCopyTextRequested: editor.copyTextRequested()
        onLogoRequested: editor.logoRequested()
        onShotRequested: function (action, id) { editor.shotRequested(action, id); }
        onEyedropRequested: function (done) { editor.eyedropRequested(done); }
    }

    Settings {
        id: settingsPanel
        doc: editor.doc
        saveDir: editor.saveDir
        anchors { top: header.bottom; bottom: footer.top; right: parent.right }
        width: inspector.width
        visible: editor.panel === "settings"
    }

    About {
        id: aboutPanel
        manifest: editor.manifest
        anchors { top: header.bottom; bottom: footer.top; right: parent.right }
        width: inspector.width
        visible: editor.panel === "about"
        onLinkOpened: editor.closeRequested()
    }

    Rectangle {
        visible: rail.visible
        anchors { left: rail.right; top: rail.top; bottom: rail.bottom }
        width: 1
        color: Ui.hairline
    }

    Rectangle {
        visible: editor.sidePanel !== null
        anchors { right: editor.sidePanel ? editor.sidePanel.left : parent.right
                  top: header.bottom; bottom: footer.top }
        width: 1
        color: Ui.hairline
    }

    Item {
        id: footer
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        height: Ui.button + Ui.pad

        Rectangle {
            anchors.top: parent.top
            width: parent.width
            height: 1
            color: Ui.hairline
        }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: Ui.pad
            anchors.verticalCenter: parent.verticalCenter
            width: Math.min(implicitWidth, parent.width - Style.space(400))
            elide: Text.ElideRight
            text: editor.statusText !== "" ? editor.statusText
                  : doc.outputTooLarge ? "Too large to render at " + doc.exportScale + "\u00d7 \u2014 pick a smaller export scale"
                  : (doc.hasContent ? (viewport.zoom > 1 ? "Zoom " : "")
                                   + Math.round(viewport.viewScale * 100) + "%  \u00b7  "
                                   + doc.geo.frameW + "\u00d7" + doc.geo.frameH
                                   + " \u2192 " + doc.outWidth + "\u00d7" + doc.outHeight
                                 : "")
            color: editor.statusText !== "" ? Ui.text : Ui.textMuted
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
        }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: Ui.pad
            anchors.verticalCenter: parent.verticalCenter
            spacing: Ui.gap
            visible: doc.hasContent

            IconButton {
                glyph: "\u{F099B}"
                tip: "Reset styling"
                flat: true
                onClicked: doc.reset()
            }
            IconButton {
                id: dragOut
                glyph: "\uf0b2"
                label: "Drag"
                tip: "Hold and drag the picture into another app"
                onPressStarted: editor.dragOutRequested()

                Drag.dragType: Drag.Automatic
                Drag.supportedActions: Qt.CopyAction
                Drag.proposedAction: Qt.CopyAction
                // The picture itself would be the size of the export.
                Drag.imageSourceSize: Qt.size(Style.space(200),
                                              Style.space(200) * doc.outHeight / Math.max(1, doc.outWidth))
                // Not told whether it was taken: Qt reports no action even
                // for a drop another window accepted.
                Drag.onDragFinished: editor.draggingOut = false
            }
            IconButton {
                glyph: "\uf0c5"
                label: editor.busy ? "Working\u2026" : "Copy"
                onClicked: editor.copyRequested()
            }
            IconButton {
                glyph: "\uf0c7"
                flat: true
                tip: "Save as\u2026 (Ctrl+Shift+S)"
                onClicked: editor.saveAsRequested()
            }
            IconButton {
                glyph: "\uf019"
                label: "Save"
                tip: "Save to " + editor.saveDir + " (Ctrl+S)"
                primary: true
                onClicked: editor.saveRequested()
            }
        }
    }

    Timer {
        id: statusTimer
        interval: 3200
        onTriggered: editor.statusText = ""
    }
    onStatusTextChanged: if (statusText !== "") statusTimer.restart()
}
