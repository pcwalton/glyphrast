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
        //
        // TODO(pcwalton): Algebraic simplifications. Don't trust the driver to do it for us.
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

    return 2500000.0;
}

// Returns true for clockwise winding and false for counterclockwise winding.
bool Winding(vec2 p0, vec2 p3) {
    return (p0.y == p3.y) ? (p0.x <= p3.x) : (p0.y < p3.y);
}

float Encode(float rasterX, float ySubpixel, bool winding) {
    return round(rasterX * 16.0) * 32.0 + ySubpixel * 2.0 + (winding ? 1.0 : 0.0);
}

void main() {
    float y = float(gl_InstanceID);
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

    float encodedRasterAX = Encode(RasterX(ap0, ap1, ap3, glyphY), 15.0, Winding(ap0, ap3));
    float encodedRasterBX = Encode(RasterX(bp0, bp1, bp3, glyphY), 15.0, Winding(bp0, bp3));
    gl_Position = vec4(encodedRasterAX, rasterY, encodedRasterBX, 1.0);
}

