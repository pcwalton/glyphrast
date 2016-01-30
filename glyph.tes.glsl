#version 410

layout(isolines) in;

uniform vec2 uWindowDimensions;

in mat4 tcPoints[];
out vec2 vEdges;
//patch in float tcY;
//in float tcPoint0[]; 
//in float tcPoint1[];
//in float tcY[];
//patch in int tcWindingsCW[16];

float GetEdge(int pointIndex) {
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

void main() {
    int tessIndex = int(round(gl_TessCoord.y * 16.0));
    if (tessIndex % 2 == 0) {
        vEdges = vec2(GetEdge(tessIndex), GetEdge(tessIndex + 1));
        float x = gl_TessCoord.x == 0.0 ? vEdges.x : vEdges.y;
        float y = gl_in[0].gl_Position.y;
        gl_Position = vec4(mix(-1.0, 1.0, x / uWindowDimensions.x),
                           mix(-1.0, 1.0, y / uWindowDimensions.y),
                           0.0,
                           1.0);
    } else {
        gl_Position = vec4(0.0, 0.0, 0.0, 1.0);
    }
}

