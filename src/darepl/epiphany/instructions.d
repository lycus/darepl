module darepl.epiphany.instructions;

import std.variant,
       darepl.core.expressions,
       darepl.core.lexer,
       darepl.core.parser,
       darepl.epiphany.enums,
       darepl.epiphany.expressions,
       darepl.epiphany.machine;

public alias Algebraic!(Expression, EpiphanyRegister, Literal) EpiphanyOperand;

public final class EpiphanyInstruction : Instruction
{
    private EpiphanyOpCodeName _opCode;
    private EpiphanyOperand _operand1;
    private EpiphanyOperand _operand2;
    private EpiphanyOperand _operand3;

    public this(EpiphanyOpCodeName opCode, EpiphanyOperand operand1, EpiphanyOperand operand2, EpiphanyOperand operand3)
    {
        _opCode = opCode;
        _operand1 = operand1;
        _operand2 = operand2;
        _operand3 = operand3;
    }

    @property public EpiphanyOpCodeName opCode() pure nothrow
    {
        return _opCode;
    }

    @property public EpiphanyOperand operand1() pure nothrow
    {
        return _operand1;
    }

    @property public EpiphanyOperand operand2() pure nothrow
    {
        return _operand2;
    }

    @property public EpiphanyOperand operand3() pure nothrow
    {
        return _operand3;
    }

    @property public override Object[] operands()
    {
        Object[] operands;

        if (_operand1.hasValue)
            operands ~= _operand1.get!Object();

        if (_operand2.hasValue)
            operands ~= _operand2.get!Object();

        if (_operand3.hasValue)
            operands ~= _operand3.get!Object();

        return operands;
    }
}
