import QtQuick
import QtTest
import "../../../ui"
import "../../../lib/Model.js" as Model

// Marks pressed and dragged the way a pointer does it. What has to hold is
// that nothing leaves the picture, here a 400x300 shot with no padding.
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

        function test_a_label_that_grows_slides_back() {
            var u = add({ kind: "text", x: 330, y: 50, text: "Hi", fontSize: 20, width: 3 });
            wait(30);
            doc.updateAnnotation(u, { text: "A much longer label" });
            wait(50);
            verify(row(u).x + doc.shownSizes[u].w <= 400.01);
        }

        function test_a_wrapping_label_is_widened_by_its_right_side() {
            var u = add({ kind: "text", x: 50, y: 50, w: 120, text: "A label that wraps", fontSize: 16, width: 3 });
            doc.selectedId = u;
            wait(30);
            // The right side, half way down the label, pulled out by 60.
            var h = doc.shownSizes[u].h;
            // Taken 3px out from the side and held there, so the side lands
            // 3px short of where the pointer stops.
            drag(170 + 3, 50 + h / 2, 60, 0);
            compare(row(u).w, 180);
            compare(row(u).x, 50, "the label itself stays put");
        }

        function test_a_filled_box_is_taken_from_its_middle() {
            var u = add({ kind: "box", x: 100, y: 100, w: 80, h: 60, width: 4, fill: true });
            drag(140, 130, 20, 10);
            // The drag threshold eats the first pixels, so near rather than exact.
            verify(row(u).x >= 115 && row(u).x <= 120, "moved by about 20: " + row(u).x);
            verify(row(u).y >= 105 && row(u).y <= 110, "moved by about 10: " + row(u).y);
            // A hollow one is empty in the middle and is not.
            var v = add({ kind: "box", x: 200, y: 100, w: 80, h: 60, width: 4 });
            drag(240, 130, 20, 10);
            compare(row(v).x, 200);
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
