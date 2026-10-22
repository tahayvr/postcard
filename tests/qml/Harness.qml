import QtQuick
import "../../ui"
import "../../lib/Model.js" as Model

// Offscreen render of the stage with one of every annotation, exported the
// same way the overlay does it. tests/qml/render.sh checks the pixels.
Window {
    id: win
    visible: true
    width: 640
    height: 480

    // render.sh passes the output directory as the last argument: a file
    // written under the plugin directory reloads the plugin in the running
    // shell, and a full test run writes seven of them.
    readonly property string outDir: {
        var a = Qt.application.arguments;
        var last = a.length ? String(a[a.length - 1]) : "";
        if (last.charAt(0) !== "/") return "/tmp/postcard-tests/";
        return last.charAt(last.length - 1) === "/" ? last : last + "/";
    }

    Doc { id: doc }

    // Grabbed the way Editor.qml does it: a wrapper padded up to whole device
    // pixels, cropped afterwards by render.sh as postcard-deliver would.
    Item {
        id: grabRoot
        readonly property var fit: Model.grabSize(stage.width, stage.height, stage.dpr)
        width: grabRoot.fit.w
        height: grabRoot.fit.h
        scale: 0.5                       // displayed smaller, like the editor
        transformOrigin: Item.TopLeft

        Stage {
            id: stage
            doc: doc
            interactive: true
        }
    }

    Component.onCompleted: {
        doc.shotPath = win.outDir + "shot.png";
        doc.shotWidth = 400;
        doc.shotHeight = 200;
        doc.bgMode = "solid";
        doc.bgSolid = "#00ff00";
        doc.padding = 10;                // 10% of 400 = 40px each side
        doc.radius = 0;
        doc.shadow = 0;
        doc.frame = "none";
        doc.exportScale = 1;

        var box = Model.newAnnotation("box", 10, 10);
        box.w = 50; box.h = 50; box.color = "#0000ff"; box.width = 4;
        doc.addAnnotation(box);          // also selects it: the outline must not export

        var redact = Model.newAnnotation("redact", 150, 50);
        redact.w = 100; redact.h = 100; redact.strength = 25;
        doc.annotations.append(redact);

        var step = Model.newAnnotation("step", 300 - 18, 100 - 18);
        step.w = 36; step.h = 36; step.index = 7; step.color = "#ff0000";
        doc.annotations.append(step);

        // A white badge, whose number has to be dark to be seen at all.
        var pale = Model.newAnnotation("step", 120, 10);
        pale.w = 36; pale.h = 36; pale.index = 3; pale.color = "#ffffff";
        doc.annotations.append(pale);

        var arrow = Model.newAnnotation("arrow", 320, 20);
        arrow.w = 60; arrow.h = 60; arrow.color = "#ff00ff"; arrow.width = 4;
        doc.annotations.append(arrow);

        // Bowing up from a flat run: its apex has to be off the chord.
        var curve = Model.newAnnotation("arrow", 250, 175);
        curve.w = 80; curve.h = 0; curve.color = "#00ffff"; curve.width = 4;
        curve.style = "curved";
        doc.annotations.append(curve);

        var label = Model.newAnnotation("text", 20, 150);
        label.text = "Hello"; label.color = "#000000"; label.width = 4;
        doc.annotations.append(label);

        var empty = Model.newAnnotation("text", 20, 100);
        empty.text = ""; empty.color = "#000000"; empty.width = 4;
        doc.annotations.append(empty);   // placeholder must not export

        // A solid hidden area inside the stripe band: one flat dark block.
        var solid = Model.newAnnotation("redact", 260, 60);
        solid.w = 20; solid.h = 20; solid.style = "solid";
        doc.annotations.append(solid);

        // A filled box with rounded corners on the black half: yellow inside,
        // and its very corner left black by the rounding.
        var filled = Model.newAnnotation("box", 340, 120);
        filled.w = 40; filled.h = 40; filled.color = "#ffff00"; filled.width = 4;
        filled.fill = true; filled.corner = 20;
        doc.annotations.append(filled);

        // A label on a cream pill, on the black half.
        var pill = Model.newAnnotation("text", 220, 160);
        pill.text = "Pill"; pill.color = "#000000"; pill.width = 4; pill.textStyle = "pill";
        pill.fontSize = 16;
        doc.annotations.append(pill);

        // Editing chrome must not reach the file: the crop tool is in hand
        // with a selection over a corner of the shot, and every check below
        // still reads the bare picture.
        doc.tool = "crop";
        doc.cropRect = Qt.rect(0, 0, 200, 120);

        doc.annotationsEdited();
        grabTimer.start();
    }

    // grabToImage is asynchronous, so the two exports are chained rather than
    // fired together: the second one changes the geometry the first is using.
    function grab(name, done) {
        doc.exporting = true;
        Qt.callLater(function () {
            var size = Qt.size(grabRoot.width * doc.exportScale, grabRoot.height * doc.exportScale);
            var ok = grabRoot.grabToImage(function (r) {
                var wrote = r.saveToFile(win.outDir + name + ".png");
                console.warn("HARNESS " + name + " " + (wrote ? "ok" : "write-failed")
                             + " expected " + doc.outWidth + "x" + doc.outHeight
                             + " dpr " + stage.dpr);
                done();
            }, size);
            if (!ok) { console.warn("HARNESS grab-failed"); Qt.quit(); }
        });
    }

    Timer {
        id: grabTimer
        interval: 600
        onTriggered: win.grab("export", function () {
            // The same frame with the wrapper displayed zoomed in, as the
            // editor shows it: the grab renders the item at its own size, so
            // the file has to come out the same.
            grabRoot.scale = 2.5;
            zoomTimer.start();
        })
    }

    Timer {
        id: zoomTimer
        interval: 250
        onTriggered: win.grab("export-zoomed", function () {
            grabRoot.scale = 0.5;
            // The inset extends the shot's edge color: the left edge of this
            // synthetic shot is white, the right edge black.
            doc.shotEdge = "#ff00ff";
            doc.inset = 10;              // 10% of 400 = 40px on every side
            insetTimer.start();
        })
    }

    Timer {
        id: insetTimer
        interval: 250
        onTriggered: win.grab("export-inset", function () {
            // A preset that turns through a color on its way. Plenty of
            // padding so there is background to sample, and no card in the
            // way of the middle of the ramp.
            doc.inset = 0;
            doc.padding = 40;
            doc.bgMode = "gradient";
            doc.bgGradient = "aurora";
            gradientTimer.start();
        })
    }

    Timer {
        id: gradientTimer
        interval: 250
        onTriggered: win.grab("export-gradient", function () {
            // A multipoint preset, which varies in two directions rather than
            // one: the test reads corners a ramp could not tell apart.
            doc.bgGradient = "bloom";
            meshTimer.start();
        })
    }

    Timer {
        id: meshTimer
        interval: 350
        onTriggered: win.grab("export-mesh", function () {
            // A frame that is not a whole number of logical pixels at any
            // fractional scale: 5.5% of 400 is 22, so 444x244, which no
            // 1.25, 1.5 or 1.6 divides. The sizes above all happened to.
            doc.bgMode = "solid";
            doc.padding = 5.5;
            oddTimer.start();
        })
    }

    Timer {
        id: oddTimer
        interval: 250
        onTriggered: win.grab("export-odd", function () {
            // Back to the first frame, with everything but a spotlight
            // cleared: the dim has to land on the picture and nowhere else.
            doc.padding = 10;
            doc.clearAnnotations();
            // Clear of the stripe band, so the hole is plain white and a
            // dimmed reading cannot be confused with the stripes.
            var spot = Model.newAnnotation("spotlight", 10, 10);
            spot.w = 80; spot.h = 180;
            doc.addAnnotation(spot);
            doc.selectedId = "";
            doc.spotShape = "rect";
            doc.spotDim = 60;
            spotTimer.start();
        })
    }

    Timer {
        id: spotTimer
        interval: 250
        onTriggered: win.grab("export-spot", function () {
            doc.spotShape = "ellipse";
            ovalTimer.start();
        })
    }

    Timer {
        id: ovalTimer
        interval: 250
        onTriggered: win.grab("export-spot-oval", function () {
            doc.spotShape = "rounded";
            doc.spotRing = true;
            // A second one on the black half, where a ring inside the hole's
            // edge shows against what the hole leaves lit.
            var onBlack = Model.newAnnotation("spotlight", 310, 150);
            onBlack.w = 80; onBlack.h = 40;
            doc.addAnnotation(onBlack);
            doc.selectedId = "";
            ringTimer.start();
        })
    }

    Timer {
        id: ringTimer
        interval: 250
        onTriggered: win.grab("export-spot-ring", function () {
            doc.spotRing = false;
            // A rounded card with a square spotlight a little along from its
            // top left corner, where the hole must not darken the padding,
            // and two spotlights overlapping, where both must stay lit.
            doc.clearAnnotations();
            doc.radius = 20;            // 20% of the card's 200px
            doc.spotShape = "rect";
            var corner = Model.newAnnotation("spotlight", 5, 0);
            corner.w = 60; corner.h = 60;
            doc.annotations.append(corner);
            var first = Model.newAnnotation("spotlight", 100, 155);
            first.w = 40; first.h = 40;
            doc.annotations.append(first);
            var second = Model.newAnnotation("spotlight", 120, 160);
            second.w = 40; second.h = 40;
            doc.annotations.append(second);
            doc.selectedId = "";
            doc.annotationsEdited();
            edgeTimer.start();
        })
    }

    Timer {
        id: edgeTimer
        interval: 250
        onTriggered: win.grab("export-spot-edge", function () {
            doc.radius = 0;
            // Two square spotlights magnifying 4x with no dim: one on the
            // stripes, whose edges have to stay sharp rather than blend,
            // and one centred just inside a hidden area, so the blocks it
            // magnifies land outside the hidden mark itself, where nothing
            // covers them; they have to be blocks rather than the stripes.
            doc.clearAnnotations();
            var hide = Model.newAnnotation("redact", 220, 60);
            hide.w = 60; hide.h = 60; hide.strength = 20;
            doc.annotations.append(hide);

            var onStripes = Model.newAnnotation("spotlight", 100, 80);
            onStripes.w = 40; onStripes.h = 40;
            doc.annotations.append(onStripes);

            var onHidden = Model.newAnnotation("spotlight", 255, 70);
            onHidden.w = 40; onHidden.h = 40;
            doc.annotations.append(onHidden);

            // And a solid block, magnified past its edge the same way: what
            // lies outside the mark has to be the block's color, not white.
            var solid = Model.newAnnotation("redact", 20, 20);
            solid.w = 40; solid.h = 40; solid.style = "solid";
            doc.annotations.append(solid);
            var onSolid = Model.newAnnotation("spotlight", 38, 20);
            onSolid.w = 40; onSolid.h = 40;
            doc.annotations.append(onSolid);
            doc.spotShape = "rect";
            doc.spotDim = 0;
            doc.spotZoom = 4;
            doc.selectedId = "";
            doc.annotationsEdited();
            magnifyTimer.start();
        })
    }

    Timer {
        id: magnifyTimer
        interval: 350
        onTriggered: win.grab("export-magnify", function () {
            doc.spotZoom = 1;
            // Two shots on one card: the picture and a solid blue one beside
            // it, from a sheet render.sh composed. Each card has to show its
            // own part of the sheet, 1:1, with the background in the gap.
            doc.clearAnnotations();
            var a = Model.newSlot(win.outDir + "shot.png", 400, 200);
            var b = Model.newSlot(win.outDir + "blue.png", 100, 200);
            doc.inset = 0;
            doc.padding = 0;
            doc.slotGap = 4;             // 4% of 200 = 8px
            doc.matchSizes = true;
            doc.layoutDir = "row";
            doc.slots = [a, b];
            doc.sheet = Model.sheetLayout(doc.slots, { dir: "row", gap: 4, match: true, align: "center",
                                                       inset: 0, frame: "none" });
            doc.shotPath = win.outDir + "sheet.png";
            doc.shotWidth = doc.sheet.w;
            doc.shotHeight = doc.sheet.h;
            twoTimer.start();
        })
    }

    Timer {
        id: twoTimer
        interval: 350
        onTriggered: win.grab("export-two", function () { Qt.quit(); })
    }
}
