#version 410

layout(vertices = 2) out;

out mat4 tcPoints[];

#define ASSIGN_TMP() \
    if (ptmp < 2500000.0) { \
        if (pnext == 0) \
            p0 = ptmp; \
        else if (pnext == 1) \
            p1 = ptmp; \
        else if (pnext == 2) \
            p2 = ptmp; \
        else if (pnext == 3) \
            p3 = ptmp; \
        else if (pnext == 4) \
            p4 = ptmp; \
        else if (pnext == 5) \
            p5 = ptmp; \
        else if (pnext == 6) \
            p6 = ptmp; \
        else if (pnext == 7) \
            p7 = ptmp; \
        else if (pnext == 8) \
            p8 = ptmp; \
        else if (pnext == 9) \
            p9 = ptmp; \
        else if (pnext == 10) \
            p10 = ptmp; \
        else if (pnext == 11) \
            p11 = ptmp; \
        else if (pnext == 12) \
            p12 = ptmp; \
        else if (pnext == 13) \
            p13 = ptmp; \
        else if (pnext == 14) \
            p14 = ptmp; \
        else if (pnext == 15) \
            p15 = ptmp; \
        pnext++; \
    }

#define ASSIGN(n) \
    ptmp = gl_in[n].gl_Position.x; \
    ASSIGN_TMP(); \
    ptmp = gl_in[n].gl_Position.z; \
    ASSIGN_TMP();

#define SWAP(a, b) \
    if (a > b) { \
        ptmp = a; \
        a = b; \
        b = ptmp; \
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
    SWAP(p0, p1);
    SWAP(p2, p3);
    SWAP(p0, p2);
    SWAP(p1, p3);
    SWAP(p1, p2);
    if (pnext >= 4) {
        SWAP(p4, p5);
        SWAP(p6, p7);
        SWAP(p4, p6);
        SWAP(p5, p7);
        SWAP(p5, p6);
        SWAP(p0, p4);
        SWAP(p1, p5);
        SWAP(p1, p4);
        SWAP(p2, p6);
        SWAP(p3, p7);
        SWAP(p3, p6);
        SWAP(p2, p4);
        SWAP(p3, p5);
        SWAP(p3, p4);
        if (pnext >= 8) {
            SWAP(p8, p9);
            SWAP(p10, p11);
            SWAP(p8, p10);
            SWAP(p9, p11);
            SWAP(p9, p10);
            SWAP(p12, p13);
            SWAP(p14, p15);
            SWAP(p12, p14);
            SWAP(p13, p15);
            SWAP(p13, p14);
            SWAP(p8, p12);
            SWAP(p9, p13);
            SWAP(p9, p12);
            SWAP(p10, p14);
            SWAP(p11, p15);
            SWAP(p11, p14);
            SWAP(p10, p12);
            SWAP(p11, p13);
            SWAP(p11, p12);
            SWAP(p0, p8);
            SWAP(p1, p9);
            SWAP(p1, p8);
            SWAP(p2, p10);
            SWAP(p3, p11);
            SWAP(p3, p10);
            SWAP(p2, p8);
            SWAP(p3, p9);
            SWAP(p3, p8);
            SWAP(p4, p12);
            SWAP(p5, p13);
            SWAP(p5, p12);
            SWAP(p6, p14);
            SWAP(p7, p15);
            SWAP(p7, p14);
            SWAP(p6, p12);
            SWAP(p7, p13);
            SWAP(p7, p12);
            SWAP(p4, p8);
            SWAP(p5, p9);
            SWAP(p5, p8);
            SWAP(p6, p10);
            SWAP(p7, p11);
            SWAP(p7, p10);
            SWAP(p6, p8);
            SWAP(p7, p9);
            SWAP(p7, p8);
        }
    }
    if (pnext >= 4) {
        if (pnext >= 8) {
        }
    }

    tcPoints[gl_InvocationID][0] = vec4(p0, p1, p2, p3);
    tcPoints[gl_InvocationID][1] = vec4(p4, p5, p6, p7);
    tcPoints[gl_InvocationID][2] = vec4(p8, p9, p10, p11);
    tcPoints[gl_InvocationID][3] = vec4(p12, p13, p14, p15);

    gl_TessLevelOuter[0] = min(pnext, 16);
    gl_TessLevelOuter[1] = 1;
}

