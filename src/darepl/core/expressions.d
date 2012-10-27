module darepl.core.instructions;

import darepl.core.lexer;

public abstract class Expression
{
    protected this() pure nothrow
    {
    }
}

public final class LiteralExpression : Expression
{
    private Literal _literal;

    public this(Literal literal) pure nothrow
    {
        _literal = literal;
    }

    @property public Literal literal() pure nothrow
    {
        return _literal;
    }
}

public abstract class UnaryExpression : Expression
{
    private Expression _expression;

    pure nothrow invariant()
    {
        assert(_expression);
    }

    public this(Expression expression) pure nothrow
    in
    {
        assert(expression);
    }
    body
    {
        _expression = expression;
    }

    @property public Expression expression() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _expression;
    }
}

public final class NegateExpression : UnaryExpression
{
    public this(Expression expression) pure nothrow
    in
    {
        assert(expression);
    }
    body
    {
        super(expression);
    }
}

public final class PlusExpression : UnaryExpression
{
    public this(Expression expression) pure nothrow
    in
    {
        assert(expression);
    }
    body
    {
        super(expression);
    }
}

public final class NotExpression : UnaryExpression
{
    public this(Expression expression) pure nothrow
    in
    {
        assert(expression);
    }
    body
    {
        super(expression);
    }
}

public final class ComplementExpression : UnaryExpression
{
    public this(Expression expression) pure nothrow
    in
    {
        assert(expression);
    }
    body
    {
        super(expression);
    }
}

public abstract class BinaryExpression : Expression
{
    private Expression _left;
    private Expression _right;

    pure nothrow invariant()
    {
        assert(_left);
        assert(_right);
    }

    public this(Expression left, Expression right) pure nothrow
    in
    {
        assert(left);
        assert(right);
    }
    body
    {
        _left = left;
        _right = right;
    }

    @property public Expression left() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _left;
    }

    @property public Expression right() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _right;
    }
}

public final class AddExpression : BinaryExpression
{
    public this(Expression left, Expression right) pure nothrow
    in
    {
        assert(left);
        assert(right);
    }
    body
    {
        super(left, right);
    }
}

public final class SubtractExpression : BinaryExpression
{
    public this(Expression left, Expression right) pure nothrow
    in
    {
        assert(left);
        assert(right);
    }
    body
    {
        super(left, right);
    }
}

public final class MultiplyExpression : BinaryExpression
{
    public this(Expression left, Expression right) pure nothrow
    in
    {
        assert(left);
        assert(right);
    }
    body
    {
        super(left, right);
    }
}

public final class DivideExpression : BinaryExpression
{
    public this(Expression left, Expression right) pure nothrow
    in
    {
        assert(left);
        assert(right);
    }
    body
    {
        super(left, right);
    }
}

public final class ModuloExpression : BinaryExpression
{
    public this(Expression left, Expression right) pure nothrow
    in
    {
        assert(left);
        assert(right);
    }
    body
    {
        super(left, right);
    }
}

public final class OrExpression : BinaryExpression
{
    public this(Expression left, Expression right) pure nothrow
    in
    {
        assert(left);
        assert(right);
    }
    body
    {
        super(left, right);
    }
}

public final class AndExpression : BinaryExpression
{
    public this(Expression left, Expression right) pure nothrow
    in
    {
        assert(left);
        assert(right);
    }
    body
    {
        super(left, right);
    }
}

public final class ExclusiveOrExpression : BinaryExpression
{
    public this(Expression left, Expression right) pure nothrow
    in
    {
        assert(left);
        assert(right);
    }
    body
    {
        super(left, right);
    }
}

public final class LeftShiftExpression : BinaryExpression
{
    public this(Expression left, Expression right) pure nothrow
    in
    {
        assert(left);
        assert(right);
    }
    body
    {
        super(left, right);
    }
}

public final class RightShiftExpression : BinaryExpression
{
    public this(Expression left, Expression right) pure nothrow
    in
    {
        assert(left);
        assert(right);
    }
    body
    {
        super(left, right);
    }
}
