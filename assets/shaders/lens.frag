#version 440
// A magnifying spotlight: the area it shows, stretched over the hole and cut
// to the hole's shape (a box with a radius per corner, or an ellipse) with
// an antialiased edge a pixel wide. Drawn here rather than as a Shape filled
// with the texture, whose fill mapped the texture at a scale that followed
// how the layer was transformed and put the zoomed pixels in the wrong
// place, and rather than through a layer mask, which resamples. The texture
// comes from a ShaderEffectSource with smooth off, so each shot pixel stays
// a square block.
//
// Build: qsb --glsl "100 es,120,150" --hlsl 50 --msl 12 -o lens.frag.qsb lens.frag

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 size;          // the hole in pixels
    vec4 radii;         // top left, top right, bottom right, bottom left
    float ellipse;      // 1 for an ellipse, when the radii are ignored
};

layout(binding = 1) uniform sampler2D source;

void main() {
    vec2 p = qt_TexCoord0 * size - size * 0.5;
    float d;
    if (ellipse > 0.5) {
        // Distance to the rim, in pixels near enough for a one-pixel fade.
        vec2 e = p / (size * 0.5);
        d = (length(e) - 1.0) * min(size.x, size.y) * 0.5;
    } else {
        float r = p.x > 0.0 ? (p.y > 0.0 ? radii.z : radii.y)
                            : (p.y > 0.0 ? radii.w : radii.x);
        vec2 q = abs(p) - size * 0.5 + r;
        d = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
    }
    float a = clamp(0.5 - d, 0.0, 1.0);
    fragColor = texture(source, qt_TexCoord0) * a * qt_Opacity;
}
