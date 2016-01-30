#version 410

in vec3 vAAResult;

out vec4 oFragColor;

void main() {
    // Start with the vertical AA value.
    float value = vAAResult.z;

    // Compute the horizontal AA value.
    if (abs(vAAResult.x - gl_FragCoord.x) < 1.0)
        value *= 0.5 + (gl_FragCoord.x - vAAResult.x) / 2.0;
    else if (abs(vAAResult.y - gl_FragCoord.x) < 1.0)
        value *= 0.5 + (vAAResult.y - gl_FragCoord.x) / 2.0;

    // Write in the color.
    oFragColor = vec4(value);
}

