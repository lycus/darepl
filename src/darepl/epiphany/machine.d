module darepl.epiphany.machine;

import std.conv,
       std.string,
       darepl.core.lexer,
       darepl.core.machine,
       darepl.core.parser,
       darepl.epiphany.enums,
       darepl.epiphany.expressions,
       darepl.epiphany.instructions,
       darepl.epiphany.target;

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
        registers[EpiphanyRegisterName.r0] = new EpiphanyRegister32(EpiphanyRegisterName.r0);
        registers[EpiphanyRegisterName.r1] = new EpiphanyRegister32(EpiphanyRegisterName.r1);
        registers[EpiphanyRegisterName.r2] = new EpiphanyRegister32(EpiphanyRegisterName.r2);
        registers[EpiphanyRegisterName.r3] = new EpiphanyRegister32(EpiphanyRegisterName.r3);
        registers[EpiphanyRegisterName.r4] = new EpiphanyRegister32(EpiphanyRegisterName.r4);
        registers[EpiphanyRegisterName.r5] = new EpiphanyRegister32(EpiphanyRegisterName.r5);
        registers[EpiphanyRegisterName.r6] = new EpiphanyRegister32(EpiphanyRegisterName.r6);
        registers[EpiphanyRegisterName.r7] = new EpiphanyRegister32(EpiphanyRegisterName.r7);
        registers[EpiphanyRegisterName.r8] = new EpiphanyRegister32(EpiphanyRegisterName.r8);
        registers[EpiphanyRegisterName.r9] = new EpiphanyRegister32(EpiphanyRegisterName.r9);
        registers[EpiphanyRegisterName.r10] = new EpiphanyRegister32(EpiphanyRegisterName.r10);
        registers[EpiphanyRegisterName.r11] = new EpiphanyRegister32(EpiphanyRegisterName.r11);
        registers[EpiphanyRegisterName.r12] = new EpiphanyRegister32(EpiphanyRegisterName.r12);
        registers[EpiphanyRegisterName.r13] = new EpiphanyRegister32(EpiphanyRegisterName.r13);
        registers[EpiphanyRegisterName.r14] = new EpiphanyRegister32(EpiphanyRegisterName.r14);
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
