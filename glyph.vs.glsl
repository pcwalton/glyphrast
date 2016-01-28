#version 410

in vec2 aP0;
in vec2 aP1;
in vec2 aP2;
in vec2 aP3;

out vec2 vP0;
out vec2 vP1;
out vec2 vP2;
out vec2 vP3;
out int vWindingCW;

void main() {
    vP0 = aP0;
    vP1 = aP1;
    vP2 = aP2;
    vP3 = aP3;
    vWindingCW = aP3.y >= aP0.y ? 1 : 0;
    gl_Position = vec4(vP0, 0.0, 1.0);
}

