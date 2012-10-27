module darepl.core.parser;

import std.string,
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
}
