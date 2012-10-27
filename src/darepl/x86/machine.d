module darepl.x86.machine;

import std.conv,
       std.string,
       darepl.core.expressions,
       darepl.core.lexer,
       darepl.core.machine,
       darepl.core.parser,
       darepl.x86.enums,
       darepl.x86.instructions,
       darepl.x86.target,
       darepl.x86.emulation.arithmetic,
       darepl.x86.emulation.misc;

public final class X86Machine : Machine
{
    private X86RegisterFlags32 _eflags;
    private X86RegisterFlags64 _rflags;
    private X86RegisterFloatFlags32 _mxcsr;

    public this(X86Target target, ubyte bits) pure nothrow
    in
    {
        assert(target);
        assert(bits == 32 || bits == 64);
    }
    body
    {
        super(target, bits);
    }

    @property public X86RegisterFlags32 eflags() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _eflags;
    }

    @property public X86RegisterFlags64 rflags() pure nothrow
    out (result)
    {
        assert(bits == 64 ? !!result : !result);
    }
    body
    {
        return _rflags;
    }

    @property public X86RegisterFloatFlags32 mxcsr() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _mxcsr;
    }

    protected override string createDispatchString(Instruction instruction)
    {
        auto insn = cast(X86Instruction)instruction;

        static string operandToString(Object operand)
        {
            if (auto expr = cast(Expression)operand)
                return "mem";
            else if (auto reg = cast(X86Register)operand)
                return reg.lp64 ? "reg64" : "reg32";
            else
                return to!string((cast(Literal)operand).type);
        }

        string name;

        if (insn.prefix != X86PrefixName.none && insn.prefix != X86PrefixName.lock)
            name ~= to!string(insn.prefix) ~ '_';

        name ~= to!string(insn.opCode);

        foreach (operand; insn.operands)
            if (operand)
                name ~= '_' ~ operandToString(operand);

        return name;
    }

    protected override void initializeRegisters(ubyte bits) pure nothrow
    {
        registers[X86RegisterName.eflags] = _eflags = new X86RegisterFlags32();

        auto eax = registers[X86RegisterName.eax] = new X86Register32(X86RegisterName.eax);
        auto ebx = registers[X86RegisterName.ebx] = new X86Register32(X86RegisterName.ebx);
        auto ecx = registers[X86RegisterName.ecx] = new X86Register32(X86RegisterName.ecx);
        auto edx = registers[X86RegisterName.edx] = new X86Register32(X86RegisterName.edx);
        auto esi = registers[X86RegisterName.esi] = new X86Register32(X86RegisterName.esi);
        auto edi = registers[X86RegisterName.edi] = new X86Register32(X86RegisterName.edi);
        auto esp = registers[X86RegisterName.esp] = new X86Register32(X86RegisterName.esp);
        auto ebp = registers[X86RegisterName.ebp] = new X86Register32(X86RegisterName.ebp);

        if (bits == 64)
        {
            registers[X86RegisterName.rflags] = _rflags = new X86RegisterFlags64(_eflags.memory);

            auto rax = registers[X86RegisterName.rax] = new X86Register64(X86RegisterName.rax, eax.memory);
            auto rbx = registers[X86RegisterName.rbx] = new X86Register64(X86RegisterName.rbx, ebx.memory);
            auto rcx = registers[X86RegisterName.rcx] = new X86Register64(X86RegisterName.rcx, ecx.memory);
            auto rdx = registers[X86RegisterName.rdx] = new X86Register64(X86RegisterName.rdx, edx.memory);
            auto rsi = registers[X86RegisterName.rsi] = new X86Register64(X86RegisterName.rsi, esi.memory);
            auto rdi = registers[X86RegisterName.rdi] = new X86Register64(X86RegisterName.rdi, edi.memory);
            auto rsp = registers[X86RegisterName.rsp] = new X86Register64(X86RegisterName.rsp, esp.memory);
            auto rbp = registers[X86RegisterName.rbp] = new X86Register64(X86RegisterName.rbp, ebp.memory);

            auto r8 = registers[X86RegisterName.r8] = new X86Register64(X86RegisterName.r8);
            auto r9 = registers[X86RegisterName.r9] = new X86Register64(X86RegisterName.r9);
            auto r10 = registers[X86RegisterName.r10] = new X86Register64(X86RegisterName.r10);
            auto r11 = registers[X86RegisterName.r11] = new X86Register64(X86RegisterName.r11);
            auto r12 = registers[X86RegisterName.r12] = new X86Register64(X86RegisterName.r12);
            auto r13 = registers[X86RegisterName.r13] = new X86Register64(X86RegisterName.r13);
            auto r14 = registers[X86RegisterName.r14] = new X86Register64(X86RegisterName.r14);
            auto r15 = registers[X86RegisterName.r15] = new X86Register64(X86RegisterName.r15);
        }

        registers[X86RegisterName.mxcsr] = _mxcsr = new X86RegisterFloatFlags32();
    }
}

public abstract class X86Register : Register
{
    private X86RegisterName _register;

    protected this(X86RegisterName name) nothrow
    {
        super(to!string(name));

        _register = name;
    }

    protected this(X86RegisterName name, RegisterMemory* memory) nothrow
    in
    {
        assert(memory);
    }
    body
    {
        super(to!string(name), memory);

        _register = name;
    }

    protected this(X86RegisterName name, RegisterMemory memory) nothrow
    {
        super(to!string(name), memory);

        _register = name;
    }

    @property public final X86RegisterName register() pure nothrow
    {
        return _register;
    }

    @property public abstract bool lp64() pure nothrow;
}

public final class X86Register32 : X86Register
{
    public this(X86RegisterName name) nothrow
    {
        super(name);
    }

    public this(X86RegisterName name, RegisterMemory* memory) nothrow
    in
    {
        assert(memory);
    }
    body
    {
        super(name, memory);
    }

    public this(X86RegisterName name, RegisterMemory memory) nothrow
    {
        super(name, memory);
    }

    public override X86Register32 snapshot() nothrow
    {
        return new X86Register32(register, *memory);
    }

    public override string stringize()
    {
        auto u32 = memory.u32[0];
        auto s32 = memory.s32[0];

        return format("0b%s / 0o%s / %s (%s) / 0x%s",
                      toImpl!string(u32, 2),
                      toImpl!string(u32, 8),
                      u32,
                      s32,
                      toImpl!string(u32, 16));
    }

    @property public override bool lp64() pure nothrow
    {
        return false;
    }
}

public final class X86RegisterFlags32 : X86Register
{
    public this() nothrow
    {
        super(X86RegisterName.eflags);
    }

    public this(RegisterMemory* memory) nothrow
    in
    {
        assert(memory);
    }
    body
    {
        super(X86RegisterName.eflags, memory);
    }

    public this(RegisterMemory memory) nothrow
    {
        super(X86RegisterName.eflags, memory);
    }

    public override X86RegisterFlags32 snapshot() pure nothrow
    {
        return new X86RegisterFlags32(*memory);
    }

    public override string stringize()
    {
        auto u32 = memory.u32[0];

        return format("0b%s (CF: %s PF: %s AF: %s ZF: %s SF: %s TF: %s IF: %s DF: %s OF: %s IOPL: %s NT: %s RF: %s VM: %s AC: %s VIF: %s VIP: %s ID: %s)",
                      toImpl!string(u32, 2),
                      memory.bits.b0,
                      memory.bits.b2,
                      memory.bits.b4,
                      memory.bits.b6,
                      memory.bits.b7,
                      memory.bits.b8,
                      memory.bits.b9,
                      memory.bits.b10,
                      memory.bits.b11,
                      memory.bits.b12,
                      memory.bits.b13,
                      memory.bits.b14,
                      memory.bits.b16,
                      memory.bits.b17,
                      memory.bits.b18,
                      memory.bits.b19,
                      memory.bits.b20,
                      memory.bits.b21);
    }

    @property public override bool lp64() pure nothrow
    {
        return false;
    }
}

public final class X86Register64 : X86Register
{
    protected this(X86RegisterName name) nothrow
    {
        super(name);
    }

    protected this(X86RegisterName name, RegisterMemory* memory) nothrow
    in
    {
        assert(memory);
    }
    body
    {
        super(name, memory);
    }

    public this(X86RegisterName name, RegisterMemory memory) nothrow
    {
        super(name, memory);
    }

    public override X86Register64 snapshot() pure nothrow
    {
        return new X86Register64(register, *memory);
    }

    public override string stringize()
    {
        auto u64 = memory.u64[0];
        auto s64 = memory.s64[0];

        return format("0b%s / 0o%s / %s (%s) / 0x%s",
                      toImpl!string(u64, 2),
                      toImpl!string(u64, 8),
                      u64,
                      s64,
                      toImpl!string(u64, 16));
    }

    @property public override bool lp64() pure nothrow
    {
        return true;
    }
}

public final class X86RegisterFlags64 : X86Register
{
    public this() nothrow
    {
        super(X86RegisterName.rflags);
    }

    public this(RegisterMemory* memory) nothrow
    in
    {
        assert(memory);
    }
    body
    {
        super(X86RegisterName.rflags, memory);
    }

    public this(RegisterMemory memory) nothrow
    {
        super(X86RegisterName.rflags, memory);
    }

    public override X86RegisterFlags64 snapshot() pure nothrow
    {
        return new X86RegisterFlags64(*memory);
    }

    public override string stringize()
    {
        auto u64 = memory.u64[0];

        return format("0b%s (CF: %s PF: %s AF: %s ZF: %s SF: %s TF: %s IF: %s DF: %s OF: %s IOPL: %s NT: %s RF: %s VM: %s AC: %s VIF: %s VIP: %s ID: %s)",
                      toImpl!string(u64, 2),
                      memory.bits.b0,
                      memory.bits.b2,
                      memory.bits.b4,
                      memory.bits.b6,
                      memory.bits.b7,
                      memory.bits.b8,
                      memory.bits.b9,
                      memory.bits.b10,
                      memory.bits.b11,
                      memory.bits.b12,
                      memory.bits.b13,
                      memory.bits.b14,
                      memory.bits.b16,
                      memory.bits.b17,
                      memory.bits.b18,
                      memory.bits.b19,
                      memory.bits.b20,
                      memory.bits.b21);
    }

    @property public override bool lp64() pure nothrow
    {
        return true;
    }
}

public final class X86RegisterFloatFlags32 : X86Register
{
    public this() nothrow
    {
        super(X86RegisterName.mxcsr);
    }

    public this(RegisterMemory* memory) nothrow
    in
    {
        assert(memory);
    }
    body
    {
        super(X86RegisterName.mxcsr, memory);
    }

    public this(RegisterMemory memory) nothrow
    {
        super(X86RegisterName.mxcsr, memory);
    }

    public override X86RegisterFloatFlags32 snapshot() pure nothrow
    {
        return new X86RegisterFloatFlags32(*memory);
    }

    public override string stringize()
    {
        auto u32 = memory.u32[0];

        return format("0b%s (IE: %s DE: %s ZE: %s OE: %s UE: %s PE: %s DAZ: %s IM: %s DM: %s ZM: %s OM: %s UM: %s PM: %s RC1: %s RC2: %s FZ: %s)",
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
                      memory.bits.b12,
                      memory.bits.b13,
                      memory.bits.b14,
                      memory.bits.b15);
    }

    @property public override bool lp64() pure nothrow
    {
        return false;
    }
}
