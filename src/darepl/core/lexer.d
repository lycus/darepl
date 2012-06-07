module darepl.core.lexer;

import std.ascii,
       std.conv,
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

public union IntLiteralValue
{
    public byte value8s;
    public ubyte value8u;
    public short value16s;
    public ushort value16u;
    public int value32s;
    public uint value32u;
    public long value64s;
    public ulong value64u;
}

public union FloatLiteralValue
{
    public float value32;
    public double value64;
}

public union LiteralValue
{
    public IntLiteralValue intValue;
    public FloatLiteralValue floatValue;
}

public struct Literal
{
    private LiteralType _type;
    private LiteralValue _value;

    @disable this();

    public this(LiteralType type, LiteralValue value)
    {
        _type = type;
        _value = value;
    }

    @property public LiteralType type()
    {
        return _type;
    }

    @property public LiteralValue value()
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

    invariant()
    {
        assert(_value);
    }

    public this(string value)
    in
    {
        assert(value);
    }
    body
    {
        _value = value;
    }

    @property public string value()
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

    public this(Literal value)
    {
        _value = value;
    }

    @property public Literal value()
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
    openBracket,
    closeBracket,
}

public final class DelimiterToken : Token
{
    private DelimiterType _type;
    private string _value;

    invariant()
    {
        assert(_value);
    }

    public this(DelimiterType type, string value)
    in
    {
        assert(value);
    }
    body
    {
        _type = type;
        _value = value;
    }

    @property public DelimiterType type()
    {
        return _type;
    }

    @property public string value()
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

    invariant()
    {
        assert(_string);
    }

    public this(string value)
    in
    {
        assert(value);
    }
    body
    {
        _string = value;
    }

    protected final char current()
    {
        return _current;
    }

    protected final char next()
    {
        if (_position == _string.length)
            return char.init;

        return _string[_position];
    }

    protected final char moveNext()
    {
        if (_position == _string.length)
            return _current = char.init;

        return _current = _string[_position++];
    }

    protected final char peek(size_t offset)
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
                    return tokens;

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
                case '[':
                    return new DelimiterToken(DelimiterType.openBracket, [chr]);
                case ']':
                    return new DelimiterToken(DelimiterType.closeBracket, [chr]);
                default:
                    break;
            }

            if (isDigit(chr) || chr == '+' || chr == '-')
                return lexLiteral(chr);

            auto tok = virtualLexNext(chr);

            if (tok)
                return tok;

            write("Expected any valid character.");
            return null;
        }

        return null;
    }

    protected final Token lexIdentifier(char chr)
    {
        string id = [chr];

        while (true)
        {
            auto idChr = next();

            if (!isAlpha(idChr) && !isDigit(idChr) && idChr != '_')
                break;

            id ~= moveNext();
        }

        return new IdentifierToken(id);
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
        bool isNegative;

        if (chr == '+')
            chr = moveNext();
        else if (chr == '-')
        {
            chr = moveNext();
            isNegative = true;
        }

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

        if (moveNext() != '/')
        {
            write("Expected literal:type expression.");
            return null;
        }

        auto typeStr = [moveNext(), moveNext()];
        LiteralType type;

        try
            type = to!LiteralType(typeStr);
        catch (ConvException)
        {
            write("Expected i8, i16, i32, i64, f32, or f64.");
            return null;
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

        try
        {
            final switch (type)
            {
                case LiteralType.int8:
                    value.intValue.value8u = parse!ubyte(literal, radixNo);

                    if (isNegative)
                        value.intValue.value8s = -value.intValue.value8u;
                    break;
                case LiteralType.int16:
                    value.intValue.value16u = parse!ushort(literal, radixNo);

                    if (isNegative)
                        value.intValue.value16s = -value.intValue.value16u;
                    break;
                case LiteralType.int32:
                    value.intValue.value32u = parse!uint(literal, radixNo);

                    if (isNegative)
                        value.intValue.value32s = -value.intValue.value32u;
                    break;
                case LiteralType.int64:
                    value.intValue.value64u = parse!ulong(literal, radixNo);

                    if (isNegative)
                        value.intValue.value64s = -value.intValue.value64u;
                    break;
                case LiteralType.float32:
                    uint raw;

                    if (!isFloat)
                    {
                        raw = parse!uint(literal, radixNo);
                        value.floatValue.value32 = *cast(float*)&raw;
                    }
                    else
                        value.floatValue.value32 = parse!float(literal);

                    if (isNegative)
                        value.floatValue.value32 = -value.floatValue.value32;
                    break;
                case LiteralType.float64:
                    ulong raw;

                    if (!isFloat)
                    {
                        raw = parse!ulong(literal, radixNo);
                        value.floatValue.value32 = *cast(double*)&raw;
                    }
                    else
                        value.floatValue.value32 = parse!double(literal);

                    if (isNegative)
                        value.floatValue.value32 = -value.floatValue.value32;
                    break;
            }
        }
        catch (ConvException)
        {
            writef("Could not lex value %s as type %s.", literal, type);
            return null;
        }

        return new LiteralToken(Literal(type, value));
    }

    protected Token virtualLexNext(char chr)
    {
        return null;
    }
}
