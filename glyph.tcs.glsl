#version 410

layout(vertices = 2) out;

uniform float uWidth;
uniform int uCurveCount;

//in int vWindingCW[];

out mat4 tcPoints[];
//patch out float tcY;
/*out TCData {
    //float tcPoint0;
    //float tcPoint1;
    float tcY;
} tcData[];*/
//out float tcPoint0[];
//out float tcPoint1[];
//out float tcY[];
//patch out int tcWindingsCW[16];

#define SWAP(a, b) \
    if (!Less(p##a, p##b)) { \
        ptmp = p##a; \
        p##a = p##b; \
        p##b = ptmp; \
    }

bool Less(float a, float b) {
    return b < 0.0 || (a >= 0.0 && a < b);
}

void main() {
    gl_out[gl_InvocationID].gl_Position = gl_in[gl_InvocationID].gl_Position;
    if (gl_InvocationID != 0)
        return;

    float p0 = gl_in[0].gl_Position.x;
    float p1 = gl_in[1].gl_Position.x;
    float p2 = gl_in[2].gl_Position.x;
    float p3 = gl_in[3].gl_Position.x;
    float p4 = gl_in[4].gl_Position.x;
    float p5 = gl_in[5].gl_Position.x;
    float p6 = gl_in[6].gl_Position.x;
    float p7 = gl_in[7].gl_Position.x;
    float p8 = gl_in[8].gl_Position.x;
    float p9 = gl_in[9].gl_Position.x;
    float p10 = gl_in[10].gl_Position.x;
    float p11 = gl_in[11].gl_Position.x;
    float p12 = gl_in[12].gl_Position.x;
    float p13 = 0.0;
    float p14 = 0.0;
    float p15 = 0.0;

    // Bose-Nelson sorting network algorithm to work around driver bugs.
    int count = 16;
    float ptmp;
    SWAP(0, 1)
    SWAP(2, 3)
    SWAP(0, 2)
    SWAP(1, 3)
    SWAP(1, 2)
    SWAP(4, 5)
    SWAP(6, 7)
    SWAP(4, 6)
    SWAP(5, 7)
    SWAP(5, 6)
    SWAP(0, 4)
    SWAP(1, 5)
    SWAP(1, 4)
    SWAP(2, 6)
    SWAP(3, 7)
    SWAP(3, 6)
    SWAP(2, 4)
    SWAP(3, 5)
    SWAP(3, 4)
    SWAP(8, 9)
    SWAP(10, 11)
    SWAP(8, 10)
    SWAP(9, 11)
    SWAP(9, 10)
    SWAP(12, 13)
    SWAP(14, 15)
    SWAP(12, 14)
    SWAP(13, 15)
    SWAP(13, 14)
    SWAP(8, 12)
    SWAP(9, 13)
    SWAP(9, 12)
    SWAP(10, 14)
    SWAP(11, 15)
    SWAP(11, 14)
    SWAP(10, 12)
    SWAP(11, 13)
    SWAP(11, 12)
    SWAP(0, 8)
    SWAP(1, 9)
    SWAP(1, 8)
    SWAP(2, 10)
    SWAP(3, 11)
    SWAP(3, 10)
    SWAP(2, 8)
    SWAP(3, 9)
    SWAP(3, 8)
    SWAP(4, 12)
    SWAP(5, 13)
    SWAP(5, 12)
    SWAP(6, 14)
    SWAP(7, 15)
    SWAP(7, 14)
    SWAP(6, 12)
    SWAP(7, 13)
    SWAP(7, 12)
    SWAP(4, 8)
    SWAP(5, 9)
    SWAP(5, 8)
    SWAP(6, 10)
    SWAP(7, 11)
    SWAP(7, 10)
    SWAP(6, 8)
    SWAP(7, 9)
    SWAP(7, 8)

    tcPoints[0][0].x = p0;
    tcPoints[0][0].y = p1;
    tcPoints[0][0].z = p2;
    tcPoints[0][0].w = p3;
    tcPoints[0][1].x = p4;
    tcPoints[0][1].y = p5;
    tcPoints[0][1].z = p6;
    tcPoints[0][1].w = p7;
    tcPoints[0][2].x = p8;
    tcPoints[0][2].y = p9;
    tcPoints[0][2].z = p10;
    tcPoints[0][2].w = p11;
    tcPoints[0][3].x = p12;
    tcPoints[0][3].y = p13;
    tcPoints[0][3].z = p14;
    tcPoints[0][3].w = p15;

    gl_TessLevelOuter[0] = count;
    gl_TessLevelOuter[1] = 1;
}

