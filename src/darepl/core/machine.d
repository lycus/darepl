module darepl.core.machine;

import core.sys.posix.dlfcn,
       std.array,
       std.algorithm,
       std.bitmanip,
       std.conv,
       std.metastrings,
       std.range,
       std.string,
       std.typetuple,
       ffi,
       darepl.core.console,
       darepl.core.parser,
       darepl.core.target;

public abstract class Machine
{
    private Target _target;
    private ubyte _bits;
    private Register[ushort] _registers;
    private Register[] _snapshot;

    pure nothrow invariant()
    {
        assert(_target);
    }

    protected this(Target target, ubyte bits) pure nothrow
    in
    {
        assert(target);
    }
    body
    {
        _target = target;
        _bits = bits;

        initializeRegisters(bits);
    }

    @property public final Target target() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _target;
    }

    @property public final ubyte bits() pure nothrow
    {
        return _bits;
    }

    @property public final ref Register[ushort] registers() pure nothrow
    {
        return _registers;
    }

    public final void beginMutation()
    in
    {
        assert(!_snapshot);
    }
    body
    {
        _snapshot = _registers.values;

        foreach (i, reg; _snapshot)
            _snapshot[i] = reg.snapshot();
    }

    public final bool dispatch(Instruction instruction)
    in
    {
        assert(instruction);
    }
    body
    {
        dlerror();

        auto proc = dlopen(null, RTLD_LAZY);

        if (!proc)
        {
            writef("Could not open handle to the current process: %s", to!string(dlerror()));
            return false;
        }

        dlerror();

        auto str = to!string(_target.architecture) ~ '_' ~ createDispatchString(instruction);
        auto fcn = dlsym(proc, toStringz(str));

        if (auto error = dlerror())
        {
            writef("Could not dispatch instruction (function %s): %s", str, to!string(error));
            return false;
        }

        auto paramTypes = [FFIType.ffiPointer, FFIType.ffiPointer];
        auto args = [cast(void*)&this, cast(void*)&instruction];

        foreach (ref operand; instruction.operands)
        {
            paramTypes ~= FFIType.ffiPointer;
            args ~= cast(void*)&operand;
        }

        beginMutation();

        ffiCall(cast(FFIFunction)fcn, FFIType.ffiVoid, paramTypes, null, args);

        finishMutation();

        return true;
    }

    public final void finishMutation()
    in
    {
        assert(_snapshot);
    }
    body
    {
        scope (exit)
            _snapshot = null;

        Register[Register] changed;

        foreach (pre, post; lockstep(_snapshot, _registers.values))
            if (pre.memory.u8 != post.memory.u8)
                changed[pre] = post;

        if (!changed.length)
            return;

        foreach (pre, post; changed)
        {
            writef("%-15s %s", pre.name, pre.stringize());
            writef("%-15s %s", "->", post.stringize());
        }
    }

    protected abstract void initializeRegisters(ubyte bits) pure nothrow;

    protected abstract string createDispatchString(Instruction instruction);
}

private template BitfieldArguments(size_t start, size_t end)
{
    static assert(start < end);

    private template InternalBitfieldArguments(size_t start, size_t end, size_t i, X ...)
    {
        static if (i > end)
            alias TypeTuple!X InternalBitfieldArguments;
        else
            alias InternalBitfieldArguments!(start, end, i + 1, TypeTuple!(X, ubyte, "b" ~ toStringNow!i, 1)) InternalBitfieldArguments;
    }

    public alias InternalBitfieldArguments!(start, end, start) BitfieldArguments;
}

public struct RegisterBits
{
    mixin(bitfields!(BitfieldArguments!(0, 63)));
    mixin(bitfields!(BitfieldArguments!(64, 127)));
    mixin(bitfields!(BitfieldArguments!(128, 191)));
    mixin(bitfields!(BitfieldArguments!(192, 255)));
}

static assert(RegisterBits.sizeof == 32);

public union RegisterMemory
{
    public RegisterBits bits;
    public ubyte[32] u8;
    public byte[32] s8;
    public ushort[16] u16;
    public short[16] s16;
    public uint[8] u32;
    public int[8] s32;
    public ulong[4] u64;
    public long[4] s64;
    public float[8] f32;
    public double[4] f64;
}

static assert(RegisterMemory.sizeof == 32);

public abstract class Register
{
    private string _name;
    private RegisterMemory* _memory;

    pure nothrow invariant()
    {
        assert(_name);
        assert(_memory);
    }

    protected this(string name) pure nothrow
    in
    {
        assert(name);
    }
    body
    {
        this(name, new RegisterMemory());
    }

    protected this(string name, RegisterMemory memory) pure nothrow
    in
    {
        assert(name);
    }
    body
    {
        this(name);

        *_memory = memory;
    }

    protected this(string name, RegisterMemory* memory) pure nothrow
    in
    {
        assert(name);
        assert(memory);
    }
    body
    {
        _name = name;
        _memory = memory;
    }

    @property public final RegisterMemory* memory() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _memory;
    }

    @property public final string name() pure nothrow
    out (result)
    {
        assert(result);
    }
    body
    {
        return _name;
    }

    public abstract Register snapshot() pure nothrow;

    public abstract string stringize();
}
