module darepl.ia64.target;

import darepl.core.common,
       darepl.core.console,
       darepl.core.lexer,
       darepl.core.machine,
       darepl.core.parser,
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

    protected override Parser createParser(Machine machine, Token[] tokens)
    {
        assert(false);
    }

    public override bool run(ubyte bits)
    {
        return repl(null, bits);
    }

    protected override bool handleInstruction(Machine machine, Instruction instruction)
    {
        return true;
    }
}
