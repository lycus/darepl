module darepl.ia64.target;

import darepl.core.common,
       darepl.core.console,
       darepl.core.target;

public final class IA64Target : Target
{
    @property public override Architecture architecture()
    {
        return Architecture.ia64;
    }

    @property public override ubyte[] supportedBits()
    {
        return [64];
    }

    public override bool run(ubyte bits)
    {
        repl(bits);

        return true;
    }

    protected override bool handleStatement(string statement)
    {
        return true;
    }
}