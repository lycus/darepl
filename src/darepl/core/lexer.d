module darepl.core.lexer;

import std.ascii,
       std.conv,
       std.string,
       std.variant,
       darepl.core.console;

public enum LiteralType : ubyte
{
    int8,
    int16,
    int32,
    int64,
    float32,
    float64,
}

public union LiteralValue
{
    public byte value8s;
    public ubyte value8u;
    public short value16s;
    public ushort value16u;
    public int value32s;
    public uint value32u;
    public long value64s;
    public ulong value64u;
    public float value32f;
    public double value64f;
}

public final class Literal
{
    private LiteralType _type;
    private LiteralValue _value;

    public this(LiteralType type, LiteralValue value) pure nothrow
    {
        _type = type;
        _value = value;
    }

    @property public LiteralType type() pure nothrow
    {
        return _type;
    }

    @property public LiteralValue value() pure nothrow
    {
        return _value;
    }
}

public abstract class Token
{
}

public final class IdentifierToken : Token
{
    private string _value;

    pure nothrow invariant()
    {
        assert(_value);
    }

    public this(string value) pure nothrow
    in
    {
        assert(value);
    }
    body
    {
        _value = value;
    }

    @property public string value() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _value;
    }
}

public final class LiteralToken : Token
{
    private Literal _value;

    public this(Literal value) pure nothrow
    {
        _value = value;
    }

    @property public Literal value() pure nothrow
    {
        return _value;
    }
}

public enum DelimiterType : ubyte
{
    comma,
    dot,
    plus,
    minus,
    star,
    slash,
    percent,
    pipe,
    ampersand,
    tilde,
    caret,
    exclamation,
    leftArrow,
    rightArrow,
    openBracket,
    closeBracket,
    openParen,
    closeParen,
}

public final class DelimiterToken : Token
{
    private DelimiterType _type;
    private string _value;

    pure nothrow invariant()
    {
        assert(_value);
    }

    public this(DelimiterType type, string value) pure nothrow
    in
    {
        assert(value);
    }
    body
    {
        _type = type;
        _value = value;
    }

    @property public DelimiterType type() pure nothrow
    {
        return _type;
    }

    @property public string value() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _value;
    }
}

public class Lexer
{
    private string _string;
    private size_t _position;
    private char _current;

    pure nothrow invariant()
    {
        assert(_string);
    }

    public this(string value) pure nothrow
    in
    {
        assert(value);
    }
    body
    {
        _string = value;
    }

    protected final char current() pure nothrow
    {
        return _current;
    }

    protected final char next() pure nothrow
    {
        if (_position == _string.length)
            return char.init;

        return _string[_position];
    }

    protected final char moveNext() pure nothrow
    {
        if (_position == _string.length)
            return _current = char.init;

        return _current = _string[_position++];
    }

    protected final char peek(size_t offset) pure nothrow
    {
        if (!offset)
            return _current;

        auto idx = _position;

        for (size_t i = 0; i < offset; i++)
        {
            if (idx == _string.length)
                return char.init;

            auto chr = _string[idx++];

            if (i == offset - 1)
                return chr;
        }

        assert(false);
    }

    public final Token[] lex()
    out (result)
    {
        if (result)
            foreach (tok; result)
                assert(tok);
    }
    body
    {
        Token[] tokens;

        while (true)
        {
            if (auto token = lexNext())
                tokens ~= token;
            else
            {
                if (_position == _string.length)
                    break;

                write("Could not lex input completely.");
                return null;
            }
        }

        return tokens;
    }

    protected final Token lexNext()
    {
        char chr;

        while ((chr = moveNext()) != char.init)
        {
            if (isWhite(chr))
                continue;

            if (isAlpha(chr) || chr == '_')
                return lexIdentifier(chr);

            switch (chr)
            {
                case ',':
                    return new DelimiterToken(DelimiterType.comma, [chr]);
                case '.':
                    return new DelimiterToken(DelimiterType.dot, [chr]);
                case '+':
                    return new DelimiterToken(DelimiterType.plus, [chr]);
                case '-':
                    return new DelimiterToken(DelimiterType.minus, [chr]);
                case '*':
                    return new DelimiterToken(DelimiterType.star, [chr]);
                case '/':
                    return new DelimiterToken(DelimiterType.slash, [chr]);
                case '%':
                    return new DelimiterToken(DelimiterType.percent, [chr]);
                case '|':
                    return new DelimiterToken(DelimiterType.pipe, [chr]);
                case '&':
                    return new DelimiterToken(DelimiterType.ampersand, [chr]);
                case '~':
                    return new DelimiterToken(DelimiterType.tilde, [chr]);
                case '^':
                    return new DelimiterToken(DelimiterType.caret, [chr]);
                case '!':
                    return new DelimiterToken(DelimiterType.exclamation, [chr]);
                case '[':
                    return new DelimiterToken(DelimiterType.openBracket, [chr]);
                case ']':
                    return new DelimiterToken(DelimiterType.closeBracket, [chr]);
                case '(':
                    return new DelimiterToken(DelimiterType.openParen, [chr]);
                case ')':
                    return new DelimiterToken(DelimiterType.closeParen, [chr]);
                default:
                    break;
            }

            if (chr == '<' || chr == '>')
            {
                string arrow = [chr, next()];

                if (arrow == "<<")
                {
                    moveNext();
                    return new DelimiterToken(DelimiterType.leftArrow, arrow);
                }
                else if (arrow == ">>")
                {
                    moveNext();
                    return new DelimiterToken(DelimiterType.rightArrow, arrow);
                }
            }

            if (isDigit(chr))
                return lexLiteral(chr);

            auto tok = virtualLexNext(chr);

            if (tok)
                return tok;

            write("Expected any valid character.");
            return null;
        }

        return null;
    }

    protected final Token lexIdentifier(char chr) pure
    {
        string id = [chr];

        while (true)
        {
            auto idChr = next();

            if (!isAlpha(idChr) && !isDigit(idChr) && idChr != '_')
                break;

            id ~= moveNext();
        }

        return new IdentifierToken(toLower(id));
    }

    protected final Token lexLiteral(char chr)
    {
        enum LiteralRadix : ubyte
        {
            binary,
            octal,
            decimal,
            hexadecimal,
        }

        string literal;
        auto radix = LiteralRadix.decimal;

        if (chr == '0')
        {
            switch (next())
            {
                case 'b', 'B':
                    radix = LiteralRadix.binary;
                    break;
                case 'o', 'O':
                    radix = LiteralRadix.octal;
                    break;
                case 'x', 'X':
                    radix = LiteralRadix.hexadecimal;
                    break;
                default:
                    break;
            }

            if (radix != LiteralRadix.decimal)
                moveNext();
        }

        if (radix == LiteralRadix.decimal)
            literal = [chr];

        while (true)
        {
            auto litChr = next();

            if (!isHexDigit(litChr))
                break;

            literal ~= moveNext();
        }

        bool isFloat;

        if (next() == '.' && isDigit(peek(2)))
        {
            if (radix != LiteralRadix.decimal)
            {
                write("Floating point literal must be base 10.");
                return null;
            }

            isFloat = true;
            literal ~= moveNext();

            while (true)
            {
                auto decChr = next();

                if (!isDigit(decChr))
                    break;

                literal ~= moveNext();
            }

            auto eChr = next();

            if (eChr == 'e' || eChr == 'E')
            {
                literal ~= moveNext();

                auto sign = next();

                if (sign == '+' || sign == '-')
                    literal ~= moveNext();

                while (true)
                {
                    auto expChr = next();

                    if (!isDigit(expChr))
                        break;

                    literal ~= moveNext();
                }
            }
        }

        auto typeStr = [moveNext(), moveNext()];
        LiteralType type;

        if (typeStr == "i8")
            type = LiteralType.int8;
        else
        {
            switch (typeStr ~ moveNext())
            {
                case "i16":
                    type = LiteralType.int16;
                    break;
                case "i32":
                    type = LiteralType.int32;
                    break;
                case "i64":
                    type = LiteralType.int64;
                    break;
                case "f32":
                    type = LiteralType.float32;
                    break;
                case "f64":
                    type = LiteralType.float64;
                    break;
                default:
                    write("Expected i8, i16, i32, i64, f32, or f64.");
                    return null;
            }
        }

        uint radixNo;

        final switch (radix)
        {
            case LiteralRadix.binary:
                radixNo = 2;
                break;
            case LiteralRadix.octal:
                radixNo = 8;
                break;
            case LiteralRadix.decimal:
                radixNo = 10;
                break;
            case LiteralRadix.hexadecimal:
                radixNo = 16;
                break;
        }

        LiteralValue value;
        auto copy = literal;

        try
        {
            final switch (type)
            {
                case LiteralType.int8:
                    value.value8u = parse!ubyte(literal, radixNo);
                    break;
                case LiteralType.int16:
                    value.value16u = parse!ushort(literal, radixNo);
                    break;
                case LiteralType.int32:
                    value.value32u = parse!uint(literal, radixNo);
                    break;
                case LiteralType.int64:
                    value.value64u = parse!ulong(literal, radixNo);
                    break;
                case LiteralType.float32:
                    uint raw;

                    if (!isFloat)
                    {
                        raw = parse!uint(literal, radixNo);
                        value.value32f = *cast(float*)&raw;
                    }
                    else
                        value.value32f = parse!float(literal);
                    break;
                case LiteralType.float64:
                    ulong raw;

                    if (!isFloat)
                    {
                        raw = parse!ulong(literal, radixNo);
                        value.value64f = *cast(double*)&raw;
                    }
                    else
                        value.value64f = parse!double(literal);
                    break;
            }
        }
        catch (ConvException)
        {
            writef("Could not lex value %s as type %s.", copy, type);
            return null;
        }

        if (literal.length)
        {
            writef("Could not lex entire literal value.");
            return null;
        }

        return new LiteralToken(new Literal(type, value));
    }

    protected Token virtualLexNext(char chr) pure nothrow
    {
        return null;
    }
}
