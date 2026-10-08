import QtQuick
import QtTest
import "../../../ui"
import "../../../lib/Model.js" as Model

// Marks pressed and dragged the way a pointer does it. What has to hold is
// that nothing leaves the picture, here a 400x300 shot with no padding, and
// that a magnifier's area is taken before the handle lying over it.
Item {
    width: 400
    height: 300

    Doc {
        id: doc
        tool: "select"
        shotWidth: 400
        shotHeight: 300
        padding: 0
        inset: 0
        frame: "none"
        ratio: "auto"
    }

    AnnotationLayer {
        id: marks
        anchors.fill: parent
        doc: doc
        interactive: true
        viewScale: 1
    }

    TestCase {
        name: "marks"
        when: windowShown

        function add(o) {
            var n = Model.newAnnotation(o.kind, o.x, o.y);
            for (var k in o) n[k] = o[k];
            doc.addAnnotation(n);
            return n.uid;
        }

        function row(uid) {
            return doc.annotations.get(doc.indexOfId(uid));
        }

        // A pixel at a time, as a pointer moves.
        function drag(x0, y0, dx, dy) {
            mousePress(marks, x0, y0);
            var n = Math.max(Math.abs(dx), Math.abs(dy));
            for (var i = 1; i <= n; i++) mouseMove(marks, x0 + dx * i / n, y0 + dy * i / n);
            mouseRelease(marks, x0 + dx, y0 + dy);
            wait(20);
        }

        function init() {
            doc.clearAnnotations();
            doc.selectedId = "";
            wait(10);
        }

        function test_area() {
            compare(JSON.stringify(doc.pictureArea), JSON.stringify({ x: 0, y: 0, w: 400, h: 300 }));
        }

        function test_move_stops_at_the_edge() {
            var u = add({ kind: "box", x: 300, y: 100, w: 60, h: 40, width: 4 });
            drag(301, 120, 200, 0);
            compare(row(u).x, 340);
        }

        function test_resize_stops_at_the_edge() {
            var u = add({ kind: "box", x: 300, y: 100, w: 60, h: 40, width: 4 });
            doc.selectedId = u;
            wait(10);
            // The bottom right corner, pulled out past both edges.
            drag(363, 143, 200, 200);
            var r = row(u);
            compare(r.x + r.w, 400);
            compare(r.y + r.h, 300);
        }

        function test_magnifier_area_is_taken_first_and_takes_the_lens() {
            var u = add({ kind: "magnify", x: 0, y: 0, w: 80, h: 80, sx: 100, sy: 200, zoom: 2, width: 3 });
            // Set up and to the right, its corner handle over the area.
            doc.updateAnnotation(u, Model.placeMagnifier(100, 200, 20, 2, doc.pictureArea));
            doc.selectedId = u;
            wait(20);
            var before = JSON.parse(JSON.stringify(row(u)));
            drag(110, 195, -30, -40);
            var r = row(u);
            compare(r.sx - before.sx, -30);
            compare(r.sy - before.sy, -40);
            compare(r.x - before.x, -30, "the lens went along");
            compare(r.y - before.y, -40);
            compare(r.w, before.w, "and was not resized");
        }

        function test_a_label_that_grows_slides_back() {
            var u = add({ kind: "text", x: 330, y: 50, text: "Hi", fontSize: 20, width: 3 });
            wait(30);
            doc.updateAnnotation(u, { text: "A much longer label" });
            wait(50);
            verify(row(u).x + doc.shownSizes[u].w <= 400.01);
        }

        function test_a_curve_flattens_to_fit() {
            var u = add({ kind: "arrow", x: 50, y: 60, w: 300, h: 0, style: "curved", bend: 0.3, width: 3 });
            doc.selectedId = u;
            wait(20);
            // The tail pulled up, which lifts the bulge past the top.
            drag(50, 60, 0, -45);
            var r = row(u);
            verify(r.bend > 0 && r.bend < 0.3, "eased, not straightened: " + r.bend);
            verify(Model.arrowBounds(r).y >= -0.01);
        }
    }
}
