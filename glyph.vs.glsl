#version 410

in vec2 aP0;
in vec2 aP1;
in vec2 aP2;
in vec2 aP3;
in float aGlyphHeight;
in vec2 aRasterOrigin;
in float aRasterHeight;
in int aCurveCount;

//out int vWindingCW;

void main() {
    float y = float(gl_InstanceID);
    /*float glyphHeight = uGlyphHeightPalette[aGlyphID];
    float rasterHeight = uRasterHeightPalette[aGlyphID];
    if (glyphHeight == 0.0)
        glyphHeight = 1350.0;
    if (rasterHeight == 0.0)
        rasterHeight = 24.0;*/
    float glyphHeight = aGlyphHeight;
    float rasterHeight = aRasterHeight;

    float glyphY = mod(y, rasterHeight);
    float rasterY = y + aRasterOrigin.y;
    float scaleFactor = rasterHeight / glyphHeight;
    vec2 p0 = aP0 * scaleFactor;
    vec2 p1 = aP1 * scaleFactor;
    vec2 p2 = aP2 * scaleFactor;
    vec2 p3 = aP3 * scaleFactor;

    float rasterX;
    if (p0.y != p3.y && glyphY >= min(p0.y, p3.y) && glyphY <= max(p0.y, p3.y)) {
        float x = abs(mix(p0.x, p3.x, (glyphY - p0.y) / (p3.y - p0.y)));
        rasterX = x + aRasterOrigin.x;
    } else {
        rasterX = 100000.0;
    }
    gl_Position = vec4(rasterX, rasterY, 0.0, 1.0);
    //vWindingCW = aP3.y >= aP0.y ? 1 : 0;
}

