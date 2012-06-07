module darepl.x86.parser;

import darepl.core.lexer,
       darepl.core.parser;

public final class X86Parser : Parser
{
    public this(Token[] tokens)
    in
    {
        assert(tokens);
    }
    body
    {
        super(tokens);
    }

    public override Object parse()
    {
        return null;
    }
}
