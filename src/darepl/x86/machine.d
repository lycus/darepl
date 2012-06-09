module darepl.x86.machine;

import std.conv,
       std.string,
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
    public this(X86Target target, ubyte bits)
    in
    {
        assert(target);
    }
    body
    {
        super(target, bits);
    }

    protected override string createDispatchString(Instruction instruction)
    {
        auto insn = cast(X86Instruction)instruction;

        static string operandToString(Object operand)
        {
            if (auto expr = cast(X86Expression)operand)
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

    protected override void initializeRegisters(ubyte bits)
    {
        auto eax = registers[X86RegisterName.eax] = new X86Register32(X86RegisterName.eax, new RegisterMemory());
        auto ebx = registers[X86RegisterName.ebx] = new X86Register32(X86RegisterName.ebx, new RegisterMemory());
        auto ecx = registers[X86RegisterName.ecx] = new X86Register32(X86RegisterName.ecx, new RegisterMemory());
        auto edx = registers[X86RegisterName.edx] = new X86Register32(X86RegisterName.edx, new RegisterMemory());
        auto esi = registers[X86RegisterName.esi] = new X86Register32(X86RegisterName.esi, new RegisterMemory());
        auto edi = registers[X86RegisterName.edi] = new X86Register32(X86RegisterName.edi, new RegisterMemory());
        auto esp = registers[X86RegisterName.esp] = new X86Register32(X86RegisterName.esp, new RegisterMemory());
        auto ebp = registers[X86RegisterName.ebp] = new X86Register32(X86RegisterName.ebp, new RegisterMemory());

        if (bits == 64)
        {
            auto rax = registers[X86RegisterName.rax] = new X86Register64(X86RegisterName.rax, eax.memory);
            auto rbx = registers[X86RegisterName.rbx] = new X86Register64(X86RegisterName.rbx, ebx.memory);
            auto rcx = registers[X86RegisterName.rcx] = new X86Register64(X86RegisterName.rcx, ecx.memory);
            auto rdx = registers[X86RegisterName.rdx] = new X86Register64(X86RegisterName.rdx, edx.memory);
            auto rsi = registers[X86RegisterName.rsi] = new X86Register64(X86RegisterName.rsi, esi.memory);
            auto rdi = registers[X86RegisterName.rdi] = new X86Register64(X86RegisterName.rdi, edi.memory);
            auto rsp = registers[X86RegisterName.rsp] = new X86Register64(X86RegisterName.rsp, esp.memory);
            auto rbp = registers[X86RegisterName.rbp] = new X86Register64(X86RegisterName.rbp, ebp.memory);
        }
    }
}

public abstract class X86Register : Register
{
    private X86RegisterName _register;

    protected this(X86RegisterName name)
    {
        super(to!string(name));

        _register = name;
    }

    protected this(X86RegisterName name, RegisterMemory* memory)
    in
    {
        assert(memory);
    }
    body
    {
        super(to!string(name), memory);

        _register = name;
    }

    protected this(X86RegisterName name, RegisterMemory memory)
    {
        super(to!string(name), memory);

        _register = name;
    }

    @property public final X86RegisterName register()
    {
        return _register;
    }

    @property public abstract bool lp64();
}

public final class X86Register32 : X86Register
{
    public this(X86RegisterName name)
    {
        super(name);
    }

    public this(X86RegisterName name, RegisterMemory* memory)
    in
    {
        assert(memory);
    }
    body
    {
        super(name, memory);
    }

    public this(X86RegisterName name, RegisterMemory memory)
    {
        super(name, memory);
    }

    public override Register snapshot()
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

    @property public override bool lp64()
    {
        return false;
    }
}

public final class X86Register64 : X86Register
{
    protected this(X86RegisterName name)
    {
        super(name);
    }

    protected this(X86RegisterName name, RegisterMemory* memory)
    in
    {
        assert(memory);
    }
    body
    {
        super(name, memory);
    }

    public this(X86RegisterName name, RegisterMemory memory)
    {
        super(name, memory);
    }

    public override Register snapshot()
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

    @property public override bool lp64()
    {
        return true;
    }
}
