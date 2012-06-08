module darepl.x86.instructions;

import std.variant,
       darepl.core.lexer,
       darepl.x86.enums;

public abstract class X86Expression
{
    private this()
    {
    }
}

public final class X86LiteralExpression : X86Expression
{
    private Literal _literal;

    public this(Literal literal)
    {
        _literal = literal;
    }

    @property public Literal literal()
    {
        return _literal;
    }
}

public final class X86RegisterExpression : X86Expression
{
    private X86Register _register;

    public this(X86Register register)
    {
        _register = register;
    }

    @property public X86Register register()
    {
        return _register;
    }
}

public abstract class X86BinaryExpression : X86Expression
{
    private X86Expression _left;
    private X86Expression _right;

    invariant()
    {
        assert(_left);
        assert(_right);
    }

    public this(X86Expression left, X86Expression right)
    in
    {
        assert(left);
        assert(right);
    }
    body
    {
        _left = left;
        _right = right;
    }

    @property public X86Expression left()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _left;
    }

    @property public X86Expression right()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _right;
    }
}

public final class X86AddExpression : X86BinaryExpression
{
    public this(X86Expression left, X86Expression right)
    in
    {
        assert(left);
        assert(right);
    }
    body
    {
        super(left, right);
    }
}

public final class X86MultiplyExpression : X86BinaryExpression
{
    public this(X86Expression left, X86Expression right)
    in
    {
        assert(left);
        assert(right);
    }
    body
    {
        super(left, right);
    }
}

public alias Algebraic!(X86Expression, X86Register, Literal) X86Operand;

public final class X86Instruction
{
    private X86Prefix _prefix;
    private X86OpCode _opCode;
    private X86Operand _operand1;
    private X86Operand _operand2;
    private X86Operand _operand3;

    public this(X86Prefix prefix, X86OpCode opCode, X86Operand operand1, X86Operand operand2, X86Operand operand3)
    {
        _prefix = prefix;
        _opCode = opCode;
        _operand1 = operand1;
        _operand2 = operand2;
        _operand3 = operand3;
    }

    @property public X86Prefix prefix()
    {
        return _prefix;
    }

    @property public X86OpCode opCode()
    {
        return _opCode;
    }

    @property public X86Operand operand1()
    {
        return _operand1;
    }

    @property public X86Operand operand2()
    {
        return _operand2;
    }

    @property public X86Operand operand3()
    {
        return _operand3;
    }
}
