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

        return format("0b%s / 0o%s / %s (%s) / 0x%s",
                      toImpl!string(u32, 2),
                      toImpl!string(u32, 8),
                      u32,
                      s32,
                      toImpl!string(u32, 16));
    }
}
