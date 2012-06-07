module darepl.arm.target;

import darepl.core.common,
       darepl.core.console,
       darepl.core.lexer,
       darepl.core.target;

public final class ARMTarget : Target
{
    @property public override Architecture architecture()
    {
        return Architecture.arm;
    }

    @property public override ubyte[] supportedBits()
    {
        return [32, 64];
    }

    public override bool run(ubyte bits)
    {
        auto lp64 = bits == 64;

        return repl(bits);
    }

    protected override bool handleStatement(Token[] tokens)
    {
        return true;
    }
}
