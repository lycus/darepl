module darepl.epiphany.target;

import darepl.core.common,
       darepl.core.console,
       darepl.core.lexer,
       darepl.core.machine,
       darepl.core.parser,
       darepl.core.target,
       darepl.epiphany.machine,
       darepl.epiphany.parser;

public final class EpiphanyTarget : Target
{
    @property public override Architecture architecture() pure nothrow
    {
        return Architecture.epiphany;
    }

    @property public override ubyte[] supportedBits() pure nothrow
    {
        return [32];
    }

    protected override Parser createParser(Machine machine, Token[] tokens) pure nothrow
    {
        return new EpiphanyParser(cast(EpiphanyMachine)machine, tokens);
    }

    public override bool run(ubyte bits)
    {
        return repl(new EpiphanyMachine(this, bits), bits);
    }

    protected override bool handleInstruction(Machine machine, Instruction instruction)
    {
        machine.dispatch(instruction);

        return true;
    }
}
