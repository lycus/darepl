module darepl.mips.target;

import darepl.core.common,
       darepl.core.console,
       darepl.core.target;

public final class MIPSTarget : Target
{
    @property public override Architecture architecture()
    {
        return Architecture.mips;
    }

    @property public override ubyte[] supportedBits()
    {
        return [32, 64];
    }

    public override bool run(ubyte bits)
    {
        auto lp64 = bits == 64;

        repl(bits);

        return true;
    }

    protected override bool handleStatement(string statement)
    {
        return true;
    }
}