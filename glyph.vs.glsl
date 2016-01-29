#version 410

uniform float uGlyphHeight;
uniform float uRasterHeight;

in vec2 aP0;
in vec2 aP1;
in vec2 aP2;
in vec2 aP3;

//out int vWindingCW;

void main() {
    float y = float(gl_InstanceID);
    float glyphY = mod(y, uRasterHeight);
    float scaleFactor = uRasterHeight / uGlyphHeight;
    vec2 p0 = aP0 * scaleFactor;
    vec2 p1 = aP1 * scaleFactor;
    vec2 p2 = aP2 * scaleFactor;
    vec2 p3 = aP3 * scaleFactor;
    if (glyphY >= min(p0.y, p3.y) && glyphY < max(p0.y, p3.y)) {
        float x = abs(mix(p0.x, p3.x, (glyphY - p0.y) / (p3.y - p0.y)));
        gl_Position = vec4(x, y, 0.0, 1.0);
    } else {
        gl_Position = vec4(100000.0, y, 0.0, 1.0);
    }
    //vWindingCW = aP3.y >= aP0.y ? 1 : 0;
}

