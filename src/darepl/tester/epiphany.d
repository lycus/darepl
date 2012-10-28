module darepl.tester.epiphany;

import darepl.core.lexer,
       darepl.epiphany.enums,
       darepl.epiphany.expressions,
       darepl.epiphany.instructions,
       darepl.epiphany.machine,
       darepl.epiphany.target;

version (unittest)
{
    private EpiphanyMachine machine()
    {
        return new EpiphanyMachine(new EpiphanyTarget(), 32, false);
    }

    private void run(string opCode, T ...)(EpiphanyMachine machine, T operands)
    {
        EpiphanyOperand op1;
        EpiphanyOperand op2;
        EpiphanyOperand op3;

        static if (operands.length >= 1)
            op1 = operands[0];

        static if (operands.length >= 2)
            op2 = operands[1];

        static if (operands.length >= 3)
            op3 = operands[2];

        assert(machine.dispatch(new EpiphanyInstruction(mixin("EpiphanyOpCodeName." ~ opCode), op1, op2, op3)));
    }

    private EpiphanyRegister reg(string register)(EpiphanyMachine machine)
    {
        return cast(EpiphanyRegister)machine.registers[mixin("EpiphanyRegisterName." ~ register)];
    }

    private Literal s8(byte value)
    {
        LiteralValue val;
        val.value8s = value;
        return new Literal(LiteralType.int8, val);
    }

    private Literal u8(ubyte value)
    {
        LiteralValue val;
        val.value8u = value;
        return new Literal(LiteralType.int8, val);
    }

    private Literal s16(short value)
    {
        LiteralValue val;
        val.value16s = value;
        return new Literal(LiteralType.int16, val);
    }

    private Literal u16(ushort value)
    {
        LiteralValue val;
        val.value16u = value;
        return new Literal(LiteralType.int16, val);
    }

    private Literal s32(int value)
    {
        LiteralValue val;
        val.value32s = value;
        return new Literal(LiteralType.int32, val);
    }

    private Literal u32(uint value)
    {
        LiteralValue val;
        val.value32u = value;
        return new Literal(LiteralType.int32, val);
    }
}

unittest
{
    auto mach = machine();

    mach.run!"mov"(mach.reg!"r0"(), u8(100));

    assert(mach.reg!"r0"().memory.u8[0] == 100);
    assert(mach.reg!"r0"().memory.u16[0] == 100);
    assert(mach.reg!"r0"().memory.u32[0] == 100);
}
