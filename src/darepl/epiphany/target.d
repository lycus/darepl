module darepl.epiphany.target;

import darepl.core.common,
       darepl.core.console,
       darepl.core.lexer,
       darepl.core.machine,
       darepl.core.parser,
       darepl.core.target;

public final class EpiphanyTarget : Target
{
    @property public override Architecture architecture()
    {
        return Architecture.epiphany;
    }

    @property public override ubyte[] supportedBits()
    {
        return [32];
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
