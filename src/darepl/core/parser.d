module darepl.core.parser;

import std.string,
       darepl.core.expressions,
       darepl.core.lexer;

public class ParserException : Exception
{
    public this(string msg, string file = __FILE__, size_t line = __LINE__)
    in
    {
        assert(msg);
        assert(file);
        assert(line);
    }
    body
    {
        super(msg, file, line);
    }

    public this(string msg, Throwable next, string file = __FILE__, size_t line = __LINE__)
    in
    {
        assert(msg);
        assert(next);
        assert(file);
        assert(line);
    }
    body
    {
        super(msg, next, file, line);
    }
}

public abstract class Instruction
{
    @property public abstract Object[] operands();
}

public abstract class Parser
{
    private Token[] _tokens;
    private size_t _position;

    pure nothrow invariant()
    {
        assert(_tokens);
    }

    protected this(Token[] tokens) pure nothrow
    in
    {
        assert(tokens);
    }
    body
    {
        _tokens ~= null;
        _tokens ~= tokens;
    }

    protected final Token current() pure nothrow
    in
    {
        assert(_position);
    }
    out (result)
    {
        assert(result);
    }
    body
    {
        return _tokens[_position];
    }

    protected final Token previous() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _tokens[_position - 1];
    }

    protected final Token next() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _tokens[_position + 1];
    }

    protected final bool done() pure nothrow
    {
        return _position == _tokens.length - 1;
    }

    protected final Token movePrevious() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _tokens[--_position];
    }

    protected final Token moveNext()
    out (result)
    {
        assert(result);
    }
    body
    {
        if (done())
            error("Unexpected end of input.");

        return _tokens[++_position];
    }

    protected final void error(T ...)(T args)
    {
        throw new ParserException(format(args));
    }

    public abstract Instruction parse();

    protected final Expression parseExpression()
    out (result)
    {
        assert(result);
    }
    body
    {
        return parseOrExpression();
    }

    protected Expression parseSpecificExpression(Token token)
    in
    {
        assert(token);
    }
    body
    {
        return null;
    }

    protected final Expression parsePrimaryExpression()
    out (result)
    {
        assert(result);
    }
    body
    {
        auto tok = moveNext();

        if (auto literal = cast(LiteralToken)tok)
            return new LiteralExpression(literal.value);
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
        else if (auto expr = parseSpecificExpression(tok))
            return expr;

        error("Invalid expression operand.");
        assert(false);
    }

    protected final Expression parseUnaryExpression()
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
                    return new NegateExpression(parseUnaryExpression());
                case DelimiterType.plus:
                    moveNext();
                    return new PlusExpression(parseUnaryExpression());
                case DelimiterType.exclamation:
                    moveNext();
                    return new NotExpression(parseUnaryExpression());
                case DelimiterType.tilde:
                    moveNext();
                    return new ComplementExpression(parseUnaryExpression());
                default:
                    break;
            }
        }

        return parsePrimaryExpression();
    }

    protected final Expression parseOrExpression()
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
                return new OrExpression(e, parseExclusiveOrExpression());
            }
        }

        return e;
    }

    protected final Expression parseExclusiveOrExpression()
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
                return new ExclusiveOrExpression(e, parseAndExpression());
            }
        }

        return e;
    }

    protected final Expression parseAndExpression()
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
                return new AndExpression(e, parseShiftExpression());
            }
        }

        return e;
    }

    protected final Expression parseShiftExpression()
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
                    return new LeftShiftExpression(e, parseAddExpression());
                case DelimiterType.rightArrow:
                    moveNext();
                    return new RightShiftExpression(e, parseAddExpression());
                default:
                    break;
            }
        }

        return e;
    }

    protected final Expression parseAddExpression()
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
                    return new AddExpression(e, parseMultiplyExpression());
                case DelimiterType.minus:
                    moveNext();
                    return new SubtractExpression(e, parseMultiplyExpression());
                default:
                    break;
            }
        }

        return e;
    }

    protected final Expression parseMultiplyExpression()
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
                    return new MultiplyExpression(e, parseUnaryExpression());
                case DelimiterType.slash:
                    moveNext();
                    return new DivideExpression(e, parseUnaryExpression());
                case DelimiterType.percent:
                    moveNext();
                    return new ModuloExpression(e, parseUnaryExpression());
                default:
                    break;
            }
        }

        return e;
    }
}
