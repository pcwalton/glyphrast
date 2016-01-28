#version 410

in vec2 aP0;
in vec2 aP1;
in vec2 aP2;
in vec2 aP3;

//out int vWindingCW;

void main() {
    float y = float(gl_InstanceID);
    if (y >= min(aP0.y, aP3.y) && y < max(aP0.y, aP3.y)) {
        float x = abs(mix(aP0.x, aP3.x, (y - aP0.y) / (aP3.y - aP0.y)));
        gl_Position = vec4(x, y, 0.0, 1.0);
    } else {
        gl_Position = vec4(-1.0, y, 0.0, 1.0);
    }
    //vWindingCW = aP3.y >= aP0.y ? 1 : 0;
}

