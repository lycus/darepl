module darepl.epiphany.machine;

import std.conv,
       std.string,
       darepl.core.lexer,
       darepl.core.machine,
       darepl.core.parser,
       darepl.epiphany.enums,
       darepl.epiphany.expressions,
       darepl.epiphany.instructions,
       darepl.epiphany.target,
       darepl.epiphany.emulation.arithmetic;

public final class EpiphanyMachine : Machine
{
    public this(EpiphanyTarget target, ubyte bits) pure nothrow
    in
    {
        assert(target);
        assert(bits == 32);
    }
    body
    {
        super(target, bits);
    }

    protected override string createDispatchString(Instruction instruction)
    {
        auto insn = cast(EpiphanyInstruction)instruction;

        static string operandToString(Object operand)
        {
            if (auto comma = cast(EpiphanyCommaExpression)operand)
                return "disp";
            else if (auto expr = cast(EpiphanyExpression)operand)
                return "mem";
            else if (auto reg = cast(EpiphanyRegister)operand)
                return "reg32";
            else
                return to!string((cast(Literal)operand).type);
        }

        auto name = to!string(insn.opCode);

        foreach (operand; insn.operands)
            if (operand)
                name ~= '_' ~ operandToString(operand);

        return name;
    }

    protected override void initializeRegisters(ubyte bits) pure nothrow
    {
        auto r0 = registers[EpiphanyRegisterName.r0] = new EpiphanyRegister32(EpiphanyRegisterName.r0);
        auto r1 = registers[EpiphanyRegisterName.r1] = new EpiphanyRegister32(EpiphanyRegisterName.r1);
        auto r2 = registers[EpiphanyRegisterName.r2] = new EpiphanyRegister32(EpiphanyRegisterName.r2);
        auto r3 = registers[EpiphanyRegisterName.r3] = new EpiphanyRegister32(EpiphanyRegisterName.r3);
        auto r4 = registers[EpiphanyRegisterName.r4] = new EpiphanyRegister32(EpiphanyRegisterName.r4);
        auto r5 = registers[EpiphanyRegisterName.r5] = new EpiphanyRegister32(EpiphanyRegisterName.r5);
        auto r6 = registers[EpiphanyRegisterName.r6] = new EpiphanyRegister32(EpiphanyRegisterName.r6);
        auto r7 = registers[EpiphanyRegisterName.r7] = new EpiphanyRegister32(EpiphanyRegisterName.r7);
        auto r8 = registers[EpiphanyRegisterName.r8] = new EpiphanyRegister32(EpiphanyRegisterName.r8);
        auto r9 = registers[EpiphanyRegisterName.r9] = new EpiphanyRegister32(EpiphanyRegisterName.r9);
        auto r10 = registers[EpiphanyRegisterName.r10] = new EpiphanyRegister32(EpiphanyRegisterName.r10);
        auto r11 = registers[EpiphanyRegisterName.r11] = new EpiphanyRegister32(EpiphanyRegisterName.r11);
        registers[EpiphanyRegisterName.r12] = new EpiphanyRegister32(EpiphanyRegisterName.r12);
        auto r13 = registers[EpiphanyRegisterName.r13] = new EpiphanyRegister32(EpiphanyRegisterName.r13);
        auto r14 = registers[EpiphanyRegisterName.r14] = new EpiphanyRegister32(EpiphanyRegisterName.r14);
        registers[EpiphanyRegisterName.r15] = new EpiphanyRegister32(EpiphanyRegisterName.r15);
        registers[EpiphanyRegisterName.r16] = new EpiphanyRegister32(EpiphanyRegisterName.r16);
        registers[EpiphanyRegisterName.r17] = new EpiphanyRegister32(EpiphanyRegisterName.r17);
        registers[EpiphanyRegisterName.r18] = new EpiphanyRegister32(EpiphanyRegisterName.r18);
        registers[EpiphanyRegisterName.r19] = new EpiphanyRegister32(EpiphanyRegisterName.r19);
        registers[EpiphanyRegisterName.r20] = new EpiphanyRegister32(EpiphanyRegisterName.r20);
        registers[EpiphanyRegisterName.r21] = new EpiphanyRegister32(EpiphanyRegisterName.r21);
        registers[EpiphanyRegisterName.r22] = new EpiphanyRegister32(EpiphanyRegisterName.r22);
        registers[EpiphanyRegisterName.r23] = new EpiphanyRegister32(EpiphanyRegisterName.r23);
        registers[EpiphanyRegisterName.r24] = new EpiphanyRegister32(EpiphanyRegisterName.r24);
        registers[EpiphanyRegisterName.r25] = new EpiphanyRegister32(EpiphanyRegisterName.r25);
        registers[EpiphanyRegisterName.r26] = new EpiphanyRegister32(EpiphanyRegisterName.r26);
        registers[EpiphanyRegisterName.r27] = new EpiphanyRegister32(EpiphanyRegisterName.r27);
        registers[EpiphanyRegisterName.r28] = new EpiphanyRegister32(EpiphanyRegisterName.r28);
        registers[EpiphanyRegisterName.r29] = new EpiphanyRegister32(EpiphanyRegisterName.r29);
        registers[EpiphanyRegisterName.r30] = new EpiphanyRegister32(EpiphanyRegisterName.r30);
        registers[EpiphanyRegisterName.r31] = new EpiphanyRegister32(EpiphanyRegisterName.r31);
        registers[EpiphanyRegisterName.r32] = new EpiphanyRegister32(EpiphanyRegisterName.r32);
        registers[EpiphanyRegisterName.r33] = new EpiphanyRegister32(EpiphanyRegisterName.r33);
        registers[EpiphanyRegisterName.r34] = new EpiphanyRegister32(EpiphanyRegisterName.r34);
        registers[EpiphanyRegisterName.r35] = new EpiphanyRegister32(EpiphanyRegisterName.r35);
        registers[EpiphanyRegisterName.r36] = new EpiphanyRegister32(EpiphanyRegisterName.r36);
        registers[EpiphanyRegisterName.r37] = new EpiphanyRegister32(EpiphanyRegisterName.r37);
        registers[EpiphanyRegisterName.r38] = new EpiphanyRegister32(EpiphanyRegisterName.r38);
        registers[EpiphanyRegisterName.r39] = new EpiphanyRegister32(EpiphanyRegisterName.r39);
        registers[EpiphanyRegisterName.r40] = new EpiphanyRegister32(EpiphanyRegisterName.r40);
        registers[EpiphanyRegisterName.r41] = new EpiphanyRegister32(EpiphanyRegisterName.r41);
        registers[EpiphanyRegisterName.r42] = new EpiphanyRegister32(EpiphanyRegisterName.r42);
        registers[EpiphanyRegisterName.r43] = new EpiphanyRegister32(EpiphanyRegisterName.r43);
        registers[EpiphanyRegisterName.r44] = new EpiphanyRegister32(EpiphanyRegisterName.r44);
        registers[EpiphanyRegisterName.r45] = new EpiphanyRegister32(EpiphanyRegisterName.r45);
        registers[EpiphanyRegisterName.r46] = new EpiphanyRegister32(EpiphanyRegisterName.r46);
        registers[EpiphanyRegisterName.r47] = new EpiphanyRegister32(EpiphanyRegisterName.r47);
        registers[EpiphanyRegisterName.r48] = new EpiphanyRegister32(EpiphanyRegisterName.r48);
        registers[EpiphanyRegisterName.r49] = new EpiphanyRegister32(EpiphanyRegisterName.r49);
        registers[EpiphanyRegisterName.r50] = new EpiphanyRegister32(EpiphanyRegisterName.r50);
        registers[EpiphanyRegisterName.r51] = new EpiphanyRegister32(EpiphanyRegisterName.r51);
        registers[EpiphanyRegisterName.r52] = new EpiphanyRegister32(EpiphanyRegisterName.r52);
        registers[EpiphanyRegisterName.r53] = new EpiphanyRegister32(EpiphanyRegisterName.r53);
        registers[EpiphanyRegisterName.r54] = new EpiphanyRegister32(EpiphanyRegisterName.r54);
        registers[EpiphanyRegisterName.r55] = new EpiphanyRegister32(EpiphanyRegisterName.r55);
        registers[EpiphanyRegisterName.r56] = new EpiphanyRegister32(EpiphanyRegisterName.r56);
        registers[EpiphanyRegisterName.r57] = new EpiphanyRegister32(EpiphanyRegisterName.r57);
        registers[EpiphanyRegisterName.r58] = new EpiphanyRegister32(EpiphanyRegisterName.r58);
        registers[EpiphanyRegisterName.r59] = new EpiphanyRegister32(EpiphanyRegisterName.r59);
        registers[EpiphanyRegisterName.r60] = new EpiphanyRegister32(EpiphanyRegisterName.r60);
        registers[EpiphanyRegisterName.r61] = new EpiphanyRegister32(EpiphanyRegisterName.r61);
        registers[EpiphanyRegisterName.r62] = new EpiphanyRegister32(EpiphanyRegisterName.r62);
        registers[EpiphanyRegisterName.r63] = new EpiphanyRegister32(EpiphanyRegisterName.r63);

        registers[EpiphanyRegisterName.a1] = new EpiphanyRegister32(EpiphanyRegisterName.a1, r0.memory);
        registers[EpiphanyRegisterName.a2] = new EpiphanyRegister32(EpiphanyRegisterName.a2, r1.memory);
        registers[EpiphanyRegisterName.a3] = new EpiphanyRegister32(EpiphanyRegisterName.a3, r2.memory);
        registers[EpiphanyRegisterName.a4] = new EpiphanyRegister32(EpiphanyRegisterName.a4, r3.memory);

        registers[EpiphanyRegisterName.v1] = new EpiphanyRegister32(EpiphanyRegisterName.v1, r4.memory);
        registers[EpiphanyRegisterName.v2] = new EpiphanyRegister32(EpiphanyRegisterName.v2, r5.memory);
        registers[EpiphanyRegisterName.v3] = new EpiphanyRegister32(EpiphanyRegisterName.v3, r6.memory);
        registers[EpiphanyRegisterName.v4] = new EpiphanyRegister32(EpiphanyRegisterName.v4, r7.memory);
        registers[EpiphanyRegisterName.v5] = new EpiphanyRegister32(EpiphanyRegisterName.v5, r8.memory);
        registers[EpiphanyRegisterName.v6] = new EpiphanyRegister32(EpiphanyRegisterName.v6, r9.memory);
        registers[EpiphanyRegisterName.v7] = new EpiphanyRegister32(EpiphanyRegisterName.v7, r10.memory);
        registers[EpiphanyRegisterName.v8] = new EpiphanyRegister32(EpiphanyRegisterName.v8, r11.memory);

        registers[EpiphanyRegisterName.sb] = new EpiphanyRegister32(EpiphanyRegisterName.sb, r9.memory);
        registers[EpiphanyRegisterName.sl] = new EpiphanyRegister32(EpiphanyRegisterName.sl, r10.memory);
        registers[EpiphanyRegisterName.fp] = new EpiphanyRegister32(EpiphanyRegisterName.fp, r11.memory);
        registers[EpiphanyRegisterName.sp] = new EpiphanyRegister32(EpiphanyRegisterName.sp, r13.memory);
        registers[EpiphanyRegisterName.lr] = new EpiphanyRegister32(EpiphanyRegisterName.lr, r14.memory);

        registers[EpiphanyRegisterName.config] = new EpiphanyConfigRegister32();
        registers[EpiphanyRegisterName.status] = new EpiphanyStatusRegister32();

        registers[EpiphanyRegisterName.ctimer0] = new EpiphanyTimerRegister32(EpiphanyRegisterName.ctimer0);
        registers[EpiphanyRegisterName.ctimer1] = new EpiphanyTimerRegister32(EpiphanyRegisterName.ctimer1);

        registers[EpiphanyRegisterName.iret] = new EpiphanyRegister32(EpiphanyRegisterName.iret);
        registers[EpiphanyRegisterName.imask] = new EpiphanyRegister32(EpiphanyRegisterName.imask);
        auto ilat = registers[EpiphanyRegisterName.ilat] = new EpiphanyRegister32(EpiphanyRegisterName.ilat);
        registers[EpiphanyRegisterName.ilatst] = new EpiphanyRegister32(EpiphanyRegisterName.ilatst, ilat.memory);
        registers[EpiphanyRegisterName.ilatcl] = new EpiphanyRegister32(EpiphanyRegisterName.ilatcl, ilat.memory);
        registers[EpiphanyRegisterName.ipend] = new EpiphanyRegister32(EpiphanyRegisterName.ipend);

        registers[EpiphanyRegisterName.dma0config] = new EpiphanyDMAConfigRegister32(EpiphanyRegisterName.dma0config);
        registers[EpiphanyRegisterName.dma0count] = new EpiphanyRegister32(EpiphanyRegisterName.dma0count);
        registers[EpiphanyRegisterName.dma0stride] = new EpiphanyRegister32(EpiphanyRegisterName.dma0stride);
        registers[EpiphanyRegisterName.dma0srcaddr] = new EpiphanyRegister32(EpiphanyRegisterName.dma0srcaddr);
        registers[EpiphanyRegisterName.dma0dstaddr] = new EpiphanyRegister32(EpiphanyRegisterName.dma0dstaddr);
        registers[EpiphanyRegisterName.dma0auto0] = new EpiphanyRegister32(EpiphanyRegisterName.dma0auto0);
        registers[EpiphanyRegisterName.dma0auto1] = new EpiphanyRegister32(EpiphanyRegisterName.dma0auto1);
        registers[EpiphanyRegisterName.dma0status] = new EpiphanyDMAStatusRegister32(EpiphanyRegisterName.dma0status);

        registers[EpiphanyRegisterName.dma1config] = new EpiphanyDMAConfigRegister32(EpiphanyRegisterName.dma1config);
        registers[EpiphanyRegisterName.dma1count] = new EpiphanyRegister32(EpiphanyRegisterName.dma1count);
        registers[EpiphanyRegisterName.dma1stride] = new EpiphanyRegister32(EpiphanyRegisterName.dma1stride);
        registers[EpiphanyRegisterName.dma1srcaddr] = new EpiphanyRegister32(EpiphanyRegisterName.dma1srcaddr);
        registers[EpiphanyRegisterName.dma1dstaddr] = new EpiphanyRegister32(EpiphanyRegisterName.dma1dstaddr);
        registers[EpiphanyRegisterName.dma1auto0] = new EpiphanyRegister32(EpiphanyRegisterName.dma1auto0);
        registers[EpiphanyRegisterName.dma1auto1] = new EpiphanyRegister32(EpiphanyRegisterName.dma1auto1);
        registers[EpiphanyRegisterName.dma1status] = new EpiphanyDMAStatusRegister32(EpiphanyRegisterName.dma1status);
    }
}

public abstract class EpiphanyRegister : Register
{
    private EpiphanyRegisterName _register;

    private this(EpiphanyRegisterName name) nothrow
    {
        super(to!string(name));

        _register = name;
    }

    private this(EpiphanyRegisterName name, RegisterMemory* memory) nothrow
    in
    {
        assert(memory);
    }
    body
    {
        super(to!string(name), memory);

        _register = name;
    }

    private this(EpiphanyRegisterName name, RegisterMemory memory) nothrow
    {
        super(to!string(name), memory);

        _register = name;
    }

    @property public final EpiphanyRegisterName register() pure nothrow
    {
        return _register;
    }
}

public final class EpiphanyRegister32 : EpiphanyRegister
{
    private this(EpiphanyRegisterName name) nothrow
    {
        super(name);
    }

    private this(EpiphanyRegisterName name, RegisterMemory* memory) nothrow
    in
    {
        assert(memory);
    }
    body
    {
        super(name, memory);
    }

    private this(EpiphanyRegisterName name, RegisterMemory memory) nothrow
    {
        super(name, memory);
    }

    public override EpiphanyRegister32 snapshot() nothrow
    {
        return new EpiphanyRegister32(register, *memory);
    }

    public override string stringize()
    {
        auto u32 = memory.u32[0];
        auto s32 = memory.s32[0];

        return format("0b%s / 0o%s / %s (%s) / 0x%s / %s",
                      toImpl!string(u32, 2),
                      toImpl!string(u32, 8),
                      u32,
                      s32,
                      toImpl!string(u32, 16),
                      memory.f32[0]);
    }
}

public final class EpiphanyTimerRegister32 : EpiphanyRegister
{
    public this(EpiphanyRegisterName name) nothrow
    in
    {
        assert(name == EpiphanyRegisterName.ctimer0 || name == EpiphanyRegisterName.ctimer1);
    }
    body
    {
        super(name);
    }

    public this(EpiphanyRegisterName name, RegisterMemory* memory) nothrow
    in
    {
        assert(name == EpiphanyRegisterName.ctimer0 || name == EpiphanyRegisterName.ctimer1);
        assert(memory);
    }
    body
    {
        super(name, memory);
    }

    public this(EpiphanyRegisterName name, RegisterMemory memory) nothrow
    in
    {
        assert(name == EpiphanyRegisterName.ctimer0 || name == EpiphanyRegisterName.ctimer1);
    }
    body
    {
        super(name, memory);
    }

    public override EpiphanyTimerRegister32 snapshot() nothrow
    {
        return new EpiphanyTimerRegister32(register, *memory);
    }

    public override string stringize()
    {
        return format("%s", memory.u32[0]);
    }
}

public final class EpiphanyConfigRegister32 : EpiphanyRegister
{
    public this() nothrow
    {
        super(EpiphanyRegisterName.config);
    }

    public this(RegisterMemory* memory) nothrow
    in
    {
        assert(memory);
    }
    body
    {
        super(EpiphanyRegisterName.config, memory);
    }

    public this(RegisterMemory memory) nothrow
    {
        super(EpiphanyRegisterName.config, memory);
    }

    public override EpiphanyConfigRegister32 snapshot() nothrow
    {
        return new EpiphanyConfigRegister32(*memory);
    }

    public override string stringize()
    {
        auto u32 = memory.u32[0];

        return format("0b%s (RMODE: %s IEN: %s OEN: %s UEN: %s CTIMER0CFG: %s%s%s%s CTIMER1CFG: %s%s%s%s ARITHMODE: %s%s%s)",
                      toImpl!string(u32, 2),
                      memory.bits.b0,
                      memory.bits.b1,
                      memory.bits.b2,
                      memory.bits.b3,
                      memory.bits.b4,
                      memory.bits.b5,
                      memory.bits.b6,
                      memory.bits.b7,
                      memory.bits.b8,
                      memory.bits.b9,
                      memory.bits.b10,
                      memory.bits.b11,
                      memory.bits.b17,
                      memory.bits.b18,
                      memory.bits.b19);
    }
}

public final class EpiphanyStatusRegister32 : EpiphanyRegister
{
    public this() nothrow
    {
        super(EpiphanyRegisterName.status);
    }

    public this(RegisterMemory* memory) nothrow
    in
    {
        assert(memory);
    }
    body
    {
        super(EpiphanyRegisterName.status, memory);
    }

    public this(RegisterMemory memory) nothrow
    {
        super(EpiphanyRegisterName.status, memory);
    }

    public override EpiphanyStatusRegister32 snapshot() nothrow
    {
        return new EpiphanyStatusRegister32(*memory);
    }

    public override string stringize()
    {
        auto u32 = memory.u32[0];

        return format("0b%s (ACTIVE: %s GID: %s: AZ: %s AN: %s AC: %s AV: %s BZ: %s BN: %s BV: %s AVS: %s BIS: %s BVS: %s BUS: %s EXCAUSE: %s%s%s)",
                      toImpl!string(u32, 2),
                      memory.bits.b0,
                      memory.bits.b1,
                      memory.bits.b4,
                      memory.bits.b5,
                      memory.bits.b6,
                      memory.bits.b7,
                      memory.bits.b8,
                      memory.bits.b9,
                      memory.bits.b10,
                      memory.bits.b12,
                      memory.bits.b13,
                      memory.bits.b14,
                      memory.bits.b15,
                      memory.bits.b16,
                      memory.bits.b17,
                      memory.bits.b18);
    }
}

public final class EpiphanyDMAConfigRegister32 : EpiphanyRegister
{
    public this(EpiphanyRegisterName name) nothrow
    in
    {
        assert(name == EpiphanyRegisterName.dma0config || name == EpiphanyRegisterName.dma1config);
    }
    body
    {
        super(name);
    }

    public this(EpiphanyRegisterName name, RegisterMemory* memory) nothrow
    in
    {
        assert(name == EpiphanyRegisterName.dma0config || name == EpiphanyRegisterName.dma1config);
        assert(memory);
    }
    body
    {
        super(name, memory);
    }

    public this(EpiphanyRegisterName name, RegisterMemory memory) nothrow
    in
    {
        assert(name == EpiphanyRegisterName.dma0config || name == EpiphanyRegisterName.dma1config);
    }
    body
    {
        super(name, memory);
    }

    public override EpiphanyDMAConfigRegister32 snapshot() nothrow
    {
        return new EpiphanyDMAConfigRegister32(register, *memory);
    }

    public override string stringize()
    {
        auto u32 = memory.u32[0];

        return format("0b%s (DMAEN: %s MASTER: %s CHAINMODE: %s STARTUP: %s IRQEN: %s DATASIZE: %s%s NEXT_PTR: %s%s%s%s%s%s%s%s%s%s%s%s%s%s%s)",
                      toImpl!string(u32, 2),
                      memory.bits.b0,
                      memory.bits.b1,
                      memory.bits.b2,
                      memory.bits.b3,
                      memory.bits.b4,
                      memory.bits.b5,
                      memory.bits.b6,
                      memory.bits.b16,
                      memory.bits.b17,
                      memory.bits.b18,
                      memory.bits.b19,
                      memory.bits.b20,
                      memory.bits.b21,
                      memory.bits.b22,
                      memory.bits.b23,
                      memory.bits.b24,
                      memory.bits.b25,
                      memory.bits.b26,
                      memory.bits.b27,
                      memory.bits.b28,
                      memory.bits.b29,
                      memory.bits.b30,
                      memory.bits.b31);
    }
}

public final class EpiphanyDMAStatusRegister32 : EpiphanyRegister
{
    public this(EpiphanyRegisterName name) nothrow
    in
    {
        assert(name == EpiphanyRegisterName.dma0status || name == EpiphanyRegisterName.dma1status);
    }
    body
    {
        super(name);
    }

    public this(EpiphanyRegisterName name, RegisterMemory* memory) nothrow
    in
    {
        assert(name == EpiphanyRegisterName.dma0status || name == EpiphanyRegisterName.dma1status);
        assert(memory);
    }
    body
    {
        super(name, memory);
    }

    public this(EpiphanyRegisterName name, RegisterMemory memory) nothrow
    in
    {
        assert(name == EpiphanyRegisterName.dma0status || name == EpiphanyRegisterName.dma1status);
    }
    body
    {
        super(name, memory);
    }

    public override EpiphanyDMAStatusRegister32 snapshot() nothrow
    {
        return new EpiphanyDMAStatusRegister32(register, *memory);
    }

    public override string stringize()
    {
        auto u32 = memory.u32[0];

        return format("0b%s (DMASTATE: %s%s%s%s CURR_PTR: %s%s%s%s%s%s%s%s%s%s%s%s%s%s%s)",
                      toImpl!string(u32, 2),
                      memory.bits.b0,
                      memory.bits.b1,
                      memory.bits.b2,
                      memory.bits.b3,
                      memory.bits.b16,
                      memory.bits.b17,
                      memory.bits.b18,
                      memory.bits.b19,
                      memory.bits.b20,
                      memory.bits.b21,
                      memory.bits.b22,
                      memory.bits.b23,
                      memory.bits.b24,
                      memory.bits.b25,
                      memory.bits.b26,
                      memory.bits.b27,
                      memory.bits.b28,
                      memory.bits.b29,
                      memory.bits.b30,
                      memory.bits.b31);
    }
}
