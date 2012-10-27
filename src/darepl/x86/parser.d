module darepl.x86.parser;

import std.conv,
       darepl.core.lexer,
       darepl.core.parser,
       darepl.x86.enums,
       darepl.x86.instructions,
       darepl.x86.machine;

public final class X86Parser : Parser
{
    private X86Machine _machine;

    pure nothrow invariant()
    {
        assert(_machine);
    }

    public this(X86Machine machine, Token[] tokens) pure nothrow
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

    public override X86Instruction parse()
    {
        auto prefix = X86PrefixName.none;

        if (auto ident = cast(IdentifierToken)next())
        {
            try
            {
                prefix = to!X86PrefixName(ident.value);
                moveNext();
            }
            catch (ConvException)
            {
            }
        }

        X86OpCodeName opCode;

        if (auto ident = cast(IdentifierToken)moveNext())
        {
            try
                opCode = to!X86OpCodeName(ident.value);
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
            X86RegisterName reg;

            try
                reg = to!X86RegisterName(ident.value);
            catch (ConvException)
                error("Unknown register name: %s", ident.value);

            switch (reg)
            {
                case X86RegisterName.eflags:
                case X86RegisterName.rflags:
                case X86RegisterName.mxcsr:
                case X86RegisterName.eip:
                case X86RegisterName.rip:
                    error("Cannot operate directly on register: %s", reg);
                    break;
                default:
                    break;
            }

            return X86Operand(cast(X86Register)_machine.registers[reg]);
        }
        else if (auto bracket = cast(DelimiterToken)tok)
        {
            if (bracket.type != DelimiterType.openBracket)
                error("Invalid opcode operand.");

            auto expr = parseExpression();
            auto closing = cast(DelimiterToken)moveNext();

            if (!closing || closing.type != DelimiterType.closeBracket)
                error("Expected closing bracket.");

            return X86Operand(expr);
        }
        else if (auto literal = cast(LiteralToken)tok)
            return X86Operand(literal.value);

        error("Invalid opcode operand.");
        assert(false);
    }

    private X86Expression parseExpression()
    out (result)
    {
        assert(result);
    }
    body
    {
        return parseOrExpression();
    }

    private X86Expression parsePrimaryExpression()
    out (result)
    {
        assert(result);
    }
    body
    {
        auto tok = moveNext();

        if (auto ident = cast(IdentifierToken)tok)
        {
            X86RegisterName reg;

            try
                reg = to!X86RegisterName(ident.value);
            catch (ConvException)
                error("Unknown register name: %s", ident.value);

            switch (reg)
            {
                case X86RegisterName.eflags:
                case X86RegisterName.rflags:
                case X86RegisterName.mxcsr:
                case X86RegisterName.eip:
                case X86RegisterName.rip:
                    error("Cannot operate directly on register: %s", reg);
                    break;
                default:
                    break;
            }

            return new X86RegisterExpression(cast(X86Register)_machine.registers[reg]);
        }
        else if (auto literal = cast(LiteralToken)tok)
            return new X86LiteralExpression(literal.value);
        else if (auto paren = cast(DelimiterToken)tok)
        {
            if (paren.type == DelimiterType.openParen)
            {
                auto expr = parseExpression();
                auto closing = cast(DelimiterToken)moveNext();

                if (!closing || closing.type != DelimiterType.closeParen)
                    error("Expected closing parenthesis.");

                return expr;
            }
        }

        error("Invalid expression operand.");
        assert(false);
    }

    private X86Expression parseUnaryExpression()
    out (result)
    {
        assert(result);
    }
    body
    {
        if (auto tok = cast(DelimiterToken)next())
        {
            switch (tok.type)
            {
                case DelimiterType.minus:
                    moveNext();
                    return new X86NegateExpression(parseUnaryExpression());
                case DelimiterType.plus:
                    moveNext();
                    return new X86PlusExpression(parseUnaryExpression());
                case DelimiterType.exclamation:
                    moveNext();
                    return new X86NotExpression(parseUnaryExpression());
                case DelimiterType.tilde:
                    moveNext();
                    return new X86ComplementExpression(parseUnaryExpression());
                default:
                    break;
            }
        }

        return parsePrimaryExpression();
    }

    private X86Expression parseOrExpression()
    out (result)
    {
        assert(result);
    }
    body
    {
        auto e = parseExclusiveOrExpression();

        if (auto tok = cast(DelimiterToken)next())
        {
            if (tok.type == DelimiterType.pipe)
            {
                moveNext();
                return new X86OrExpression(e, parseExclusiveOrExpression());
            }
        }

        return e;
    }

    private X86Expression parseExclusiveOrExpression()
    out (result)
    {
        assert(result);
    }
    body
    {
        auto e = parseAndExpression();

        if (auto tok = cast(DelimiterToken)next())
        {
            if (tok.type == DelimiterType.caret)
            {
                moveNext();
                return new X86ExclusiveOrExpression(e, parseAndExpression());
            }
        }

        return e;
    }

    private X86Expression parseAndExpression()
    out (result)
    {
        assert(result);
    }
    body
    {
        auto e = parseShiftExpression();

        if (auto tok = cast(DelimiterToken)next())
        {
            if (tok.type == DelimiterType.ampersand)
            {
                moveNext();
                return new X86AndExpression(e, parseShiftExpression());
            }
        }

        return e;
    }

    private X86Expression parseShiftExpression()
    out (result)
    {
        assert(result);
    }
    body
    {
        auto e = parseAddExpression();

        if (auto tok = cast(DelimiterToken)next())
        {
            switch (tok.type)
            {
                case DelimiterType.leftArrow:
                    moveNext();
                    return new X86LeftShiftExpression(e, parseAddExpression());
                case DelimiterType.rightArrow:
                    moveNext();
                    return new X86RightShiftExpression(e, parseAddExpression());
                default:
                    break;
            }
        }

        return e;
    }

    private X86Expression parseAddExpression()
    out (result)
    {
        assert(result);
    }
    body
    {
        auto e = parseMultiplyExpression();

        if (auto tok = cast(DelimiterToken)next())
        {
            switch (tok.type)
            {
                case DelimiterType.plus:
                    moveNext();
                    return new X86AddExpression(e, parseMultiplyExpression());
                case DelimiterType.minus:
                    moveNext();
                    return new X86SubtractExpression(e, parseMultiplyExpression());
                default:
                    break;
            }
        }

        return e;
    }

    private X86Expression parseMultiplyExpression()
    out (result)
    {
        assert(result);
    }
    body
    {
        auto e = parseUnaryExpression();

        if (auto tok = cast(DelimiterToken)next())
        {
            switch (tok.type)
            {
                case DelimiterType.star:
                    moveNext();
                    return new X86MultiplyExpression(e, parseUnaryExpression());
                case DelimiterType.slash:
                    moveNext();
                    return new X86DivideExpression(e, parseUnaryExpression());
                case DelimiterType.percent:
                    moveNext();
                    return new X86ModuloExpression(e, parseUnaryExpression());
                default:
                    break;
            }
        }

        return e;
    }
}
