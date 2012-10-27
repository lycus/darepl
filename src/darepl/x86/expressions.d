module darepl.x86.expressions;

import darepl.core.expressions,
       darepl.x86.machine;

public abstract class X86Expression : Expression
{
    private this() pure nothrow
    {
    }
}

public final class X86RegisterExpression : X86Expression
{
    private X86Register _register;

    public this(X86Register register) pure nothrow
    {
        _register = register;
    }

    @property public X86Register register() pure nothrow
    {
        return _register;
    }
}
