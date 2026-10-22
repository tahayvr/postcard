#version 440
// A magnifying spotlight: the area it shows, stretched over the lens, and
// cut to the hole (a box with a radius per corner, or an ellipse) and to the
// card's rounded corners, with an antialiased edge a pixel wide. The lens is
// exactly zoom times the area, so it can reach a little past the hole.
// Drawn here rather than as a Shape filled with the texture, whose fill
// mapped the texture at a scale that followed how the layer was transformed
// and put the zoomed pixels in the wrong place, and rather than through a
// layer mask, which resamples. The texture comes from a ShaderEffectSource
// with smooth off, so each shot pixel stays a square block.
//
// Build: qsb --glsl "100 es,120,150" --hlsl 50 --msl 12 -o lens.frag.qsb lens.frag

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 size;          // the lens in pixels
    vec4 hole;          // the hole, x y w h in the lens's pixels
    vec4 radii;         // the hole's corners: top left, top right, bottom right, bottom left
    float ellipse;      // 1 for an elliptical hole, when its radii are ignored
    vec4 card;          // the card the hole is on, x y w h in the lens's pixels
    vec4 cardRadii;     // its corners, in the same order
};

layout(binding = 1) uniform sampler2D source;

// Signed distance to a box with a radius per corner, y pointing down.
float boxDistance(vec2 p, vec4 b, vec4 r) {
    vec2 c = p - (b.xy + b.zw * 0.5);
    float k = c.x > 0.0 ? (c.y > 0.0 ? r.z : r.y) : (c.y > 0.0 ? r.w : r.x);
    vec2 q = abs(c) - b.zw * 0.5 + k;
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - k;
}

void main() {
    vec2 p = qt_TexCoord0 * size;
    float d;
    if (ellipse > 0.5) {
        // Distance to the rim, in pixels near enough for a one-pixel fade.
        vec2 e = (p - (hole.xy + hole.zw * 0.5)) / (hole.zw * 0.5);
        d = (length(e) - 1.0) * min(hole.z, hole.w) * 0.5;
    } else {
        d = boxDistance(p, hole, radii);
    }
    d = max(d, boxDistance(p, card, cardRadii));
    float a = clamp(0.5 - d, 0.0, 1.0);
    fragColor = texture(source, qt_TexCoord0) * a * qt_Opacity;
}
