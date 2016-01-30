#version 410

in vec2 aAP0;
in vec2 aAP1;
in vec2 aAP2;
in vec2 aAP3;
in vec2 aBP0;
in vec2 aBP1;
in vec2 aBP2;
in vec2 aBP3;
in float aGlyphHeight;
in vec2 aRasterOrigin;
in float aRasterHeight;
in int aCurveCount;

float RasterX(vec2 p0, vec2 p1, vec2 p3, float glyphY) {
    if (p0.y != p3.y && glyphY >= min(p0.y, p3.y) && glyphY <= max(p0.y, p3.y)) {
        // https://www.reddit.com/r/MathHelp/comments/3pt8l5/
        //  quadratic_bezier_curve_line_intersections_the/
        float a = (p0.y - p1.y) + (p3.y - p1.y);
        float b = -2.0 * (p0.y - p1.y);
        float c = p0.y - glyphY;

        float t0 = (-b + sqrt(b * b - 4.0 * a * c)) / (2.0 * a);
        float t1 = (-b - sqrt(b * b - 4.0 * a * c)) / (2.0 * a);
        float t = t0 >= 0.0 && t0 <= 1.0 ? t0 : t1;

        float oneMinusT = 1.0 - t;
        float x = oneMinusT * oneMinusT * p0.x + 2.0 * oneMinusT * t * p1.x + t * t * p3.x;
        return x + aRasterOrigin.x;
    }

    return 100000.0;
}

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
    vec2 ap0 = aAP0 * scaleFactor;
    vec2 ap1 = aAP1 * scaleFactor;
    vec2 ap2 = aAP2 * scaleFactor;
    vec2 ap3 = aAP3 * scaleFactor;
    vec2 bp0 = aBP0 * scaleFactor;
    vec2 bp1 = aBP1 * scaleFactor;
    vec2 bp2 = aBP2 * scaleFactor;
    vec2 bp3 = aBP3 * scaleFactor;

    float rasterAX = RasterX(ap0, ap1, ap3, glyphY);
    float rasterBX = RasterX(bp0, bp1, bp3, glyphY);
    gl_Position = vec4(rasterAX, rasterY, rasterBX, 1.0);
    //vWindingCW = aP3.y >= aP0.y ? 1 : 0;
}

