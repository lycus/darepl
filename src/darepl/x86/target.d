module darepl.x86.target;

import darepl.core.common,
       darepl.core.console,
       darepl.core.lexer,
       darepl.core.machine,
       darepl.core.parser,
       darepl.core.target,
       darepl.x86.machine,
       darepl.x86.parser;

public final class X86Target : Target
{
    @property public override Architecture architecture()
    {
        return Architecture.x86;
    }

    @property public override ubyte[] supportedBits()
    {
        return [32, 64];
    }

    protected override X86Parser createParser(Machine machine, Token[] tokens)
    {
        return new X86Parser(cast(X86Machine)machine, tokens);
    }

    public override bool run(ubyte bits)
    {
        return repl(new X86Machine(this, bits), bits);
    }

    protected override bool handleInstruction(Machine machine, Instruction instruction)
    {
        machine.dispatch(instruction);

        return true;
    }
}
