module darepl.ppc.target;

import darepl.core.common,
       darepl.core.console,
       darepl.core.lexer,
       darepl.core.target;

public final class PPCTarget : Target
{
    @property public override Architecture architecture()
    {
        return Architecture.ppc;
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
