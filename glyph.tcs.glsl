#version 410

layout(vertices = 2) out;

uniform float uWidth;

in Tessellation {
    in vec2 vP0;
    in vec2 vP1;
    in vec2 vP2;
    in vec2 vP3;
    in int vWindingCW;
} iVertex[];

out Tessellation {
    vec4 vP0;
    vec4 vP1;
    vec4 vP2;
    vec4 vP3;
    int vWindingCW;
    int vEdge;
} oVertex[];

void main() {
    gl_TessLevelOuter[0] = 1;
    gl_TessLevelOuter[1] = int(abs(vP3.y - vP0.y));

    oVertex[gl_InvocationID].vP0 = iVertex[0].vP0;
    oVertex[gl_InvocationID].vP1 = iVertex[0].vP1;
    oVertex[gl_InvocationID].vP2 = iVertex[0].vP2;
    oVertex[gl_InvocationID].vP3 = iVertex[0].vP3;
    oVertex[gl_InvocationID].vWindingCW = vWindingCW;
    if (gl_InvocationID == 0) {
        oVertex[0].gl_Position = vec4(vP0, 0.0, 1.0);
        oVertex[0].vEdge = 0;
    } else {
        oVertex[1].gl_Position = vec4(uWidth, vP0.y, 0.0, 1.0);
        oVertex[1].vEdge = 1;
    }
}

