module darepl.ia64.target;

import darepl.core.common,
       darepl.core.console,
       darepl.core.lexer,
       darepl.core.machine,
       darepl.core.parser,
       darepl.core.target;

public final class IA64Target : Target
{
    @property public override Architecture architecture() pure nothrow
    {
        return Architecture.ia64;
    }

    @property public override ubyte[] supportedBits() pure nothrow
    {
        return [64];
    }

    protected override Parser createParser(Machine machine, Token[] tokens) pure nothrow
    {
        assert(false);
    }

    public override bool run(ubyte bits, bool interactive)
    {
        return repl(null, bits);
    }

    protected override bool handleInstruction(Machine machine, Instruction instruction)
    {
        return true;
    }
}
