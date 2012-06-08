module darepl.mips.target;

import darepl.core.common,
       darepl.core.console,
       darepl.core.lexer,
       darepl.core.parser,
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

    protected override Parser createParser(Token[] tokens)
    {
        assert(false);
    }

    public override bool run(ubyte bits)
    {
        auto lp64 = bits == 64;

        return repl(bits);
    }

    protected override bool handleInstruction(Instruction instruction)
    {
        return true;
    }
}
