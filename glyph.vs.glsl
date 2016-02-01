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

bool IntersectsCurve(vec2 p0, vec2 p3, float y) {
    return y >= min(p0.y, p3.y) && y <= max(p0.y, p3.y);
}

// Returns the bottom and top X extents.
float RasterX(vec2 p0, vec2 p1, vec2 p3, float glyphYAAExtents) {
    if (p0.y != p3.y && IntersectsCurve(p0, p3, glyphYAAExtents)) { /*&&
            IntersectsCurve(p0, p3, glyphYAAExtents.y)) {*/
        // https://www.reddit.com/r/MathHelp/comments/3pt8l5/
        //  quadratic_bezier_curve_line_intersections_the/
        //
        // TODO(pcwalton): Algebraic simplifications. Don't trust the driver to do it for us.
        float a = (p0.y - p1.y) + (p3.y - p1.y);
        float b = -2.0 * (p0.y - p1.y);
        float c = p0.y - glyphYAAExtents;

        float discriminant = sqrt((b * b) - 4.0 * (a) * c);
        float t0 = (-b + discriminant) / (2.0 * a);
        float t1 = (-b - discriminant) / (2.0 * a);
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

float Encode(float rasterX, bool winding) {
    float spread = rasterX.y - rasterX.x;
    float encodedSpread = round((clamp(-2.0, 2.0, spread) + 2.0) * 8.0);
    return round(rasterX * 16.0) * 32.0 + encodedSpread + (winding ? 1.0 : 0.0);
}

void main() {
    float y = float(gl_InstanceID);
    float glyphHeight = aGlyphHeight;
    float rasterHeight = aRasterHeight;

    float glyphY = mod(y, rasterHeight);
    vec2 glyphYAAExtents = vec2(glyphY - 0.0, glyphY + 0.0);
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

    float encodedRasterAX = Encode(RasterX(ap0, ap1, ap3, glyphYAAExtents.x), Winding(ap0, ap3));
    float encodedRasterBX = Encode(RasterX(bp0, bp1, bp3, glyphYAAExtents.x), Winding(bp0, bp3));
    gl_Position = vec4(encodedRasterAX, rasterY, encodedRasterBX, 1.0);
}

