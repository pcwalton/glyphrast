#version 410

layout(isolines) in;

uniform float uWidth;

in vec2 vP0;
in vec2 vP1;
in vec2 vP2;
in vec2 vP3;
in int vEdge;
in int vWindingCW;

out float vFragmentWindingCW;

void main() {
    float y = mix(vP0.y, vP3.y, gl_TessCoord.y);
    float x;
    if (vEdge == 0)
        x = mix(vP0.x, vP3.x, gl_TessCoord.y);
    else
        x = uWidth;
    vFragmentWindingCW = vWindingCW != 0 ? 1.0 : 0.0;
    gl_Position = vec4(x / uWidth, y / uWidth, 0.0, 1.0);
}

