#version 410

in vec2 vEdges;

out vec4 oFragColor;

void main() {
    float value;
    if (abs(vEdges.x - gl_FragCoord.x) < 1.0)
        value = 0.5 + (gl_FragCoord.x - vEdges.x) / 2.0;
    else if (abs(vEdges.y - gl_FragCoord.x) < 1.0)
        value = 0.5 + (vEdges.y - gl_FragCoord.x) / 2.0;
    else
        value = 1.0;
    oFragColor = vec4(value);
}

