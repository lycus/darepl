module darepl.x86.parser;

import std.conv,
       darepl.core.lexer,
       darepl.core.parser,
       darepl.x86.enums,
       darepl.x86.instructions;

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

    public override X86Instruction parse()
    {
        import darepl.core.console;
        auto prefix = X86Prefix.none;

        if (auto ident = cast(IdentifierToken)next())
        {
            try
            {
                prefix = to!X86Prefix(ident.value);
                moveNext();
            }
            catch (ConvException)
            {
            }
        }

        if (done())
            error("Expected opcode mnemonic.");

        X86OpCode opCode;

        if (auto ident = cast(IdentifierToken)moveNext())
        {
            try
                opCode = to!X86OpCode(ident.value);
            catch (ConvException)
                error("Unknown opcode mnemonic: %s", ident.value);
        }
        else
            error("Expected opcode mnemonic.");

        X86Operand operand1;
        X86Operand operand2;
        X86Operand operand3;

        if (!done())
        {
            operand1 = parseOperand();

            if (!done())
            {
                auto comma1 = cast(DelimiterToken)moveNext();

                if (comma1 && comma1.type == DelimiterType.comma)
                {
                    operand2 = parseOperand();

                    if (!done())
                    {
                        auto comma2 = cast(DelimiterToken)moveNext();

                        if (comma2 && comma2.type == DelimiterType.comma)
                            operand3 = parseOperand();
                        else
                            error("Expected comma followed by operand.");
                    }
                }
                else
                    error("Expected comma followed by operand.");
            }
        }

        if (!done())
            error("Could not parse input completely.");

        return new X86Instruction(prefix, opCode, operand1, operand2, operand3);
    }

    private X86Operand parseOperand()
    out (result)
    {
        assert(result.hasValue);
    }
    body
    {
        auto tok = moveNext();

        if (auto ident = cast(IdentifierToken)tok)
        {
            try
                return X86Operand(to!X86Register(ident.value));
            catch (ConvException)
                error("Unknown register name: %s", ident.value);
        }
        else if (auto bracket = cast(DelimiterToken)tok)
        {
            if (bracket.type != DelimiterType.openBracket)
                error("Invalid opcode operand.");

            assert(false); // TODO: Parse expressions.
        }
        else if (auto literal = cast(LiteralToken)tok)
            return X86Operand(literal.value);

        error("Invalid opcode operand.");
        assert(false);
    }
}
