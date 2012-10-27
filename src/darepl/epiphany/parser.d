module darepl.epiphany.parser;

import std.conv,
       darepl.core.expressions,
       darepl.core.lexer,
       darepl.core.parser,
       darepl.epiphany.enums,
       darepl.epiphany.expressions,
       darepl.epiphany.instructions,
       darepl.epiphany.machine;

public final class EpiphanyParser : Parser
{
    private EpiphanyMachine _machine;

    pure nothrow invariant()
    {
        assert(_machine);
    }

    public this(EpiphanyMachine machine, Token[] tokens) pure nothrow
    in
    {
        assert(machine);
        assert(tokens);
    }
    body
    {
        super(tokens);

        _machine = machine;
    }

    public override EpiphanyInstruction parse()
    {
        EpiphanyOpCodeName opCode;

        if (auto ident = cast(IdentifierToken)moveNext())
        {
            try
                opCode = to!EpiphanyOpCodeName(ident.value);
            catch (ConvException)
                error("Unknown opcode mnemonic: %s", ident.value);
        }
        else
            error("Expected opcode mnemonic.");

        EpiphanyOperand operand1;
        EpiphanyOperand operand2;
        EpiphanyOperand operand3;

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

        return new EpiphanyInstruction(opCode, operand1, operand2, operand3);
    }

    private EpiphanyOperand parseOperand()
    out (result)
    {
        assert(result.hasValue);
    }
    body
    {
        auto tok = moveNext();

        if (auto ident = cast(IdentifierToken)tok)
        {
            EpiphanyRegisterName reg;

            try
                reg = to!EpiphanyRegisterName(ident.value);
            catch (ConvException)
                error("Unknown register name: %s", ident.value);

            return EpiphanyOperand(cast(EpiphanyRegister)_machine.registers[reg]);
        }
        else if (auto bracket = cast(DelimiterToken)tok)
        {
            if (bracket.type != DelimiterType.openBracket)
                error("Invalid opcode operand.");

            auto expr = parseExpression();
            auto closing = cast(DelimiterToken)moveNext();

            if (!closing || closing.type != DelimiterType.closeBracket)
                error("Expected closing bracket.");

            return EpiphanyOperand(expr);
        }
        else if (auto literal = cast(LiteralToken)tok)
            return EpiphanyOperand(literal.value);

        error("Invalid opcode operand.");
        assert(false);
    }

    protected override Expression parseSpecificExpression(Token token)
    {
        if (auto ident = cast(IdentifierToken)token)
        {
            EpiphanyRegisterName reg;

            try
                reg = to!EpiphanyRegisterName(ident.value);
            catch (ConvException)
                error("Unknown register name: %s", ident.value);

            return new EpiphanyRegisterExpression(cast(EpiphanyRegister)_machine.registers[reg]);
        }

        return null;
    }
}
