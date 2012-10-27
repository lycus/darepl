module darepl.x86.instructions;

import std.variant,
       darepl.core.expressions,
       darepl.core.lexer,
       darepl.core.parser,
       darepl.x86.enums,
       darepl.x86.expressions,
       darepl.x86.machine;

public alias Algebraic!(Expression, X86Register, Literal) X86Operand;

public final class X86Instruction : Instruction
{
    private X86PrefixName _prefix;
    private X86OpCodeName _opCode;
    private X86Operand _operand1;
    private X86Operand _operand2;
    private X86Operand _operand3;

    public this(X86PrefixName prefix, X86OpCodeName opCode, X86Operand operand1, X86Operand operand2, X86Operand operand3) nothrow
    {
        _prefix = prefix;
        _opCode = opCode;
        _operand1 = operand1;
        _operand2 = operand2;
        _operand3 = operand3;
    }

    @property public X86PrefixName prefix() pure nothrow
    {
        return _prefix;
    }

    @property public X86OpCodeName opCode() pure nothrow
    {
        return _opCode;
    }

    @property public X86Operand operand1() pure nothrow
    {
        return _operand1;
    }

    @property public X86Operand operand2() pure nothrow
    {
        return _operand2;
    }

    @property public X86Operand operand3() pure nothrow
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
