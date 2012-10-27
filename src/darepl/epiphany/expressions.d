module darepl.epiphany.expressions;

import darepl.core.expressions,
       darepl.epiphany.machine;

public abstract class EpiphanyExpression : Expression
{
    private this() pure nothrow
    {
    }
}

public final class EpiphanyRegisterExpression : EpiphanyExpression
{
    private EpiphanyRegister _register;

    public this(EpiphanyRegister register) pure nothrow
    {
        _register = register;
    }

    @property public EpiphanyRegister register() pure nothrow
    {
        return _register;
    }
}

public final class EpiphanyCommaExpression : EpiphanyExpression
{
    private Expression _first;
    private Expression _second;

    pure nothrow invariant()
    {
        assert(_first);
        assert(_second);
    }

    public this(Expression first, Expression second) pure nothrow
    in
    {
        assert(first);
        assert(second);
    }
    body
    {
        _first = first;
        _second = second;
    }

    @property public Expression first() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _first;
    }

    @property public Expression second() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _second;
    }
}
