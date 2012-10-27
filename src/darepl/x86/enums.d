module darepl.x86.enums;

public enum X86PrefixName : ubyte
{
    none,
    lock, // Ignored.
    repne,
    repnz,
    rep,
    repe,
    repz,
}

public enum X86OpCodeName : ubyte
{
    add,
    nop,
}

public enum X86RegisterName : ushort
{
    eax,
    ebx,
    ecx,
    edx,
    esi,
    edi,
    esp,
    ebp,

    xmm0,
    xmm1,
    xmm2,
    xmm3,
    xmm4,
    xmm5,
    xmm6,
    xmm7,

    ymm0,
    ymm1,
    ymm2,
    ymm3,
    ymm4,
    ymm5,
    ymm6,
    ymm7,

    eip,
    eflags,

    rax,
    rbx,
    rcx,
    rdx,
    rsi,
    rdi,
    rsp,
    rbp,
    r8,
    r9,
    r10,
    r11,
    r12,
    r13,
    r14,
    r15,

    xmm8,
    xmm9,
    xmm10,
    xmm11,
    xmm12,
    xmm13,
    xmm14,
    xmm15,

    ymm8,
    ymm9,
    ymm10,
    ymm11,
    ymm12,
    ymm13,
    ymm14,
    ymm15,

    rip,
    rflags,

    mxcsr,

    st0,
    st1,
    st2,
    st3,
    st4,
    st5,
    st6,
    st7,

    mm0,
    mm1,
    mm2,
    mm3,
    mm4,
    mm5,
    mm6,
    mm7,
}
