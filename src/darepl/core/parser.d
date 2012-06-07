module darepl.core.parser;

import darepl.core.lexer;

public abstract class Parser
{
    private Token[] _tokens;
    private size_t _position;

    invariant()
    {
        assert(_tokens);
    }

    protected this(Token[] tokens)
    in
    {
        assert(tokens);
    }
    body
    {
        _tokens = tokens;
    }

    protected final Token current()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _tokens[_position];
    }

    protected final Token previous()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _tokens[_position - 1];
    }

    protected final Token next()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _tokens[_position - 1];
    }

    protected final bool done()
    {
        return _position == _tokens.length;
    }

    protected final Token movePrevious()
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
        return _tokens[++_position];
    }

    protected final Token peek()
    {
        return _tokens[_position + 1];
    }

    protected final Token peekEnd()
    {
        if (_position == _tokens.length)
            return null;

        return _tokens[_position + 1];
    }

    public abstract Object parse();
}
