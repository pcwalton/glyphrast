#version 410

layout(isolines) in;

uniform vec2 uWindowDimensions;

in mat4 tcPoints[];
out vec4 vAAResult;

float GetEncodedPoint(int pointIndex) {
    if (pointIndex == 0)
        return tcPoints[0][0].x;
    if (pointIndex == 1)
        return tcPoints[0][0].y;
    if (pointIndex == 2)
        return tcPoints[0][0].z;
    if (pointIndex == 3)
        return tcPoints[0][0].w;
    if (pointIndex == 4)
        return tcPoints[0][1].x;
    if (pointIndex == 5)
        return tcPoints[0][1].y;
    if (pointIndex == 6)
        return tcPoints[0][1].z;
    if (pointIndex == 7)
        return tcPoints[0][1].w;
    if (pointIndex == 8)
        return tcPoints[0][2].x;
    if (pointIndex == 9)
        return tcPoints[0][2].y;
    if (pointIndex == 10)
        return tcPoints[0][2].z;
    if (pointIndex == 11)
        return tcPoints[0][2].w;
    if (pointIndex == 12)
        return tcPoints[0][3].x;
    if (pointIndex == 13)
        return tcPoints[0][3].y;
    if (pointIndex == 14)
        return tcPoints[0][3].z;
    return tcPoints[0][3].w;
}

float GetLocation(float encodedPoint) {
    return floor(encodedPoint / 32.0) / 16.0;
}

float GetSpread(float encodedPoint) {
    return floor(floor(mod(encodedPoint, 32.0) / 2.0) / 4.0) - 2.0;
}

void main() {
    int tessIndex = int(round(gl_TessCoord.y * float(gl_TessLevelOuter[0])));
    if (tessIndex % 2 != 0) {
        gl_Position = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    float encodedPoint0 = GetEncodedPoint(tessIndex);
    float encodedPoint1 = GetEncodedPoint(tessIndex + 1);
    float point0Location = GetLocation(encodedPoint0);
    float point1Location = GetLocation(encodedPoint1);
    /*float point0Spread = GetSpread(encodedPoint0);
    float point1Spread = GetSpread(encodedPoint1);*/
    float point0Spread = 0.0;
    float point1Spread = 0.0;
    vAAResult = vec4(point0Location, point1Location + point1Spread, point0Spread, point1Spread);
    float x = gl_TessCoord.x == 0.0 ? vAAResult.x : vAAResult.y;
    float y = gl_in[0].gl_Position.y;
    gl_Position = vec4(x, y, 0.0, 1.0);
}

