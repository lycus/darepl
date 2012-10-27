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
