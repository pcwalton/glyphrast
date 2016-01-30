#version 410

layout(vertices = 2) out;

out mat4 tcPoints[];

#define ASSIGN_IF(n) \
    if (pnext == n) \
        p##n = ptmp;

#define ASSIGN_TMP() \
    if (ptmp < 2500000.0) { \
        ASSIGN_IF(0) \
        else ASSIGN_IF(1) \
        else ASSIGN_IF(2) \
        else ASSIGN_IF(3) \
        else ASSIGN_IF(4) \
        else ASSIGN_IF(5) \
        else ASSIGN_IF(6) \
        else ASSIGN_IF(7) \
        else ASSIGN_IF(8) \
        else ASSIGN_IF(9) \
        else ASSIGN_IF(10) \
        else ASSIGN_IF(11) \
        else ASSIGN_IF(12) \
        else ASSIGN_IF(13) \
        else ASSIGN_IF(14) \
        else ASSIGN_IF(15) \
        pnext++; \
    }

#define ASSIGN(n) \
    ptmp = gl_in[n].gl_Position.x; \
    ASSIGN_TMP(); \
    ptmp = gl_in[n].gl_Position.z; \
    ASSIGN_TMP();

#define SWAP(a, b) \
    if (p##a > p##b) { \
        ptmp = p##a; \
        p##a = p##b; \
        p##b = ptmp; \
    }

void main() {
    gl_out[gl_InvocationID].gl_Position = vec4(gl_in[gl_InvocationID].gl_Position.xy, 0.0, 1.0);
    if (gl_InvocationID != 0)
        return;

    float p0 = 2500000.0, p1 = 2500000.0, p2 = 2500000.0, p3 = 2500000.0;
    float p4 = 2500000.0, p5 = 2500000.0, p6 = 2500000.0, p7 = 2500000.0;
    float p8 = 2500000.0, p9 = 2500000.0, p10 = 2500000.0, p11 = 2500000.0;
    float p12 = 2500000.0, p13 = 2500000.0, p14 = 2500000.0, p15 = 2500000.0;
    int pnext = 0;
    float ptmp;
    ASSIGN(0);
    ASSIGN(1);
    ASSIGN(2);
    ASSIGN(3);
    ASSIGN(4);
    ASSIGN(5);
    ASSIGN(6);
    ASSIGN(7);
    ASSIGN(8);
    ASSIGN(9);
    ASSIGN(10);
    ASSIGN(11);
    ASSIGN(12);
    ASSIGN(13);
    ASSIGN(14);
    ASSIGN(15);
    ASSIGN(16);
    ASSIGN(17);
    ASSIGN(18);
    ASSIGN(19);
    ASSIGN(20);
    ASSIGN(21);
    ASSIGN(22);
    ASSIGN(23);
    ASSIGN(24);
    ASSIGN(25);
    ASSIGN(26);
    ASSIGN(27);
    ASSIGN(28);
    ASSIGN(29);
    ASSIGN(30);
    ASSIGN(31);

    // Bose-Nelson sorting network algorithm. Seems to be faster than a traditional sort on the
    // GPU.
    SWAP(0, 1);
    SWAP(2, 3);
    SWAP(0, 2);
    SWAP(1, 3);
    SWAP(1, 2);
    if (pnext >= 4) {
        SWAP(4, 5);
        SWAP(6, 7);
        SWAP(4, 6);
        SWAP(5, 7);
        SWAP(5, 6);
        SWAP(0, 4);
        SWAP(1, 5);
        SWAP(1, 4);
        SWAP(2, 6);
        SWAP(3, 7);
        SWAP(3, 6);
        SWAP(2, 4);
        SWAP(3, 5);
        SWAP(3, 4);
        if (pnext >= 8) {
            SWAP(8, 9);
            SWAP(10, 11);
            SWAP(8, 10);
            SWAP(9, 11);
            SWAP(9, 10);
            SWAP(12, 13);
            SWAP(14, 15);
            SWAP(12, 14);
            SWAP(13, 15);
            SWAP(13, 14);
            SWAP(8, 12);
            SWAP(9, 13);
            SWAP(9, 12);
            SWAP(10, 14);
            SWAP(11, 15);
            SWAP(11, 14);
            SWAP(10, 12);
            SWAP(11, 13);
            SWAP(11, 12);
            SWAP(0, 8);
            SWAP(1, 9);
            SWAP(1, 8);
            SWAP(2, 10);
            SWAP(3, 11);
            SWAP(3, 10);
            SWAP(2, 8);
            SWAP(3, 9);
            SWAP(3, 8);
            SWAP(4, 12);
            SWAP(5, 13);
            SWAP(5, 12);
            SWAP(6, 14);
            SWAP(7, 15);
            SWAP(7, 14);
            SWAP(6, 12);
            SWAP(7, 13);
            SWAP(7, 12);
            SWAP(4, 8);
            SWAP(5, 9);
            SWAP(5, 8);
            SWAP(6, 10);
            SWAP(7, 11);
            SWAP(7, 10);
            SWAP(6, 8);
            SWAP(7, 9);
            SWAP(7, 8);
        }
    }

    tcPoints[0][0] = vec4(p0, p1, p2, p3);
    tcPoints[0][1] = vec4(p4, p5, p6, p7);
    tcPoints[0][2] = vec4(p8, p9, p10, p11);
    tcPoints[0][3] = vec4(p12, p13, p14, p15);

    gl_TessLevelOuter[0] = min(pnext, 16);
    gl_TessLevelOuter[1] = 1;
}

