#version 410

in vec3 vAAResult;

out vec4 oFragColor;

void main() {
    float value = vAAResult.z;
    if (abs(vAAResult.x - gl_FragCoord.x) < 1.0)
        value *= 0.5 + (gl_FragCoord.x - vAAResult.x) / 2.0;
    else if (abs(vAAResult.y - gl_FragCoord.x) < 1.0)
        value *= 0.5 + (vAAResult.y - gl_FragCoord.x) / 2.0;
    oFragColor = vec4(value);
}

