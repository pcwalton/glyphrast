#version 410

in vec4 vAAResult;

out vec4 oFragColor;

void main() {
    float point0Spread = vAAResult.z;
    float point1Spread = vAAResult.w;

    // Compute the AA coverage.
    float value = 1.0;
    /*if (gl_FragCoord.x < vAAResult.x + point0Spread)
        value *= (gl_FragCoord.x - vAAResult.x) / point0Spread;
    if (gl_FragCoord.x > vAAResult.y - point1Spread)
        value *= (vAAResult.y - gl_FragCoord.x) / point1Spread;*/

    // Write in the color.
    oFragColor = vec4(value);
}

