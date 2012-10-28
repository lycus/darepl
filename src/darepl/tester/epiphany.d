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

    private void run(string opCode)(EpiphanyMachine machine,
                                    EpiphanyOperand operand1 = EpiphanyOperand.init,
                                    EpiphanyOperand operand2 = EpiphanyOperand.init,
                                    EpiphanyOperand operand3 = EpiphanyOperand.init)
    {
        assert(machine.dispatch(new EpiphanyInstruction(mixin("EpiphanyOpCodeName." ~ opCode), operand1, operand2, operand3)));
    }

    private EpiphanyOperand arg(T)(T argument)
    {
        return EpiphanyOperand(argument);
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

    mach.run!"mov"(arg(mach.reg!"r0"()),
                   arg(u8(100)));

    assert(mach.reg!"r0"().memory.u8[0] == 100);
    assert(mach.reg!"r0"().memory.u16[0] == 100);
    assert(mach.reg!"r0"().memory.u32[0] == 100);
}
