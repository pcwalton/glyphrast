#version 410

layout(isolines) in;

uniform vec2 uWindowDimensions;

in mat4 tcPoints[];
out vec3 vAAResult;

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

float GetOpacity(float encodedPoint) {
    return floor(mod(encodedPoint, 32.0) / 2.0) / 15.0;
}

void main() {
    int tessIndex = int(round(gl_TessCoord.y * float(gl_TessLevelOuter[0])));
    if (tessIndex % 2 == 0) {
        float encodedPoint0 = GetEncodedPoint(tessIndex);
        float encodedPoint1 = GetEncodedPoint(tessIndex + 1);
        vAAResult = vec3(GetLocation(encodedPoint0),
                         GetLocation(encodedPoint1),
                         GetOpacity(encodedPoint0));
        float x = gl_TessCoord.x == 0.0 ? vAAResult.x : vAAResult.y;
        float y = gl_in[0].gl_Position.y;
        gl_Position = vec4(mix(-1.0, 1.0, x / uWindowDimensions.x),
                           mix(-1.0, 1.0, y / uWindowDimensions.y),
                           0.0,
                           1.0);
    } else {
        gl_Position = vec4(0.0, 0.0, 0.0, 1.0);
    }
}

