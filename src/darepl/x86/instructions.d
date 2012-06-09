module darepl.x86.instructions;

import std.variant,
       darepl.core.lexer,
       darepl.core.parser,
       darepl.x86.enums,
       darepl.x86.machine;

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

public abstract class X86UnaryExpression : X86Expression
{
    private X86Expression _expression;

    invariant()
    {
        assert(_expression);
    }

    public this(X86Expression expression)
    in
    {
        assert(expression);
    }
    body
    {
        _expression = expression;
    }

    @property public X86Expression expression()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _expression;
    }
}

public final class X86NegateExpression : X86UnaryExpression
{
    public this(X86Expression expression)
    in
    {
        assert(expression);
    }
    body
    {
        super(expression);
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

public final class X86Instruction : Instruction
{
    private X86PrefixName _prefix;
    private X86OpCodeName _opCode;
    private X86Operand _operand1;
    private X86Operand _operand2;
    private X86Operand _operand3;

    public this(X86PrefixName prefix, X86OpCodeName opCode, X86Operand operand1, X86Operand operand2, X86Operand operand3)
    {
        _prefix = prefix;
        _opCode = opCode;
        _operand1 = operand1;
        _operand2 = operand2;
        _operand3 = operand3;
    }

    @property public X86PrefixName prefix()
    {
        return _prefix;
    }

    @property public X86OpCodeName opCode()
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
