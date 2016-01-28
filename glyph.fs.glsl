#version 410

in float vFragmentWindingCW;

out vec4 oFragColor;

void main() {
    oFragColor = vFragmentWindingCW > 0.0 ? vec4(1.0, 0.0, 0.0, 1.0) : vec4(0.0, 0.0, 1.0, 1.0);
}

