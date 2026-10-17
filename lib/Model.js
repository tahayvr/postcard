.pragma library

// r of 0 follows the shot.
var RATIOS = [
    { key: "auto",  label: "Auto",   r: 0 },
    { key: "16:9",  label: "16:9",   r: 16 / 9 },
    { key: "4:3",   label: "4:3",    r: 4 / 3 },
    { key: "3:2",   label: "3:2",    r: 3 / 2 },
    { key: "1:1",   label: "1:1",    r: 1 },
    { key: "4:5",   label: "4:5",    r: 4 / 5 },
    { key: "9:16",  label: "9:16",   r: 9 / 16 },
    { key: "1.91",  label: "OG",     r: 1.91 }
];

// Backgrounds. `stops` is a list of colors spread evenly from one corner to
// the other, or {at, color} for a stop placed by hand. Two of them make the
// plain linear ramps; more make a gradient that turns through a colour on its
// way, which two stops cannot do.
var GRADIENT_STOPS = 5;          // slots Stage binds; presets may use fewer

var GRADIENTS = [
    { key: "dusk",     angle: 135, stops: ["#3b2f5e", "#7b5ea7"] },
    { key: "ember",    angle: 120, stops: ["#7a2e2e", "#e0764a"] },
    { key: "moss",     angle: 150, stops: ["#1f3d2b", "#5c8a58"] },
    { key: "slate",    angle: 160, stops: ["#1f2430", "#4a5568"] },
    { key: "tide",     angle: 130, stops: ["#123a5c", "#4aa6c7"] },
    { key: "sand",     angle: 110, stops: ["#8a6d3b", "#e3c391"] },
    { key: "plum",     angle: 140, stops: ["#4a1d3f", "#b0577f"] },
    { key: "rose",     angle: 125, stops: ["#6d2a44", "#e39ab0"] },
    { key: "teal",     angle: 145, stops: ["#10403f", "#57c9bd"] },
    { key: "ink",      angle: 180, stops: ["#0d0d12", "#2b2b38"] },
    { key: "aurora",   angle: 150, stops: ["#08203e", "#15756b", "#9fe0a8"] },
    { key: "sunset",   angle: 120, stops: ["#231942", "#9e3d6b", "#e8915b"] },
    { key: "nebula",   angle: 140, stops: ["#12091f", "#4a2a6b", "#9b4f8e", "#d98fb0"] },
    { key: "canyon",   angle: 125, stops: ["#2a1410", "#7d3b23", "#c97a3e", "#e8c07a"] },
    { key: "twilight", angle: 160, stops: ["#0d1b2a", "#3d5a80", "#98c1d9", "#e0fbfc"] },

    // Multipoint, or mesh: colors placed about the frame rather than
    // strung along one axis. `base` shows wherever no point reaches.
    { key: "bloom", base: "#241b3a", points: [
        { x: 0.18, y: 0.2, r: 0.75, color: "#6d4bd6" },
        { x: 0.85, y: 0.12, r: 0.7, color: "#e0567a" },
        { x: 0.75, y: 0.85, r: 0.8, color: "#f0a05a" },
        { x: 0.1, y: 0.9, r: 0.7, color: "#2ec5b6" }] },
    { key: "lagoon", base: "#06202e", points: [
        { x: 0.2, y: 0.15, r: 0.75, color: "#1c7fa8" },
        { x: 0.88, y: 0.3, r: 0.7, color: "#2ec5b6" },
        { x: 0.55, y: 0.9, r: 0.8, color: "#0f5d7a" },
        { x: 0.05, y: 0.7, r: 0.65, color: "#3fd6c4" }] },
    { key: "magma", base: "#180a06", points: [
        { x: 0.15, y: 0.85, r: 0.75, color: "#c2341c" },
        { x: 0.8, y: 0.7, r: 0.7, color: "#e8761f" },
        { x: 0.55, y: 0.15, r: 0.75, color: "#7a1f3d" },
        { x: 0.95, y: 0.05, r: 0.55, color: "#f0c040" }] },
    { key: "orchid", base: "#2a1233", points: [
        { x: 0.15, y: 0.25, r: 0.7, color: "#8a3fb0" },
        { x: 0.85, y: 0.2, r: 0.7, color: "#e06fa8" },
        { x: 0.7, y: 0.88, r: 0.75, color: "#4a5fd0" },
        { x: 0.12, y: 0.85, r: 0.65, color: "#c25f9e" }] },
    { key: "dune", base: "#2b1d14", points: [
        { x: 0.2, y: 0.2, r: 0.72, color: "#a8642c" },
        { x: 0.85, y: 0.35, r: 0.7, color: "#e0b060" },
        { x: 0.6, y: 0.9, r: 0.78, color: "#8a3f3a" },
        { x: 0.05, y: 0.8, r: 0.6, color: "#d9944f" }] },
    { key: "frost", base: "#c9d6e4", points: [
        { x: 0.2, y: 0.18, r: 0.72, color: "#eef4fb" },
        { x: 0.85, y: 0.25, r: 0.68, color: "#a9c3e0" },
        { x: 0.7, y: 0.88, r: 0.75, color: "#c7b8e8" },
        { x: 0.1, y: 0.85, r: 0.65, color: "#dce8f2" }] },
    { key: "jade", base: "#0b2018", points: [
        { x: 0.22, y: 0.2, r: 0.72, color: "#1f7a52" },
        { x: 0.85, y: 0.28, r: 0.68, color: "#5fc48a" },
        { x: 0.6, y: 0.9, r: 0.78, color: "#0f4f3a" },
        { x: 0.08, y: 0.82, r: 0.62, color: "#9ad86a" }] },
    { key: "iris", base: "#0d1030", points: [
        { x: 0.18, y: 0.22, r: 0.72, color: "#3b4fd0" },
        { x: 0.85, y: 0.18, r: 0.68, color: "#7a5fe0" },
        { x: 0.72, y: 0.85, r: 0.75, color: "#d060a8" },
        { x: 0.08, y: 0.85, r: 0.65, color: "#2a80c9" }] },
    { key: "peach", base: "#e8d5c8", points: [
        { x: 0.2, y: 0.2, r: 0.7, color: "#f6e3d2" },
        { x: 0.85, y: 0.28, r: 0.68, color: "#f0a78f" },
        { x: 0.68, y: 0.88, r: 0.75, color: "#e0798a" },
        { x: 0.08, y: 0.85, r: 0.62, color: "#f5c9a0" }] },
    { key: "cosmos", base: "#07060f", points: [
        { x: 0.25, y: 0.18, r: 0.7, color: "#4a2f8a" },
        { x: 0.82, y: 0.22, r: 0.65, color: "#1f5fa8" },
        { x: 0.65, y: 0.85, r: 0.75, color: "#a03f7a" },
        { x: 0.1, y: 0.78, r: 0.6, color: "#2f8a8a" }] }
];

var MAX_OUTPUT_SIDE = 16384;   // common GPU texture limit
var XTERM_BLACK = "#000000";

var ARROW_STYLES = [
    { key: "straight", glyph: "\u{F005C}", label: "Straight" },
    { key: "curved",   glyph: "\u{F17AB}", label: "Curved" },
    { key: "line",     glyph: "\u{F0FDF}", label: "Line, no head" },
    { key: "double",   glyph: "\u{F0E73}", label: "A head at each end" }
];
// A head's length, never under ARROW_HEAD_MIN so it still reads on a thin
// stroke, and how far each side of it spreads from the line.
var ARROW_HEAD_MIN = 14;
var ARROW_SPREAD = 27.5 * Math.PI / 180;

function arrowHead(stroke) {
    return Math.max((stroke || 1) * 3.2, ARROW_HEAD_MIN);
}

var ARROW_BOW = 0.22;              // how far a new curve leaves the straight line
var ARROW_BOW_MAX = 1;             // either way; past it the curve folds back on itself

// A curved arrow's own bend, as a share of its length and signed for the
// side it bows to. Read through here, so a row without one still curves.
function arrowBend(a) {
    var b = a ? a.bend : undefined;
    return typeof b === "number" && isFinite(b) ? clamp(b, -ARROW_BOW_MAX, ARROW_BOW_MAX) : ARROW_BOW;
}

function newAnnotation(kind, x, y) {
    return {
        uid: Math.random().toString(36).slice(2, 10),
        kind: kind,
        x: x, y: y, w: 0, h: 0,
        color: "",                 // "" means "use the current ink color"
        width: 3,
        style: "",                 // arrows: straight | curved | line | double; redact: pixelate | solid
        bend: ARROW_BOW,           // curved arrows: see arrowBend
        text: "",
        index: 0,
        strength: 14,              // pixelation block size for redact
        fontSize: 0,               // text: pixels, 0 on rows from before it
        font: "",                  // text: a TEXT_FONTS key, "" on rows from before it
        textStyle: "",             // text: a TEXT_STYLES key, "" (outline) on rows from before it
        fill: false,               // box, ellipse: filled rather than outlined
        corner: -1                 // box: corner radius in shot pixels; -1 follows the stroke
    };
}

// How a hidden area is drawn. Pixelation samples one color per block, which
// is already unrecoverable at the block sizes used; solid is the one choice
// that leaks nothing at all, not even the shape of a word.
var REDACT_STYLES = [
    { key: "pixelate", label: "Pixels" },
    { key: "solid",    label: "Solid" }
];

function redactStyle(a) {
    return a && a.style === "solid" ? "solid" : "pixelate";
}

// What a label sits on: an outline (the look it always had), a cream pill
// that reads on any picture, or nothing.
var TEXT_STYLES = [
    { key: "outline", label: "Outline" },
    { key: "pill",    label: "Pill" },
    { key: "plain",   label: "Plain" }
];
var PILL_COLOR = "#f8f5eb";

function textStyle(a) {
    var s = a ? a.textStyle : "";
    return s === "pill" || s === "plain" ? s : "outline";
}

// A dragged-out label wraps at the width of its box; a clicked one is as
// wide as its text. Narrower than this and the drag was a click.
var MIN_TEXT_WRAP = 24;

// A box's corners: the ones it was given, or a touch of rounding that
// follows the stroke, which is what every box had before corners were a
// setting. The default stroke of 4 gives 6, so the default look is unchanged.
var DEFAULT_CORNER = 6;
var MAX_CORNER = 60;

function boxRadius(a, stroke) {
    var c = a ? Number(a.corner) : -1;
    if (!(c >= 0)) return Math.max(1, stroke || 1) * 1.5;
    return Math.min(c, Math.abs(a.w) / 2, Math.abs(a.h) / 2);
}

// --- Drawing with Shift and Alt ---------------------------------------------
// Pure, so the harness can drive them without a pointer. All in shot pixels,
// signs kept: w and h say which way the drag went.

// Shift holds a drag to a square (the smaller extent, so it never reaches
// past where the pointer is) and an arrow to the nearest 45 degrees.
function constrainDrag(kind, w, h) {
    if (kind === "arrow") {
        var len = Math.sqrt(w * w + h * h);
        if (len < 1) return { w: w, h: h };
        var ang = Math.round(Math.atan2(h, w) / (Math.PI / 4)) * (Math.PI / 4);
        return { w: Math.round(Math.cos(ang) * len * 1000) / 1000, h: Math.round(Math.sin(ang) * len * 1000) / 1000 };
    }
    var e = Math.min(Math.abs(w), Math.abs(h));
    return { w: w < 0 ? -e : e, h: h < 0 ? -e : e };
}

// Which kinds Alt draws from the middle out, and Shift squares up.
function drawsFromCentre(kind) {
    return ["box", "ellipse", "spotlight", "highlight", "redact"].indexOf(kind) !== -1;
}

// Alt: the press is the middle, and the pointer one corner, so the mark
// reaches as far the other way. Held inside the picture by cutting the
// shorter reach, so both corners stay in.
function centredDrag(ox, oy, w, h, area) {
    var ew = Math.abs(w), eh = Math.abs(h);
    if (area) {
        ew = Math.min(ew, ox - area.x, area.x + area.w - ox);
        eh = Math.min(eh, oy - area.y, area.y + area.h - oy);
        ew = Math.max(0, ew); eh = Math.max(0, eh);
    }
    return { x: ox - ew, y: oy - eh, w: ew * 2, h: eh * 2 };
}

// A corner pulled with Shift keeps the mark's proportions: the axis the
// pointer has moved more wins and the other follows (Omasnap's rule).
function aspectLockedPoint(fixed, originalMoving, candidate) {
    var ox = originalMoving.x - fixed.x, oy = originalMoving.y - fixed.y;
    if (Math.abs(ox) < 1e-6 || Math.abs(oy) < 1e-6) return candidate;
    var dx = candidate.x - fixed.x, dy = candidate.y - fixed.y;
    var k = Math.max(Math.abs(dx) / Math.abs(ox), Math.abs(dy) / Math.abs(oy));
    var sx = dx < 0 ? -1 : 1, sy = dy < 0 ? -1 : 1;
    return { x: fixed.x + sx * Math.abs(ox) * k, y: fixed.y + sy * Math.abs(oy) * k };
}

// The corner a handle pulls against: the one diagonally opposite.
function oppositeCorner(a, key) {
    var r = normalised(a);
    return { x: key.indexOf("l") !== -1 ? r.x + r.w : r.x,
             y: key.indexOf("t") !== -1 ? r.y + r.h : r.y };
}

// Where copies land: a step down and right of the originals, or back the
// other way on an axis where that would push the first of them past the
// edge, so a copy of a mark in the corner is still a copy beside it.
function copyOffset(boxes, step, area) {
    var out = fitMove(boxes, step, step, area);
    var dx = out.dx, dy = out.dy;
    if (Math.abs(dx) < step) { var bx = fitMove(boxes, -step, 0, area).dx; if (Math.abs(bx) > Math.abs(dx)) dx = bx; }
    if (Math.abs(dy) < step) { var by = fitMove(boxes, 0, -step, area).dy; if (Math.abs(by) > Math.abs(dy)) dy = by; }
    return { dx: dx, dy: dy };
}

// Both ship with Omarchy, so neither needs a fallback.
var TEXT_FONTS = [
    { key: "mono", label: "Mono", family: "JetBrainsMono Nerd Font" },
    { key: "sans", label: "Sans", family: "iA Writer Quattro S" }
];

function textFamily(key) {
    for (var i = 0; i < TEXT_FONTS.length; i++)
        if (TEXT_FONTS[i].key === key) return TEXT_FONTS[i].family;
    return TEXT_FONTS[0].family;
}

// A pasted copy of a mark, moved off the original so both can be seen. It
// gets a uid of its own.
function duplicateAnnotation(a, dx, dy) {
    var c = plainAnnotation(a);
    c.uid = newAnnotation("", 0, 0).uid;
    c.x = a.x + dx;
    c.y = a.y + dy;
    return c;
}

function plural(n, word) {
    return n + " " + word + (n === 1 ? "" : "s");
}

// How far each paste steps from the last: enough to see on any shot.
function pasteStep(shotW, shotH) {
    return Math.max(12, Math.round(Math.max(shotW, shotH) / 80));
}

// Undo steps kept for one picture; each is every mark as it stood.
var HISTORY_KEPT = 200;

// The most text a code card takes, in characters: far past anything that
// reads as a card, and small enough that a huge selection cannot swamp the
// editor or the highlighter. bin/postcard-text stops reading at it too.
var CODE_MAX = 65536;

// Text cut down to CODE_MAX at a line break where there is one.
function clipCode(text, max) {
    var t = String(text || "");
    max = max || CODE_MAX;
    if (t.length <= max) return { text: t, cut: false };
    t = t.slice(0, max);
    var nl = t.lastIndexOf("\n");
    return { text: nl > 0 ? t.slice(0, nl) : t, cut: true };
}

var MIN_TEXT_SIZE = 8;

// A label made before text had a size of its own took it from the stroke.
function textSize(a) {
    return a.fontSize > 0 ? a.fontSize : Math.max(12, Math.max(1, a.width) * 6);
}

// Big enough to read on the card whatever the size of the shot.
function defaultTextSize(shotW, shotH) {
    return Math.max(16, Math.round(Math.max(shotW, shotH) / 60));
}

// A ListModel row is a live view that dies with the row, so anything kept
// after a remove (the redo stack) needs its roles copied out first.
function plainAnnotation(row) {
    var roles = newAnnotation("", 0, 0), o = {};
    for (var k in roles) o[k] = row[k];
    return o;
}

// How far an arrow's curve and heads can stand off the box it was dragged
// out in.
function arrowBulge(a) {
    var bow = a.style === "curved" ? Math.abs(arrowBend(a)) / 2 : 0;
    return Math.sqrt(a.w * a.w + a.h * a.h) * bow;
}

// Everything the arrow delegate draws, from the drag extents and the size of
// the head. The shaft is a quadratic curve whatever the style: with its
// control point on the midpoint it is the straight line, so one path serves
// all four. Both heads point along the curve, which at either end runs
// towards the control point, and the shaft stops short of a head so the head
// is the tip rather than sitting on top of a blunt end.
function arrowShape(w, h, style, head, bend) {
    var aw = Math.abs(w), ah = Math.abs(h);
    var x1 = w >= 0 ? 0 : aw, y1 = h >= 0 ? 0 : ah;
    var x2 = w >= 0 ? aw : 0, y2 = h >= 0 ? ah : 0;

    var curved = style === "curved";
    var headEnd = style !== "line";
    var headStart = style === "double";

    var bow = curved ? arrowBend({ bend: bend }) : 0;
    var cx = (x1 + x2) / 2 + (y2 - y1) * bow;
    var cy = (y1 + y2) / 2 - (x2 - x1) * bow;

    var angEnd = Math.atan2(y2 - cy, x2 - cx);
    var angStart = Math.atan2(y1 - cy, x1 - cx);
    var back = head * 0.82;

    return {
        cx: cx, cy: cy,
        tailX: x1, tailY: y1,
        tipX: x2, tipY: y2,
        sx: x1 - (headStart ? Math.cos(angStart) * back : 0),
        sy: y1 - (headStart ? Math.sin(angStart) * back : 0),
        ex: x2 - (headEnd ? Math.cos(angEnd) * back : 0),
        ey: y2 - (headEnd ? Math.sin(angEnd) * back : 0),
        angStart: angStart,
        angEnd: angEnd,
        headStart: headStart,
        headEnd: headEnd
    };
}

function parseHex(hex) {
    // Eight digits is a QML colour carrying its alpha in front; the alpha
    // says nothing about what reads against it.
    var m = /^#?(?:[0-9a-fA-F]{2})?([0-9a-fA-F]{6})$/.exec(String(hex || "").trim());
    if (!m) return null;
    var n = parseInt(m[1], 16);
    return { r: (n >> 16) & 255, g: (n >> 8) & 255, b: n & 255 };
}

function toHex(r, g, b) {
    function p(v) {
        var n = Math.round(clamp(v, 0, 255)).toString(16);
        return n.length < 2 ? "0" + n : n;
    }
    return "#" + p(r) + p(g) + p(b);
}

function luminance(c) {
    return 0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b;
}

// The title bar borrows the card's own dominant color so the two read as one
// window, one step away from it so the seam is still visible: darker over a
// light card, lighter over a dark one. Near-black needs an absolute lift as
// well, because scaling it up leaves it black.
function chromeTint(hex) {
    var c = parseHex(hex);
    if (!c) return "";
    if (luminance(c) > 150) return toHex(c.r * 0.9, c.g * 0.9, c.b * 0.9);
    return toHex(c.r + (255 - c.r) * 0.1 + 14,
                 c.g + (255 - c.g) * 0.1 + 14,
                 c.b + (255 - c.b) * 0.1 + 14);
}

// Title text that stays legible on whatever chromeTint produced.
function textOn(hex) {
    var c = parseHex(hex);
    if (!c) return "#e8e8e8";
    return luminance(c) > 150 ? "#1b1b1b" : "#f0f0f0";
}

// The card is the screenshot plus the title bar above it.
// With several shots the picture is the sheet they sit on, and sizing the
// title bar or the inset from that would move the shots, which would change
// the sheet again. baseWidth/baseHeight are the shots' own size instead.
function chromeHeight(doc) {
    var sh = Math.max(1, doc.baseHeight || doc.shotHeight);
    if (doc.frame === "titlebar")
        return clamp(Math.round(sh * 0.045), 28, 48);
    return 0;
}

// The inset grows the card around the shot and is filled with the shot's own
// edge color, so the screenshot reads as having more room inside its window.
// Padding, by contrast, grows the frame around the whole card.
function insetSize(doc) {
    var longest = Math.max(1, doc.baseWidth || doc.shotWidth, doc.baseHeight || doc.shotHeight);
    return Math.max(0, Math.round((doc.inset || 0) / 100 * longest));
}

function frameGeometry(doc) {
    var sw = Math.max(1, doc.shotWidth);
    var sh = Math.max(1, doc.shotHeight);
    var chrome = chromeHeight(doc);
    var inset = insetSize(doc);

    var cardW = sw + inset * 2;
    var cardH = sh + inset * 2 + chrome;

    var pad = Math.max(0, doc.padding / 100 * Math.max(cardW, cardH));

    var w = cardW + pad * 2;
    var h = cardH + pad * 2;

    var ratio = 0;
    for (var i = 0; i < RATIOS.length; i++)
        if (RATIOS[i].key === doc.ratio) ratio = RATIOS[i].r;

    if (ratio > 0) {
        if (w / h < ratio) w = h * ratio;
        else h = w / ratio;
    }

    var x = (w - cardW) / 2;
    var y = (h - cardH) / 2;

    // Arithmetically centred content reads as sitting low; lift it a little.
    if (doc.balance && ratio > 0) {
        var slack = (h - cardH) / 2;
        y = slack - Math.min(slack * 0.18, pad * 0.5);
    }

    return {
        frameW: Math.round(w),
        frameH: Math.round(h),
        cardX: Math.round(x),
        cardY: Math.round(y),
        cardW: cardW,
        cardH: cardH,
        chromeH: chrome,
        inset: inset,
        shotW: sw,
        shotH: sh,
        pad: pad
    };
}

// A handle or logo under the card's bottom-right corner, in shot pixels.
// Its size follows the card, scaled by the user's percentage. It sits in the
// padding when there is room for it and tucks inside the card's corner when
// there is not, rather than running off the frame.
function watermarkBox(geo, percent) {
    var size = Math.max(10, Math.round(Math.max(geo.cardW, geo.cardH) * 0.022 * (percent || 100) / 100));
    var rowH = Math.round(size * 1.35);
    var gap = Math.round(size * 0.6);
    var below = geo.frameH - (geo.cardY + geo.cardH);
    var inside = below < rowH + gap * 2;
    return {
        size: size,
        rowH: rowH,
        gap: gap,
        inside: inside,
        right: inside ? geo.cardX + geo.cardW - gap : geo.cardX + geo.cardW,
        top: inside ? geo.cardY + geo.cardH - gap - rowH : geo.cardY + geo.cardH + gap
    };
}

// Light or dark ink for whatever the mark sits on: the average of its
// colors. With nothing known underneath, as over a wallpaper or a
// transparent background, the answer is null and the mark is drawn light
// with an outline so it reads on either.
function watermarkInk(colors) {
    var list = (colors || []).map(parseHex).filter(function (c) { return c !== null; });
    if (list.length === 0) return null;
    var sum = 0;
    for (var i = 0; i < list.length; i++) sum += luminance(list[i]);
    return sum / list.length > 150 ? "#1b1b1b" : "#ffffff";
}

// grabToImage multiplies its target size by the window's device pixel ratio,
// and on a fractional ratio the stage is not a whole number of logical pixels:
// 1210 shot pixels are 756.25 of them at 1.6. Grabbing the stage at 757 would
// render it at 757/756.25 and resample every pixel, so the export grabs a
// wrapper around the stage instead, padded up to a whole number of device
// pixels, and postcard-deliver crops the surplus off. grabStep is the smallest
// run of logical pixels that is whole in device pixels: 5 at 1.6, 4 at 1.25,
// 2 at 1.5, 1 at any integer.
function grabStep(dpr) {
    var s = dpr > 0 ? dpr : 1;
    for (var k = 1; k <= 64; k++)
        if (Math.abs(k * s - Math.round(k * s)) < 1e-6) return k;
    return 1;
}

// The wrapper's size, in logical pixels, for a stage of the given size.
function grabSize(w, h, dpr) {
    var k = grabStep(dpr);
    return { w: Math.max(k, Math.ceil(w / k) * k), h: Math.max(k, Math.ceil(h / k) * k) };
}

function gradientByKey(key) {
    for (var i = 0; i < GRADIENTS.length; i++)
        if (GRADIENTS[i].key === key) return GRADIENTS[i];
    return GRADIENTS[0];
}

// The user's own gradient sits beside the presets under the key "custom";
// its stops and angle live on the document, which this library cannot see.
var CUSTOM_MIN_STOPS = 2;
var CUSTOM_MAX_STOPS = 4;
var CUSTOM_STOPS = ["#3b2f5e", "#7b5ea7"];
var CUSTOM_ANGLE = 135;

function gradientFor(key, customStops, customAngle) {
    if (key !== "custom") return gradientByKey(key);
    var stops = Array.isArray(customStops) && customStops.length >= CUSTOM_MIN_STOPS
              ? customStops.slice(0, CUSTOM_MAX_STOPS) : CUSTOM_STOPS;
    var angle = typeof customAngle === "number" && isFinite(customAngle) ? customAngle : CUSTOM_ANGLE;
    return { key: "custom", angle: Math.round(angle), stops: stops };
}

// Always GRADIENT_STOPS entries, so the stops can be bound declaratively
// rather than built at runtime. A preset with fewer repeats its last color at
// position 1, which renders identically to the shorter list.
function gradientStops(colors, angleless) {
    var raw = colors && colors.length ? colors : [];
    var out = [];
    for (var i = 0; i < raw.length; i++) {
        var s = raw[i];
        if (typeof s === "string")
            out.push({ at: raw.length < 2 ? 0 : i / (raw.length - 1), color: s });
        else if (s && s.color)
            out.push({ at: clamp(Number(s.at) || 0, 0, 1), color: String(s.color) });
    }
    if (!out.length) out.push({ at: 0, color: XTERM_BLACK });
    var last = out[out.length - 1];
    while (out.length < GRADIENT_STOPS) out.push({ at: 1, color: last.color });
    return out.slice(0, GRADIENT_STOPS);
}

// How many of the slots a preset actually uses; the README and the swatches
// want to say "three colors", not "five".
function gradientStopCount(key) {
    var g = gradientByKey(key);
    return g.stops ? g.stops.length : 0;
}

// Auto builds its ramp from one color rather than pairing the two most
// dominant ones. Those two are often unrelated — a bright logo and a dark
// terminal, say — and ramping between them drags the whole backdrop through
// muddy mid-tones, which reads as a cheap gradient however smoothly it is
// drawn. One color shaded both ways keeps the hue and stays close to the
// presets in spread.
function autoGradient(hex) {
    var c = parseHex(hex);
    if (!c) return [];
    function mix(t, target) {
        return toHex(c.r + (target - c.r) * t,
                     c.g + (target - c.g) * t,
                     c.b + (target - c.b) * t);
    }
    // A light backdrop has more room to darken than to lighten, and the other
    // way round, so the shading leans away from whichever end it sits near.
    var light = luminance(c) > 150;
    return light ? [mix(0.10, 255), mix(0.22, 0)]
                 : [mix(0.16, 0), mix(0.26, 255)];
}

// A preset is either a ramp along one axis or a set of points scattered over
// the frame. Nothing carries both.
function gradientIsMesh(g) {
    return !!(g && g.points && g.points.length);
}

// Points clamped into the frame, so a bad preset cannot push a fill off it.
function meshPoints(g) {
    var raw = (g && g.points) || [];
    var out = [];
    for (var i = 0; i < raw.length; i++) {
        var p = raw[i];
        if (!p || !p.color) continue;
        out.push({
            x: clamp(Number(p.x) || 0, -0.5, 1.5),
            y: clamp(Number(p.y) || 0, -0.5, 1.5),
            r: Math.max(0.02, Number(p.r) || 0.5),
            color: String(p.color)
        });
    }
    return out;
}

function clamp(v, lo, hi) {
    return v < lo ? lo : (v > hi ? hi : v);
}

function stamp() {
    var d = new Date();
    function p(n) { return (n < 10 ? "0" : "") + n; }
    return d.getFullYear() + "-" + p(d.getMonth() + 1) + "-" + p(d.getDate())
         + "_" + p(d.getHours()) + "-" + p(d.getMinutes()) + "-" + p(d.getSeconds());
}

var EXPORT_FORMATS = ["png", "jpg", "webp"];

// The extension a file in this format is saved with; anything unknown, as
// `set` could hand in, is saved as a PNG, which is what gets rendered.
function exportExtension(format) {
    return EXPORT_FORMATS.indexOf(format) !== -1 ? format : "png";
}

// The save dialog hands back whatever name was typed, and magick picks its
// encoder from the extension: a name with none fails outright, and one
// carrying the other format's extension would lie about the contents.
function withExtension(path, ext) {
    var p = String(path || "");
    var dot = p.lastIndexOf(".");
    var cur = dot > p.lastIndexOf("/") + 1 ? p.slice(dot + 1).toLowerCase() : "";
    if (cur === ext || (ext === "jpg" && cur === "jpeg")) return p;
    // Only an image extension is replaced; a dot anywhere else in the name is
    // part of the name.
    var image = ["png", "jpg", "jpeg", "webp"].indexOf(cur) !== -1;
    return (image ? p.slice(0, dot) : p) + "." + ext;
}

// --- Spotlight -------------------------------------------------------------
// The dim is one filled path rather than one per spotlight: drawn separately
// they would darken twice where they overlap.

function svgN(v) { return Math.round(v * 10) / 10; }

// A rectangle with per-corner radii, as an SVG subpath.
function rectSubpath(x, y, w, h, tl, tr, br, bl) {
    var lim = Math.min(w, h) / 2;
    function r(v) { return clamp(Number(v) || 0, 0, lim); }
    tl = r(tl); tr = r(tr); br = r(br); bl = r(bl);
    var d = "M" + svgN(x + tl) + "," + svgN(y) + "H" + svgN(x + w - tr);
    if (tr) d += "A" + svgN(tr) + "," + svgN(tr) + " 0 0 1 " + svgN(x + w) + "," + svgN(y + tr);
    d += "V" + svgN(y + h - br);
    if (br) d += "A" + svgN(br) + "," + svgN(br) + " 0 0 1 " + svgN(x + w - br) + "," + svgN(y + h);
    d += "H" + svgN(x + bl);
    if (bl) d += "A" + svgN(bl) + "," + svgN(bl) + " 0 0 1 " + svgN(x) + "," + svgN(y + h - bl);
    d += "V" + svgN(y + tl);
    if (tl) d += "A" + svgN(tl) + "," + svgN(tl) + " 0 0 1 " + svgN(x + tl) + "," + svgN(y);
    return d + "Z";
}

// Two half arcs, so the ellipse closes on itself.
function ellipseSubpath(x, y, w, h) {
    var rx = svgN(w / 2), ry = svgN(h / 2), cy = svgN(y + h / 2);
    return "M" + svgN(x) + "," + cy
         + "A" + rx + "," + ry + " 0 0 1 " + svgN(x + w) + "," + cy
         + "A" + rx + "," + ry + " 0 0 1 " + svgN(x) + "," + cy + "Z";
}

// Every spotlight annotation as a normalised rectangle, moved from screenshot
// pixels into the dimmed area's own coordinates (an inset sits between them).
function spotlightHoles(model, offset, shape) {
    var out = [];
    if (!model) return out;
    var dyn = typeof model.count === "number";
    var n = dyn ? model.count : model.length;
    for (var i = 0; i < n; i++) {
        var a = dyn ? model.get(i) : model[i];
        if (!a || a.kind !== "spotlight") continue;
        out.push({
            x: Math.min(a.x, a.x + a.w) + offset,
            y: Math.min(a.y, a.y + a.h) + offset,
            w: Math.abs(a.w),
            h: Math.abs(a.h),
            shape: shape
        });
    }
    return out;
}

// The picture's outline with a hole punched for every spotlight, filled
// odd-even. A hole is clamped to the picture, and where it reaches a corner it
// takes that corner's radius: a hole reaching past the outline would be filled
// in by the odd-even rule instead of punched out, which reads as a dark wedge
// sitting outside the card.
function spotlightPath(w, h, topRadius, bottomRadius, holes) {
    return spotlightPathIn([{ x: 0, y: 0, w: w, h: h, top: topRadius, bottom: bottomRadius }], holes);
}

// The same over several cards: each is dimmed, and a spotlight is cut out
// of the card it is on, clamped to it, so it never fills in a gap.
function spotlightPathIn(outlines, holes) {
    var d = "";
    outlines.forEach(function (o) {
        d += rectSubpath(o.x, o.y, o.w, o.h, o.top, o.top, o.bottom, o.bottom);
    });
    return d + spotlightHolesPath(outlines, holes);
}

var SPOT_SHAPES = ["rect", "rounded", "ellipse"];
var SPOT_ROUND = 0.2;              // a rounded hole's corners, of its shorter side

// Whole steps only: at 2, 3 and 4 every shot pixel becomes a square block of
// screen pixels, so text in a magnified spotlight stays crisp. 1 is off.
var SPOT_ZOOMS = [2, 3, 4];

function spotZoom(z) {
    return SPOT_ZOOMS.indexOf(Number(z)) !== -1 ? Number(z) : 1;
}

// What a magnifying spotlight shows: the area around its middle that fills
// the box at this zoom, a whole number of shot pixels each way so every one
// comes out the same size.
function spotLensArea(x, y, w, h, zoom) {
    var z = spotZoom(zoom);
    var sw = Math.max(1, Math.round(w / z)), sh = Math.max(1, Math.round(h / z));
    return { x: Math.round(x + w / 2 - sw / 2), y: Math.round(y + h / 2 - sh / 2), w: sw, h: sh };
}

// Each hole on the card nearest its centre, clamped to it, with a radius for
// every corner: what the dim punches out, what a ring is drawn along and the
// shape a magnifying spotlight is cut to, so all three agree.
function spotlightHoleBoxes(outlines, holes) {
    var out = [];
    for (var i = 0; holes && i < holes.length; i++) {
        var s = holes[i];
        var cx = s.x + s.w / 2, cy = s.y + s.h / 2, o = outlines[0], best = Infinity;
        outlines.forEach(function (c) {
            var dx = Math.max(c.x - cx, 0, cx - (c.x + c.w)), dy = Math.max(c.y - cy, 0, cy - (c.y + c.h));
            if (dx * dx + dy * dy < best) { best = dx * dx + dy * dy; o = c; }
        });
        var R = o.x + o.w, B = o.y + o.h;
        var x0 = clamp(Math.min(s.x, s.x + s.w), o.x, R), x1 = clamp(Math.max(s.x, s.x + s.w), o.x, R);
        var y0 = clamp(Math.min(s.y, s.y + s.h), o.y, B), y1 = clamp(Math.max(s.y, s.y + s.h), o.y, B);
        if (x1 - x0 < 1 || y1 - y0 < 1) continue;
        // In a card's corner a hole takes at least that corner's radius, or
        // its own corner would poke past the card's.
        var r = s.shape === "rounded" ? Math.min(x1 - x0, y1 - y0) * SPOT_ROUND : 0;
        var lim = Math.min(x1 - x0, y1 - y0) / 2;
        function corner(v) { return clamp(v, 0, lim); }
        out.push({
            x: x0, y: y0, w: x1 - x0, h: y1 - y0, shape: s.shape === "ellipse" ? "ellipse" : "rect",
            tl: corner(x0 <= o.x && y0 <= o.y ? Math.max(r, o.top) : r),
            tr: corner(x1 >= R && y0 <= o.y ? Math.max(r, o.top) : r),
            br: corner(x1 >= R && y1 >= B ? Math.max(r, o.bottom) : r),
            bl: corner(x0 <= o.x && y1 >= B ? Math.max(r, o.bottom) : r)
        });
    }
    return out;
}

function spotlightHolesPath(outlines, holes) {
    return spotlightHoleBoxes(outlines, holes).map(function (b) {
        return b.shape === "ellipse" ? ellipseSubpath(b.x, b.y, b.w, b.h)
             : rectSubpath(b.x, b.y, b.w, b.h, b.tl, b.tr, b.br, b.bl);
    }).join("");
}

// A ring's width in shot pixels: thin enough to frame, thick enough to see
// on a 4K shot once it is scaled down.
function spotRingWidth(shotW, shotH) {
    return Math.max(2, Math.round(Math.min(shotW, shotH) / 250));
}

// --- Several shots on one card ----------------------------------------------
// Each shot is a slot: the file it came from, its own crop in that file's
// pixels, and the file's size. The slots are laid out on one sheet, in shot
// pixels, with room between them for each card's inset and title bar and
// the gap, and the sheet is the picture every mark, hidden area and lens is
// drawn on. The stage draws a card per slot from its part of the sheet.

var SLOT_GAP = 4;                  // percent of the shots' lined-up edge
var SLOT_GAP_MAX = 15;

function newSlot(source, w, h) {
    var name = String(source).split("/").pop();
    return { id: newAnnotation("", 0, 0).uid, source: String(source), crop: null,
             w: w, h: h, name: name, edge: "" };
}

function slotSize(s) {
    return s.crop ? { w: s.crop.w, h: s.crop.h } : { w: s.w, h: s.h };
}

// The layout the card is drawn from: the shots sized first, so the inset and
// the title bar can be sized from them rather than from the sheet, then laid
// out with room for both. o carries the layout settings and the style's
// inset percentage and frame.
function sheetLayout(slots, o) {
    var sized = slotLayout(slots, { dir: o.dir, match: o.match, align: o.align });
    var bw = 1, bh = 1;
    sized.items.forEach(function (it) { bw = Math.max(bw, it.w); bh = Math.max(bh, it.h); });
    var L = slotLayout(slots, {
        dir: o.dir, gap: o.gap, match: o.match, align: o.align,
        inset: insetSize({ inset: o.inset, shotWidth: bw, shotHeight: bh }),
        chrome: chromeHeight({ frame: o.frame, shotHeight: bh })
    });
    L.baseW = bw;
    L.baseH = bh;
    return L;
}

// A single shot, uncropped, is its own file; anything else is composed.
function needsSheet(slots) {
    return slots.length > 1 || slots.some(function (s) { return !!s.crop; });
}

// o: { dir: "row" | "column", gap, match, align: "start" | "center" | "end",
//      inset, chrome }, the last two in shot pixels. Side by side, shots
// line up by height; stacked, by width. Matching scales the larger ones
// down to the smallest, never up; otherwise each keeps its size and is
// aligned across. Every size is whole pixels, so an unscaled shot is 1:1.
function slotLayout(slots, o) {
    var row = o.dir !== "column";
    var inset = o.inset || 0, chrome = o.chrome || 0;
    var sizes = slots.map(slotSize);
    var across = sizes.map(function (z) { return Math.max(1, row ? z.h : z.w); });
    var target = across.length === 0 ? 0
               : o.match ? Math.min.apply(null, across) : Math.max.apply(null, across);
    var gap = Math.round(clamp(o.gap || 0, 0, SLOT_GAP_MAX) / 100 * target);
    var items = [], pos = 0, W = 0, H = 0;
    for (var i = 0; i < slots.length; i++) {
        var k = o.match ? Math.min(1, target / across[i]) : 1;
        var w = Math.max(1, Math.round(sizes[i].w * k));
        var h = Math.max(1, Math.round(sizes[i].h * k));
        var cross = row ? h : w;
        var off = o.match ? 0
                : o.align === "center" ? Math.round((target - cross) / 2)
                : o.align === "end" ? target - cross : 0;
        var it = { id: slots[i].id, x: row ? pos : off, y: row ? off : pos, w: w, h: h, scale: k };
        items.push(it);
        W = Math.max(W, it.x + w);
        H = Math.max(H, it.y + h);
        pos += (row ? w : h) + inset * 2 + (row ? 0 : chrome) + gap;
    }
    return { items: items, w: W, h: H, dir: row ? "row" : "column", inset: inset, chrome: chrome };
}

// The slot a point on the sheet belongs to: the one it is on, or failing
// that the nearest, so a mark in a gap or an inset still has a home.
function slotIndexAt(layout, px, py) {
    var best = -1, bestD = Infinity;
    for (var i = 0; i < layout.items.length; i++) {
        var it = layout.items[i];
        var dx = Math.max(it.x - px, 0, px - (it.x + it.w));
        var dy = Math.max(it.y - py, 0, py - (it.y + it.h));
        var d = dx * dx + dy * dy;
        if (d < bestD) { bestD = d; best = i; }
    }
    return best;
}

function slotById(slots, id) {
    for (var i = 0; i < slots.length; i++) if (slots[i].id === id) return i;
    return -1;
}

// A point on one layout, through the file its shot came from, onto another.
function remapPoint(px, py, fromItem, fromSlot, toItem, toSlot) {
    var fc = fromSlot.crop || { x: 0, y: 0 }, tc = toSlot.crop || { x: 0, y: 0 };
    var ux = (px - fromItem.x) / fromItem.scale + fc.x;
    var uy = (py - fromItem.y) / fromItem.scale + fc.y;
    return { x: toItem.x + (ux - tc.x) * toItem.scale, y: toItem.y + (uy - tc.y) * toItem.scale };
}

// Marks follow their shots when the layout changes. Each end of a mark
// follows the shot it is on, so an arrow from one shot to another keeps
// pointing at the same two places. A mark whose shot is gone, or that a
// crop left with nothing to sit on, is dropped.
function remapAnnotations(marks, oldLayout, oldSlots, newLayout, newSlots) {
    var kept = [], dropped = 0;
    function place(px, py) {
        var i = slotIndexAt(oldLayout, px, py);
        if (i < 0) return null;
        var j = slotById(newSlots, oldLayout.items[i].id);
        if (j < 0) return null;
        var p = remapPoint(px, py, oldLayout.items[i], oldSlots[slotById(oldSlots, oldLayout.items[i].id)],
                           newLayout.items[j], newSlots[j]);
        p.from = oldLayout.items[i];
        p.to = newLayout.items[j];
        return p;
    }
    marks.forEach(function (a) {
        var b = JSON.parse(JSON.stringify(a));
        var p1 = place(a.x, a.y), p2 = place(a.x + a.w, a.y + a.h);
        if (!p1 || !p2) { dropped++; return; }
        b.x = p1.x; b.y = p1.y;
        b.w = p2.x - p1.x; b.h = p2.y - p1.y;
        if (a.kind === "text" && a.fontSize > 0)
            b.fontSize = Math.max(MIN_TEXT_SIZE, Math.round(a.fontSize * p1.to.scale / p1.from.scale));
        var it = p1.to;
        if (!overlapsRect(b, it.x, it.y, it.w, it.h)) { dropped++; return; }
        kept.push(b);
    });
    return { marks: kept, dropped: dropped };
}

// A selection drawn on the sheet as a crop of the shot it is on, in that
// shot's own file. Null when what is left of it on the shot is too small.
function cropForSlot(sel, item, slot) {
    var x0 = clamp(sel.x, item.x, item.x + item.w), x1 = clamp(sel.x + rectW(sel), item.x, item.x + item.w);
    var y0 = clamp(sel.y, item.y, item.y + item.h), y1 = clamp(sel.y + rectH(sel), item.y, item.y + item.h);
    var c = slot.crop || { x: 0, y: 0 };
    var r = { x: Math.round((x0 - item.x) / item.scale + c.x), y: Math.round((y0 - item.y) / item.scale + c.y),
              w: Math.round((x1 - x0) / item.scale), h: Math.round((y1 - y0) / item.scale) };
    return r.w >= MIN_CROP && r.h >= MIN_CROP ? r : null;
}

// What bin/postcard-sheet is given: the sheet's size, then per shot its
// file, the part of it to take, and where and how big that goes.
function sheetArgs(slots, layout) {
    var args = [String(layout.w), String(layout.h)];
    layout.items.forEach(function (it) {
        var s = slots[slotById(slots, it.id)];
        var c = s.crop || { x: 0, y: 0, w: s.w, h: s.h };
        args.push(s.source, String(c.x), String(c.y), String(c.w), String(c.h),
                  String(it.w), String(it.h), String(it.x), String(it.y));
    });
    return args;
}

// Names the composed sheet after what went into it, so Qt's image cache,
// keyed on the URL, never serves an older sheet for a new layout.
function sheetName(args) {
    var t = args.join("|"), h = 5381;
    for (var i = 0; i < t.length; i++) h = ((h * 33) ^ t.charCodeAt(i)) >>> 0;
    return "postcard-sheet-" + h.toString(16) + ".png";
}

// Each card's part of the spotlight's area, which starts at the first
// card's top left below its title bar: the dim covers the cards and never
// the gaps between them.
function spotlightOutlines(layout, radiusTop, radiusBottom) {
    return layout.items.map(function (it) {
        return { x: it.x, y: it.y, w: it.w + layout.inset * 2, h: it.h + layout.inset * 2,
                 top: radiusTop, bottom: radiusBottom };
    });
}

// --- Crop ------------------------------------------------------------------

var MIN_CROP = 16;                 // below this it is a stray click, not a crop

// A drag normalised into the picture: it may run any way and may start or
// end outside it.
function cropRect(x, y, w, h, shotW, shotH) {
    var x0 = clamp(Math.round(Math.min(x, x + w)), 0, shotW);
    var x1 = clamp(Math.round(Math.max(x, x + w)), 0, shotW);
    var y0 = clamp(Math.round(Math.min(y, y + h)), 0, shotH);
    var y1 = clamp(Math.round(Math.max(y, y + h)), 0, shotH);
    return { x: x0, y: y0, w: x1 - x0, h: y1 - y0 };
}

// QML's rect spells its size width/height; the plain objects here and in the
// path builder spell it w/h, and a rect crossing between the two reads as
// zero-sized if only one spelling is honoured.
function rectW(r) { return r.w !== undefined ? r.w : r.width; }
function rectH(r) { return r.h !== undefined ? r.h : r.height; }

function cropUsable(r) {
    return !!r && rectW(r) >= MIN_CROP && rectH(r) >= MIN_CROP;
}

// Every crop is taken from the file the editor opened rather than from the
// last crop of a crop, so the selection is offset by how far the picture has
// already moved. Re-encoding a re-encode would only lose quality.
function cropInSource(sel, offsetX, offsetY) {
    return { x: Math.round(sel.x + offsetX), y: Math.round(sel.y + offsetY),
             w: Math.round(rectW(sel)), h: Math.round(rectH(sel)) };
}

// --- Picking and resizing annotations ---------------------------------------

var MIN_ANNOTATION = 8;            // shot pixels, in either direction

function normalised(a) {
    return { x: Math.min(a.x, a.x + a.w), y: Math.min(a.y, a.y + a.h),
             w: Math.abs(a.w), h: Math.abs(a.h) };
}

// Whether a press at (px, py), in screenshot pixels, belongs to this
// annotation. A box, an ellipse and an arrow are mostly empty space, and
// taking the whole bounding box made whichever was drawn last swallow every
// press over the things inside it. `slop` is the reach in shot pixels.
function hitAnnotation(a, px, py, slop, shownW, shownH) {
    var r = normalised(a);
    // A text label is as big as its text, which only the delegate knows: its
    // own w and h are zero, and taking those meant only the very corner of a
    // label could be clicked.
    if (shownW !== undefined) r.w = shownW;
    if (shownH !== undefined) r.h = shownH;
    var stroke = Math.max(1, a.width || 1);
    var reach = slop + stroke / 2;

    // An arrow is drawn outside the box the drag made: the head's barbs stand
    // off the line, and a curve bows away from it altogether.
    var pad = reach;
    if (a.kind === "arrow") {
        pad += arrowHead(stroke)
             + arrowBulge(a);
    }

    if (px < r.x - pad || px > r.x + r.w + pad
        || py < r.y - pad || py > r.y + r.h + pad) return false;

    if (a.kind === "arrow") return nearArrow(a, px, py, reach);

    if (a.kind === "box") {
        // Anywhere but the hollow middle, unless it is filled in.
        if (a.fill) return true;
        return px <= r.x + reach || px >= r.x + r.w - reach
            || py <= r.y + reach || py >= r.y + r.h - reach;
    }

    if (a.kind === "ellipse") {
        var rx = Math.max(1, r.w / 2), ry = Math.max(1, r.h / 2);
        var dx = (px - (r.x + rx)) / rx, dy = (py - (r.y + ry)) / ry;
        var d = Math.sqrt(dx * dx + dy * dy);
        // The ring's thickness in these normalised units, off the shorter axis.
        var band = reach / Math.min(rx, ry);
        if (a.fill) return d <= 1 + band;
        return d >= 1 - band && d <= 1 + band;
    }

    return true;                   // the filled kinds are their whole box
}

// The shaft is a quadratic, so it is walked rather than solved; the head is
// taken as a disc at the tip.
function nearArrow(a, px, py, reach) {
    var g = arrowShape(a.w, a.h, a.style, arrowHead(a.width), a.bend);
    var ox = Math.min(a.x, a.x + a.w), oy = Math.min(a.y, a.y + a.h);
    var x = px - ox, y = py - oy;
    var head = arrowHead(a.width);

    if (Math.abs(x - g.tipX) <= head && Math.abs(y - g.tipY) <= head) return true;
    if (g.headStart && Math.abs(x - g.tailX) <= head && Math.abs(y - g.tailY) <= head) return true;

    var steps = 24, best = 1e9;
    for (var i = 0; i <= steps; i++) {
        var t = i / steps, u = 1 - t;
        var qx = u * u * g.sx + 2 * u * t * g.cx + t * t * g.ex;
        var qy = u * u * g.sy + 2 * u * t * g.cy + t * t * g.ey;
        var d = Math.sqrt((qx - x) * (qx - x) + (qy - y) * (qy - y));
        if (d < best) best = d;
    }
    return best <= reach;
}

var SIDE_KEYS = ["t", "r", "b", "l"];

// The points a selected annotation can be pulled by, in screenshot pixels.
// An arrow is held by its ends, everything else by the corners of its box,
// and by the middle of each side too unless it is a step badge, which has to
// stay round, or a text label, which keeps
// the shape of its text. A label is as big as its text, which only the
// delegate knows, so it passes the size it is shown at.
function resizeHandles(a, shownW, shownH) {
    if (!a) return [];
    if (a.kind === "text") {
        if (!(shownW > 0 && shownH > 0)) return [];
        var wraps = a.w > 0;
        a = { x: a.x, y: a.y, w: shownW, h: shownH };
        var tc = [{ key: "tl", x: a.x, y: a.y },
                  { key: "tr", x: a.x + a.w, y: a.y },
                  { key: "br", x: a.x + a.w, y: a.y + a.h },
                  { key: "bl", x: a.x, y: a.y + a.h }];
        // A label that wraps is as wide as it was dragged, and that width
        // is pulled from its right side.
        if (wraps) tc.push({ key: "r", x: a.x + a.w, y: a.y + a.h / 2 });
        return tc;
    }
    if (a.kind === "arrow") {
        var ends = [{ key: "tail", x: a.x, y: a.y }, { key: "tip", x: a.x + a.w, y: a.y + a.h }];
        if (a.style !== "curved") return ends;
        // Halfway along the curve, which is halfway to its control point.
        var b = arrowBend(a);
        return ends.concat([{ key: "bend", x: a.x + a.w / 2 + a.h * b / 2,
                                           y: a.y + a.h / 2 - a.w * b / 2 }]);
    }
    var r = normalised(a);
    var corners = [{ key: "tl", x: r.x, y: r.y },
                   { key: "tr", x: r.x + r.w, y: r.y },
                   { key: "br", x: r.x + r.w, y: r.y + r.h },
                   { key: "bl", x: r.x, y: r.y + r.h }];
    if (!hasSides(a.kind)) return corners;
    return corners.concat([{ key: "t", x: r.x + r.w / 2, y: r.y },
                           { key: "r", x: r.x + r.w, y: r.y + r.h / 2 },
                           { key: "b", x: r.x + r.w / 2, y: r.y + r.h },
                           { key: "l", x: r.x, y: r.y + r.h / 2 }]);
}

// The whole picture, background and padding and title bar included, in shot
// pixels: marks are placed against the shot, which sits inside it, so this
// starts above and to the left of 0,0. No mark is drawn, moved or resized
// past it.
function pictureArea(geo) {
    return { x: -(geo.cardX + geo.inset), y: -(geo.cardY + geo.chromeH + geo.inset),
             w: geo.frameW, h: geo.frameH };
}

// Where a point is held to the picture, for a pointer dragging an edge,
// a corner or the end of a line.
function clampToArea(px, py, area) {
    return { x: clamp(px, area.x, area.x + area.w), y: clamp(py, area.y, area.y + area.h) };
}

// The extent of a curved arrow's shaft, bulge included: a quadratic curve's
// box is its ends and, on each axis, the one turning point between them.
function arrowBounds(a, bend) {
    var x0 = a.x, y0 = a.y, x2 = a.x + a.w, y2 = a.y + a.h;
    var b = a.style === "curved" ? (bend === undefined ? arrowBend(a) : bend) : 0;
    var cx = a.x + a.w / 2 + a.h * b, cy = a.y + a.h / 2 - a.w * b;
    function span(p0, p1, p2) {
        var lo = Math.min(p0, p2), hi = Math.max(p0, p2);
        var den = p0 - 2 * p1 + p2;
        if (den !== 0) {
            var t = (p0 - p1) / den;
            if (t > 0 && t < 1) {
                var v = (1 - t) * (1 - t) * p0 + 2 * t * (1 - t) * p1 + t * t * p2;
                lo = Math.min(lo, v); hi = Math.max(hi, v);
            }
        }
        return [lo, hi];
    }
    var sx = span(x0, cx, x2), sy = span(y0, cy, y2);
    return { x: sx[0], y: sy[0], w: sx[1] - sx[0], h: sy[1] - sy[0] };
}

// The part of a mark that has to stay inside the picture. A label is as big
// as it is drawn, which only its delegate knows. Strokes and arrowheads are left out, so a thick one can reach a little past the edge.
function markBounds(a, shownW, shownH) {
    if (a.kind === "text")
        return { x: a.x, y: a.y, w: shownW > 0 ? shownW : 0, h: shownH > 0 ? shownH : 0 };
    if (a.kind === "arrow") return arrowBounds(a);
    return normalised(a);
}

// How far boxes can move together by dx, dy before the first of them meets
// an edge. One already past an edge may come back but not go further out,
// and one bigger than the picture across an axis holds nothing back on it.
function fitMove(boxes, dx, dy, area) {
    var lox = -Infinity, hix = Infinity, loy = -Infinity, hiy = Infinity;
    boxes.forEach(function (b) {
        if (b.w <= area.w) {
            lox = Math.max(lox, Math.min(0, area.x - b.x));
            hix = Math.min(hix, Math.max(0, area.x + area.w - b.x - b.w));
        }
        if (b.h <= area.h) {
            loy = Math.max(loy, Math.min(0, area.y - b.y));
            hiy = Math.min(hiy, Math.max(0, area.y + area.h - b.y - b.h));
        }
    });
    return { dx: lox > hix ? 0 : clamp(dx, lox, hix), dy: loy > hiy ? 0 : clamp(dy, loy, hiy) };
}

// The shift that brings a box back inside, the least that will; nothing for
// one that is bigger than the picture across that axis.
function keepInside(b, area) {
    function axis(lo, size, alo, asize) {
        if (size > asize) return 0;
        if (lo < alo) return alo - lo;
        if (lo + size > alo + asize) return alo + asize - lo - size;
        return 0;
    }
    return { dx: axis(b.x, b.w, area.x, area.w), dy: axis(b.y, b.h, area.y, area.h) };
}

// A curved arrow's bend, eased just enough for the whole curve to fit in
// the picture: its ends stay put and it never bends more than it was asked
// to. Each point of the curve moves in a straight line as the bend grows,
// so whatever fits at some bend fits at every smaller one.
function bendInside(a, area) {
    if (a.style !== "curved") return arrowBend(a);
    var want = arrowBend(a);
    function fits(b) {
        var r = arrowBounds(a, b);
        return r.x >= area.x - 0.01 && r.y >= area.y - 0.01
            && r.x + r.w <= area.x + area.w + 0.01 && r.y + r.h <= area.y + area.h + 0.01;
    }
    if (fits(want) || !fits(0)) return want;
    var lo = 0, hi = 1;
    for (var i = 0; i < 24; i++) {
        var mid = (lo + hi) / 2;
        if (fits(want * mid)) lo = mid; else hi = mid;
    }
    return Math.trunc(want * lo * 1000) / 1000;
}

// Whether a kind can be pulled by a side alone: not a line, nor anything
// that has to keep its shape.
function hasSides(kind) {
    return ["arrow", "text", "step"].indexOf(kind) === -1;
}

// The sides this mark is pulled by: all four, or only the right one of a
// wrapping label, whose width is the one thing a side can change on it.
function sideHandles(a) {
    if (!a) return [];
    if (hasSides(a.kind)) return SIDE_KEYS;
    return a.kind === "text" && a.w > 0 ? ["r"] : [];
}

function isSideHandle(key) {
    return SIDE_KEYS.indexOf(key) !== -1;
}

// Where an annotation lands when one of those points is dragged to (px, py).
// The edges opposite the handle stay put, a side moves its own edge only, and
// a step badge keeps its two sides equal so it stays round.
function resizeAnnotation(a, key, px, py, shownW, shownH) {
    if (a.kind === "text") return resizeText(a, key, px, py, shownW, shownH);
    if (a.kind === "arrow") {
        if (key === "tail")
            return { x: px, y: py, w: a.x + a.w - px, h: a.y + a.h - py };
        // Only the pull across the line counts: the curve stays symmetric.
        if (key === "bend") {
            var len2 = a.w * a.w + a.h * a.h;
            if (len2 < 1) return {};
            var across = (px - a.x - a.w / 2) * a.h - (py - a.y - a.h / 2) * a.w;
            return { bend: Math.round(clamp(2 * across / len2, -ARROW_BOW_MAX, ARROW_BOW_MAX) * 1000) / 1000 };
        }
        return { x: a.x, y: a.y, w: px - a.x, h: py - a.y };
    }

    var r = normalised(a);
    var ax = (key === "tl" || key === "bl" || key === "l") ? r.x + r.w : r.x;
    var ay = (key === "tl" || key === "tr" || key === "t") ? r.y + r.h : r.y;

    if (key === "t" || key === "b") {
        var sh = Math.max(MIN_ANNOTATION, Math.abs(py - ay));
        return { x: r.x, y: py < ay ? ay - sh : ay, w: r.w, h: sh };
    }
    if (key === "l" || key === "r") {
        var sw = Math.max(MIN_ANNOTATION, Math.abs(px - ax));
        return { x: px < ax ? ax - sw : ax, y: r.y, w: sw, h: r.h };
    }

    var w = Math.max(MIN_ANNOTATION, Math.abs(px - ax));
    var h = Math.max(MIN_ANNOTATION, Math.abs(py - ay));
    if (a.kind === "step") { w = Math.max(w, h); h = w; }

    return { x: px < ax ? ax - w : ax, y: py < ay ? ay - h : ay, w: w, h: h };
}

// A label scales with its text rather than stretching. The pull is measured
// along the diagonal of what is shown, so a corner dragged sideways or
// straight down still grows or shrinks it.
function resizeText(a, key, px, py, shownW, shownH) {
    var size = textSize(a);
    // The right side of a wrapping label sets how wide it wraps.
    if (key === "r") return { w: Math.max(MIN_TEXT_WRAP, Math.round(px - a.x)) };
    if (!(shownW > 0 && shownH > 0)) return { fontSize: size };
    var ax = (key === "tl" || key === "bl") ? a.x + shownW : a.x;
    var ay = (key === "tl" || key === "tr") ? a.y + shownH : a.y;
    var dx = Math.abs(px - ax), dy = Math.abs(py - ay);
    var k = (dx * shownW + dy * shownH) / (shownW * shownW + shownH * shownH);
    var next = Math.max(MIN_TEXT_SIZE, Math.round(size * k));
    var w = shownW * next / size, h = shownH * next / size;
    var out = { fontSize: next, x: px < ax ? ax - w : ax, y: py < ay ? ay - h : ay };
    // A wrapping label scales its width with its text, so the lines break
    // where they did.
    if (a.w > 0) out.w = Math.max(MIN_TEXT_WRAP, Math.round(a.w * next / size));
    return out;
}

// Whether any of an annotation still shows inside a crop, so that what is cut
// away takes the marks that were only on it.
function overlapsRect(a, x, y, w, h) {
    var r = normalised(a);
    // A text label is a point with its text hanging off it, and a zero-sized
    // mark is still somewhere.
    var rw = Math.max(r.w, 1), rh = Math.max(r.h, 1);
    return r.x < x + w && r.x + rw > x && r.y < y + h && r.y + rh > y;
}

// Whether a selection box drawn over the picture takes this mark: any
// overlap will do.
function inSelectionBox(a, x, y, w, h) {
    var r = normalised(a);
    var rw = Math.max(r.w, 1), rh = Math.max(r.h, 1);
    return r.x < x + w && r.x + rw > x && r.y < y + h && r.y + rh > y;
}

var CAPTURE_MODES = ["region", "windows", "fullscreen", "smart", "last"];

// The editor's keys, as [keys, what they do, whether a button does it too].
// The README's Keys table is checked against them, so the two cannot drift
// apart; the About panel lists only the ones no button shows, without the
// README's backticks.
var KEYS = [
    ["`V`, `A`, `R`, `O`, `T`, `S`, `H`, `B`, `L`, `C`", "move, arrow, box, ellipse, text, step, highlight, hide, spotlight, crop", true],
    ["`Ctrl+C` / `Ctrl+S`", "copy / save", true],
    ["`Ctrl+C`, `Ctrl+X`, `Ctrl+V`, `Ctrl+D`", "With annotations selected: copy, cut, paste, duplicate them", false],
    ["`Ctrl+Shift+S`", "Save as, through the system file dialog", true],
    ["`Ctrl+Z`", "undo", true],
    ["`Ctrl+Shift+Z` / `Ctrl+Y`", "redo", true],
    ["`Ctrl+N`", "Grab another region", true],
    ["`Ctrl+Shift+N`", "Capture the last region again", true],
    ["`Ctrl+K`", "Code card from the selected text", true],
    ["`Delete`", "Remove the selected annotations", false],
    ["`Shift`+click, or drag a box with the move tool", "Select several annotations; `Ctrl+A` selects them all", false],
    ["Arrow keys, `Shift`+arrows", "Move the selected annotations 1px, or 10px", false],
    ["`Shift` while drawing", "A square box, ellipse or spotlight; an arrow held to 45°; a corner handle keeps the shape", false],
    ["`Alt` while drawing", "Draw from the middle out", false],
    ["Drag with the text tool", "A label that wraps at that width", false],
    ["`Enter`, `Shift+Enter`", "Finish typing a text label, or start a new line in it", false],
    ["`Esc`", "Deselect, then close", false]
];

var ANNOTATION_KINDS = ["arrow", "box", "ellipse", "text", "step", "highlight",
                        "redact", "spotlight"];

// What `call set` accepts, and the hint `call help set` prints for each.
// The overlay takes its list of settable keys from here, so the two cannot
// drift apart.
var SETTABLE = {
    bgMode: "auto | solid | gradient | theme | desktop | none",
    bgSolid: "a color, \"#1e222a\"",
    bgGradient: "a preset (" + GRADIENTS.map(function (g) { return g.key; }).join(", ") + ") or custom",
    bgCustomStops: "the custom gradient's colors, [\"#112233\",\"#445566\"] (in an object, not bare)",
    bgCustomAngle: "0 to 359",
    padding: "0 to 30, percent of the card's longest edge",
    inset: "0 to 20, percent, inside the card",
    balance: "true | false, lift the card a little off centre",
    ratio: RATIOS.map(function (r) { return r.key; }).join(" | "),
    radius: "0 to 25, percent of the card's shorter edge",
    shadow: "0 to 100",
    frame: "none | titlebar",
    frameTitle: "the title bar's text",
    exportScale: "1 | 2 | 3",
    format: EXPORT_FORMATS.join(" | "),
    quality: "40 to 100, for jpg and webp; 100 is lossless webp",
    tool: "select | " + ANNOTATION_KINDS.join(" | ") + " | crop",
    inkColor: "a color, for the next mark",
    inkWidth: "1 to 16, the next mark's stroke",
    arrowStyle: ARROW_STYLES.map(function (a) { return a.key; }).join(" | "),
    textFont: TEXT_FONTS.map(function (f) { return f.key; }).join(" | "),
    textStyle: TEXT_STYLES.map(function (f) { return f.key; }).join(" | ") + ", what the next label sits on",
    redactStyle: REDACT_STYLES.map(function (f) { return f.key; }).join(" | ") + ", how the next hidden area is drawn",
    shapeFill: "true | false, whether the next box or ellipse is filled in",
    shapeCorner: "0 to " + MAX_CORNER + ", the next box's corner radius in pixels",
    highlightSnap: "true | false, whether a highlight snaps to the line of text under it",
    spotShape: SPOT_SHAPES.join(" | "),
    spotRing: "true | false, a white ring around every spotlight",
    spotZoom: "1 (off), " + SPOT_ZOOMS.join(", ") + ": every spotlight magnifies what is under it",
    spotDim: "0 to 90, how dark a spotlight leaves the rest",
    codeLang: "auto, or a language bat knows",
    codeTheme: "omarchy, or an Omarchy or bat theme name",
    codeFont: "10 to 32",
    codeNumbers: "true | false",
    watermarkText: "a handle under the card, \"@you\"",
    watermarkLogo: "a path to an image, shown before the handle",
    watermarkSize: "50 to 200, percent",
    layoutDir: "row | column: several shots side by side, or stacked",
    slotGap: "0 to " + SLOT_GAP_MAX + ", percent: the gap between shots",
    matchSizes: "true | false: scale larger shots down to line up, or keep their sizes",
    slotAlign: "start | center | end: where shots of different sizes line up",
    saveCopies: "true | false, whether saving also copies (a setting, not a style)",
    captureCopies: "true | false, whether a new capture is copied as it is taken (a setting)"
};

// `call help [topic]`. The CLI splits a bare argument on spaces, so a
// topic is one word.
function helpText(topic) {
    var t = String(topic || "").trim().toLowerCase();
    var call = "omarchy-shell shell call tahayvr.postcard";
    if (t === "set") {
        var lines = ["set '<json>': change any of these at once, e.g.",
                     "  " + call + " set '{\"padding\":8,\"frame\":\"titlebar\"}'", ""];
        Object.keys(SETTABLE).forEach(function (k) { lines.push("  " + k + ": " + SETTABLE[k]); });
        lines.push("", "Strings cannot hold a literal space on the command line: write \\u0020.");
        return lines.join("\n");
    }
    if (t === "annotate") {
        return [
            "annotate '<json>': add marks, in the picture's own pixels, top left 0,0.",
            "  One mark:     " + call + " annotate '{\"kind\":\"box\",\"x\":40,\"y\":40,\"w\":300,\"h\":120}'",
            "  Several:      " + call + " annotate '{\"items\":[{...},{...}]}'",
            "                (a bare [...] is split on commas by the command line)",
            "",
            "  kind      " + ANNOTATION_KINDS.join(", "),
            "  x y w h   position and size; an arrow runs from x,y by w,h",
            "  color     \"#rrggbb\", else the current ink",
            "  width     stroke, 1 to 16",
            "  style     arrows: " + ARROW_STYLES.map(function (a) { return a.key; }).join(", ")
                + "; redact: " + REDACT_STYLES.map(function (a) { return a.key; }).join(", "),
            "  bend      a curved arrow's bow, -" + ARROW_BOW_MAX + " to " + ARROW_BOW_MAX + " of its length, negative the other way (" + ARROW_BOW + ")",
            "  fill      box, ellipse: true to fill it in",
            "  corner    box: corner radius in pixels, 0 for square",
            "  text      a text label's words (\\u0020 for a space, \\n for a new line)",
            "  w         a text label's wrap width; 0 (or none) for a single line",
            "  size      a text label's size in pixels",
            "  font      a text label's font: " + TEXT_FONTS.map(function (f) { return f.key; }).join(", "),
            "  textStyle a text label's backing: " + TEXT_STYLES.map(function (f) { return f.key; }).join(", "),
            "  index     a step's number, else the next one",
            "  strength  a hidden area's block size"
        ].join("\n");
    }
    if (t === "capture") {
        return [
            "capture <mode>: take a screenshot and open it in the editor.",
            "  " + call + " capture region        (" + CAPTURE_MODES.join(" | ") + ")",
            "  " + call + " capture '{\"mode\":\"fullscreen\",\"delay\":5}'   (0 to " + MAX_DELAY + " seconds)",
            "",
            "last takes the region picked last time again, with no picker. If",
            "there is none, or the monitors have changed since, the picker runs.",
            "",
            "It answers ok at once and captures in the background. Wait for",
            "\"capturing\":false in `info` before the next call; a cancelled",
            "picker leaves hasContent false. `shell hide tahayvr.postcard` cancels.",
            "With captureCopies set, the plain shot also goes onto the clipboard."
        ].join("\n");
    }
    return [
        "Postcard: " + call + " <function> <argument>",
        "Every call takes one argument; a function that needs none takes ''.",
        "It answers ok or a short reason (busy, no shot, bad json, ...).",
        "",
        "Getting a picture in",
        "  capture <mode>        screenshot, then the editor (help capture)",
        "  edit <path>           open an image file",
        "  add <mode|path>       another shot beside it: a capture mode, a path, or file",
        "  code ''               code card from the selection, or pass the text",
        "  pick ''               choose a file in the system dialog",
        "",
        "Styling",
        "  set '<json>'          change settings (help set)",
        "  preset <name>         put a saved preset on; a dash for each space; default",
        "",
        "Marking up",
        "  annotate '<json>'     add marks (help annotate)",
        "  crop '<json>'         crop the shot under {x,y,w,h}, or '' for the selection",
        "  uncrop ''             back to the whole picture",
        "  redact ''             find secrets and hide them",
        "",
        "Recent cards",
        "  recent ''             the last five cards as JSON, newest first",
        "  recent <id|1-5>       reopen one, marks and all",
        "",
        "Getting it out",
        "  save ''               write to the screenshot folder, and copy unless Settings says not",
        "  saveAs ''             choose where, in the system dialog",
        "  copy ''               to the clipboard",
        "  copyText ''           the text in the shot, read by OCR, to the clipboard",
        "",
        "  info ''               the document as JSON: busy, delivering, lastSaved, sizes, style",
        "  help [set|annotate|capture]",
        "",
        "Captures and exports run in the background and answer ok at once. A",
        "script waits for info to show capturing, busy and delivering all false;",
        "lastSaved then names the file a save wrote."
    ].join("\n");
}
var MAX_DELAY = 60;

// What `capture` was asked for. The CLI hands over one string, so a delay
// arrives inside it as {"mode","delay"} JSON; a summon passes it apart.
// An unknown mode falls back to region, as the bar always has; a delay that
// is not a whole number of seconds is refused rather than rounded.
function captureRequest(mode, delay) {
    if (typeof mode === "string" && mode.trim().indexOf("{") === 0) {
        var options;
        try { options = JSON.parse(mode); } catch (e) { return { error: "bad json" }; }
        mode = options.mode;
        delay = options.delay;
    }
    var seconds = delay === undefined ? 0 : delay;
    if (typeof seconds !== "number" || !isFinite(seconds)
            || seconds < 0 || seconds > MAX_DELAY || Math.floor(seconds) !== seconds)
        return { error: "bad delay" };
    var m = String(mode || "region");
    if (CAPTURE_MODES.indexOf(m) === -1) m = "region";
    return { mode: m, seconds: seconds };
}

// "#abc", "abc", "#aabbcc" or "AABBCC" as "#aabbcc"; anything else as "".
function normaliseHex(text) {
    var t = String(text || "").trim().replace(/^#/, "").toLowerCase();
    if (/^[0-9a-f]{3}$/.test(t)) t = t[0] + t[0] + t[1] + t[1] + t[2] + t[2];
    return /^[0-9a-f]{6}$/.test(t) ? "#" + t : "";
}

// Hue in degrees, saturation and value 0 to 1.
function hsvToHex(h, s, v) {
    h = ((h % 360) + 360) % 360;
    s = clamp(s, 0, 1);
    v = clamp(v, 0, 1);
    var c = v * s, x = c * (1 - Math.abs((h / 60) % 2 - 1)), m = v - c;
    var r = 0, g = 0, b = 0;
    if (h < 60) { r = c; g = x; }
    else if (h < 120) { r = x; g = c; }
    else if (h < 180) { g = c; b = x; }
    else if (h < 240) { g = x; b = c; }
    else if (h < 300) { r = x; b = c; }
    else { r = c; b = x; }
    return toHex(Math.round((r + m) * 255), Math.round((g + m) * 255), Math.round((b + m) * 255));
}

// A gray has no hue of its own, so it reports the hue it was given; a picker
// set to gray then keeps its place on the hue bar.
function hexToHsv(hex, fallbackHue) {
    var c = parseHex(hex);
    if (!c) return { h: fallbackHue || 0, s: 0, v: 0 };
    var r = c.r / 255, g = c.g / 255, b = c.b / 255;
    var max = Math.max(r, g, b), min = Math.min(r, g, b), d = max - min;
    var h = fallbackHue || 0;
    if (d > 0) {
        if (max === r) h = 60 * (((g - b) / d) % 6);
        else if (max === g) h = 60 * ((b - r) / d + 2);
        else h = 60 * ((r - g) / d + 4);
        if (h < 0) h += 360;
    }
    return { h: h, s: max === 0 ? 0 : d / max, v: max };
}

var CUSTOM_COLORS_KEPT = 8;
// Fewer inks than background colors: they share the header with the tool's
// other options.
var INK_COLORS_KEPT = 6;

// The recent custom colors, newest first. Within one visit to the picker
// every choice replaces the one before it, so dragging about leaves one
// color behind rather than a trail; a fresh visit pushes a new one.
function rememberColor(list, hex, replaceFirst, kept) {
    var c = normaliseHex(hex);
    var out = Array.isArray(list) ? list.slice() : [];
    if (!c) return out;
    if (replaceFirst && out.length) out.shift();
    out = out.filter(function (x) { return normaliseHex(x) !== c; });
    out.unshift(c);
    return out.slice(0, kept || CUSTOM_COLORS_KEPT);
}

function forgetColor(list, hex) {
    var c = normaliseHex(hex);
    return (Array.isArray(list) ? list : []).filter(function (x) { return normaliseHex(x) !== c; });
}

var USER_GRADIENTS_KEPT = 12;

// A saved gradient as it may come back off disk: its stops cleaned up and
// bounded, its angle whole and in range. Null when there is not enough of a
// gradient left to draw.
function cleanGradient(g) {
    if (!g || typeof g !== "object" || !Array.isArray(g.stops)) return null;
    var stops = g.stops.map(normaliseHex).filter(function (c) { return c !== ""; });
    if (stops.length < CUSTOM_MIN_STOPS) return null;
    var angle = typeof g.angle === "number" && isFinite(g.angle) ? g.angle : CUSTOM_ANGLE;
    return {
        id: g.id ? String(g.id) : newGradientId(),
        stops: stops.slice(0, CUSTOM_MAX_STOPS),
        angle: Math.round(clamp(angle, 0, 359))
    };
}

function newGradientId() {
    return Date.now().toString(36) + Math.floor(Math.random() * 1296).toString(36);
}

// Edits land on the saved gradient where it already sits, so the row does
// not reshuffle under the pointer; a new one goes in front.
function saveGradient(list, g) {
    var clean = cleanGradient(g);
    var out = Array.isArray(list) ? list.slice() : [];
    if (!clean) return out;
    for (var i = 0; i < out.length; i++) {
        if (out[i].id === clean.id) { out[i] = clean; return out; }
    }
    out.unshift(clean);
    return out.slice(0, USER_GRADIENTS_KEPT);
}

function forgetGradient(list, id) {
    return (Array.isArray(list) ? list : []).filter(function (g) { return g.id !== id; });
}

// Where a new gradient of the user's starts: the one on show if it is a
// linear one, since that is usually what is about to be adjusted.
function gradientSeed(key, customStops, customAngle) {
    var g = gradientFor(key, customStops, customAngle);
    if (gradientIsMesh(g)) return { stops: CUSTOM_STOPS.slice(), angle: CUSTOM_ANGLE };
    return { stops: g.stops.slice(0, CUSTOM_MAX_STOPS), angle: g.angle !== undefined ? g.angle : CUSTOM_ANGLE };
}

// Everything a preset carries: the look of the card and how it is exported,
// never the marks on it or what the annotation tools are set to. Doc.reset()
// starts from these, and so does the built-in Default preset.
var DEFAULT_STYLE = {
    padding: 5, inset: 0, balance: false, ratio: "auto",
    radius: 3, shadow: 45, frame: "none",
    bgMode: "auto", bgSolid: "#1e222a", bgGradient: "dusk",
    bgCustomStops: CUSTOM_STOPS, bgCustomAngle: CUSTOM_ANGLE,
    exportScale: 1, format: "png", quality: 92,
    codeTheme: "omarchy", codeFont: 16, codeNumbers: false,
    watermarkText: "", watermarkLogo: "", watermarkSize: 100
};
var STYLE_KEYS = Object.keys(DEFAULT_STYLE);
var DEFAULT_PRESET = "default";

// The style of anything that has these properties, the document included,
// as plain values: a QML color comes out as its hex, an array as a copy.
function styleOf(src) {
    var out = {};
    for (var i = 0; i < STYLE_KEYS.length; i++) {
        var k = STYLE_KEYS[i], v = src[k];
        if (k === "bgSolid") v = normaliseHex(String(v)) || DEFAULT_STYLE.bgSolid;
        else if (Array.isArray(DEFAULT_STYLE[k])) v = Array.prototype.slice.call(v || []);
        out[k] = v;
    }
    return out;
}

function sameStyle(a, b) {
    return JSON.stringify(styleOf(a)) === JSON.stringify(styleOf(b));
}

// A style read back off disk: every key of the default, each taken from what
// was saved only when it is the right kind of value. A preset saved before a
// setting existed gets that setting's default.
function cleanStyle(o) {
    var out = styleOf(DEFAULT_STYLE);
    if (!o || typeof o !== "object") return out;
    for (var i = 0; i < STYLE_KEYS.length; i++) {
        var k = STYLE_KEYS[i], d = DEFAULT_STYLE[k], v = o[k];
        if (v === undefined || v === null) continue;
        if (k === "bgSolid") {
            var c = normaliseHex(v);
            if (c) out[k] = c;
        } else if (Array.isArray(d)) {
            var g = cleanGradient({ stops: v });
            if (g) out[k] = g.stops;
        } else if (typeof d === "number") {
            if (typeof v === "number" && isFinite(v)) out[k] = v;
        } else if (typeof v === typeof d) {
            out[k] = v;
        }
    }
    return out;
}

// How Postcard behaves rather than how the card looks, so never part of a
// preset. A new preference is a key here, and a property of the same name
// on the document.
var DEFAULT_SETTINGS = {
    saveCopies: true,          // saving also puts the picture on the clipboard
    captureCopies: false       // a new capture goes onto the clipboard as it is taken
};

// Every file under ~/.config/postcard carries the version of its layout.
// Changing what a key means, or renaming or splitting one, bumps that file's
// version and appends the step from the version before to its migrations;
// a plain new key needs neither, since each file is cleaned on the way in
// and a missing key gets its default. A file without a version is 0, the
// layout it had before versions existed. migrations[n] takes a file at
// version n to n + 1, and only has to know those two.
var CONFIG_FILES = {
    settings: { version: 1, migrations: [
        function (o) { return o; }       // 0 → 1: the version field itself
    ] },
    colors: { version: 1, migrations: [
        function (o) { return o; }       // 0 → 1: the version field itself
    ] },
    presets: { version: 1, migrations: [
        function (o) { return o; }       // 0 → 1: the version field itself
    ] },
    // One per recent card, under ~/.local/state/postcard/recent/<id>/doc.json.
    recent: { version: 1, migrations: [
        function (o) { return o; }       // 0 → 1: the version field itself
    ] }
};

function configVersion(o) {
    var v = o && typeof o === "object" ? o.version : undefined;
    return typeof v === "number" && isFinite(v) && v >= 0 ? Math.floor(v) : 0;
}

// A file as read off disk, brought up to this build's version of it. One
// from a newer Postcard is passed through as it is, and marked so it is
// never written over: going back a version must not lose what the newer one
// saved.
function migrateConfig(kind, o) {
    var spec = CONFIG_FILES[kind];
    var from = configVersion(o);
    var cur = o && typeof o === "object" ? JSON.parse(JSON.stringify(o)) : {};
    for (var v = from; v < spec.version; v++) cur = spec.migrations[v](cur) || {};
    return { data: cur, from: from, tooNew: from > spec.version };
}

// What is written: the version first, then the rest.
function configFile(kind, values) {
    var out = { version: CONFIG_FILES[kind].version };
    for (var k in values) if (k !== "version") out[k] = values[k];
    return out;
}


// Settings read back off disk: each taken only when it is the kind of value
// its default is, so a damaged file falls back rather than breaking a save.
function cleanSettings(o) {
    var out = {};
    for (var k in DEFAULT_SETTINGS) {
        var d = DEFAULT_SETTINGS[k];
        out[k] = (o && typeof o === "object" && typeof o[k] === typeof d) ? o[k] : d;
    }
    return out;
}

var PRESET_NAME_MAX = 40;

function cleanPresetName(name) {
    return String(name || "").replace(/\s+/g, " ").trim().slice(0, PRESET_NAME_MAX);
}

function cleanPreset(p) {
    if (!p || typeof p !== "object") return null;
    var name = cleanPresetName(p.name);
    if (!name) return null;
    var id = p.id ? String(p.id) : newGradientId();
    if (id === DEFAULT_PRESET) return null;
    return { id: id, name: name, style: cleanStyle(p.style) };
}

// Kept in the order they were made; an edit stays where it is.
function savePreset(list, p) {
    var clean = cleanPreset(p);
    var out = Array.isArray(list) ? list.slice() : [];
    if (!clean) return out;
    for (var i = 0; i < out.length; i++) {
        if (out[i].id === clean.id) { out[i] = clean; return out; }
    }
    out.push(clean);
    return out;
}

function forgetPreset(list, id) {
    return (Array.isArray(list) ? list : []).filter(function (p) { return p.id !== id; });
}

// A name as `call preset` has to type it: the shell's command line splits on
// spaces, so a dash or an underscore stands for one, and \u0020 is read as
// one too, as it is in the JSON that set and annotate take. Case is ignored.
function presetKey(name) {
    var s = String(name || "").replace(/\\u([0-9a-fA-F]{4})/g, function (m, hex) {
        return String.fromCharCode(parseInt(hex, 16));
    });
    return cleanPresetName(s.replace(/[_-]+/g, " ")).toLowerCase();
}

// By id, or by name as presetKey reads it; "default" is the built-in one.
function findPreset(list, key) {
    var k = presetKey(key);
    if (!k) return null;
    if (k === DEFAULT_PRESET) return { id: DEFAULT_PRESET, name: "Default", style: styleOf(DEFAULT_STYLE) };
    var all = Array.isArray(list) ? list : [];
    for (var i = 0; i < all.length; i++)
        if (all[i].id === key || presetKey(all[i].name) === k) return all[i];
    return null;
}

// --- Recent cards ------------------------------------------------------------
// The last few cards, kept with their marks so any of them can be reopened
// as it was: the shots (copied into the state directory, since a capture's
// scratch file goes with the next capture), the layout, the style and the
// marks. A snapshot, not a history: undo starts again on reopening.

var RECENT_KEPT = 5;

// What is written to doc.json. `slots` already point at the copies in the
// entry's directory; the overlay rewrites them before calling this.
function recentDocument(doc, id, slots) {
    var marks = typeof doc.snapshot === "function" ? JSON.parse(doc.snapshot()) : [];
    return {
        id: String(id),
        stamp: Date.now(),
        kind: doc.kind === "code" ? "code" : "shot",
        title: doc.kind === "code" ? String(doc.frameTitle || "")
             : (slots.length ? String(slots[0].name) + (slots.length > 1 ? " +" + (slots.length - 1) : "") : ""),
        shotName: String(doc.shotName || ""),
        frameTitle: String(doc.frameTitle || ""),
        codeText: doc.kind === "code" ? String(doc.codeText || "") : "",
        codeLang: String(doc.codeLang || "auto"),
        slots: slots,
        layout: { dir: String(doc.layoutDir || "row"), gap: Number(doc.slotGap) || 0,
                  match: !!doc.matchSizes, align: String(doc.slotAlign || "center") },
        palette: { auto: Array.prototype.slice.call(doc.autoPalette || []),
                   shot: Array.prototype.slice.call(doc.shotPalette || []),
                   edge: String(doc.shotEdge || "") },
        style: styleOf(doc),
        activePreset: String(doc.activePreset || DEFAULT_PRESET),
        textSize: Number(doc.textSize) || 0,
        marks: marks
    };
}

// A doc.json read back off disk, with anything that is not what it should
// be dropped. Null when there is no card in it.
function cleanRecent(o) {
    if (!o || typeof o !== "object" || !o.id) return null;
    var kind = o.kind === "code" ? "code" : "shot";
    var slots = Array.isArray(o.slots) ? o.slots.filter(function (s) {
        return s && typeof s === "object" && typeof s.source === "string" && s.source.length
            && s.w > 0 && s.h > 0;
    }).map(function (s) {
        var out = newSlot(s.source, Math.round(s.w), Math.round(s.h));
        if (s.id) out.id = String(s.id);
        if (s.name) out.name = String(s.name);
        if (/^#[0-9a-fA-F]{6}$/.test(String(s.edge || ""))) out.edge = String(s.edge);
        if (s.crop && typeof s.crop === "object" && s.crop.w >= MIN_CROP && s.crop.h >= MIN_CROP)
            out.crop = { x: Math.round(s.crop.x) || 0, y: Math.round(s.crop.y) || 0,
                         w: Math.round(s.crop.w), h: Math.round(s.crop.h) };
        return out;
    }) : [];
    if (kind === "shot" && slots.length === 0) return null;
    if (kind === "code" && !(typeof o.codeText === "string" && o.codeText.length)) return null;
    var hex = function (c) { return /^#[0-9a-fA-F]{6}$/.test(String(c || "")) ? String(c) : null; };
    var layout = o.layout && typeof o.layout === "object" ? o.layout : {};
    var palette = o.palette && typeof o.palette === "object" ? o.palette : {};
    return {
        id: String(o.id),
        stamp: typeof o.stamp === "number" && isFinite(o.stamp) ? o.stamp : 0,
        kind: kind,
        title: typeof o.title === "string" ? o.title : "",
        shotName: typeof o.shotName === "string" ? o.shotName : "",
        frameTitle: typeof o.frameTitle === "string" ? o.frameTitle : "",
        codeText: kind === "code" ? String(o.codeText) : "",
        codeLang: typeof o.codeLang === "string" && o.codeLang ? o.codeLang : "auto",
        slots: slots,
        layout: { dir: layout.dir === "column" ? "column" : "row",
                  gap: typeof layout.gap === "number" ? clamp(layout.gap, 0, SLOT_GAP_MAX) : SLOT_GAP,
                  match: layout.match !== false,
                  align: ["start", "center", "end"].indexOf(layout.align) !== -1 ? layout.align : "center" },
        palette: { auto: (Array.isArray(palette.auto) ? palette.auto : []).map(hex).filter(Boolean),
                   shot: (Array.isArray(palette.shot) ? palette.shot : []).map(hex).filter(Boolean),
                   edge: hex(palette.edge) || "" },
        style: cleanStyle(o.style),
        activePreset: typeof o.activePreset === "string" && o.activePreset ? o.activePreset : DEFAULT_PRESET,
        textSize: typeof o.textSize === "number" && o.textSize > 0 ? Math.round(o.textSize) : 0,
        marks: (Array.isArray(o.marks) ? o.marks : []).filter(function (a) {
            return a && typeof a === "object" && a.kind && ANNOTATION_KINDS.indexOf(a.kind) !== -1;
        }).map(function (a) {
            // Every role the delegates read, from the row, then the defaults
            // for anything a row from an older build lacks.
            var row = newAnnotation(String(a.kind), Number(a.x) || 0, Number(a.y) || 0);
            for (var k in row) if (a[k] !== undefined && a[k] !== null && k !== "kind") row[k] = a[k];
            if (!a.uid) row.uid = newAnnotation("", 0, 0).uid;
            return row;
        })
    };
}

// Where each slot's source is copied to inside the entry: numbered, so two
// shots with the same name do not land on each other.
function recentSourceName(index, source) {
    return index + "-" + String(source).split("/").pop();
}

// A recent card by id, or by its place in the list (1 is the newest).
function findRecent(list, key) {
    var k = String(key || "").trim();
    if (!k) return null;
    var all = Array.isArray(list) ? list : [];
    if (/^[1-9]$/.test(k)) return all[parseInt(k, 10) - 1] || null;
    for (var i = 0; i < all.length; i++) if (all[i].id === k) return all[i];
    return null;
}
