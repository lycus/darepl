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
        return parseAddExpression();
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
        if (auto neg = cast(DelimiterToken)next())
        {
            if (neg.type == DelimiterType.minus)
            {
                moveNext();

                return new X86NegateExpression(parseUnaryExpression());
            }
        }

        return parsePrimaryExpression();
    }

    private X86Expression parseAddExpression()
    out (result)
    {
        assert(result);
    }
    body
    {
        auto e = parseMultiplyExpression();

        if (auto add = cast(DelimiterToken)next())
        {
            if (add.type != DelimiterType.plus)
                return e;

            moveNext();
        }

        return new X86AddExpression(e, parseMultiplyExpression());
    }

    private X86Expression parseMultiplyExpression()
    out (result)
    {
        assert(result);
    }
    body
    {
        auto e = parseUnaryExpression();

        if (auto mul = cast(DelimiterToken)next())
        {
            if (mul.type != DelimiterType.star)
                return e;

            moveNext();
        }

        return new X86MultiplyExpression(e, parseUnaryExpression());
    }
}
