module darepl.core.machine;

import core.sys.posix.dlfcn,
       std.array,
       std.algorithm,
       std.conv,
       std.range,
       std.utf,
       ffi,
       darepl.core.console,
       darepl.core.parser,
       darepl.core.target;

public abstract class Machine
{
    private Target _target;
    private Register[ushort] _registers;
    private Register[] _snapshot;

    invariant()
    {
        assert(_target);
    }

    protected this(Target target, ubyte bits)
    in
    {
        assert(target);
    }
    body
    {
        _target = target;

        initializeRegisters(bits);
    }

    @property public final Target target()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _target;
    }

    @property public final ref Register[ushort] registers()
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
        auto fcn = dlsym(proc, toUTFz!(const(char)*)(str));

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
        Register[Register] changed;

        foreach (pre, post; lockstep(_snapshot, _registers.values))
            if (pre.memory.u8 != post.memory.u8)
                changed[pre] = post;

        if (!changed.length)
            return;

        foreach (pre, post; changed)
            writef("[%s]\t{%s} -> {%s}", pre.name, pre.stringize(), post.stringize());

        _snapshot = null;
    }

    protected abstract void initializeRegisters(ubyte bits);

    protected abstract string createDispatchString(Instruction instruction);
}

public union RegisterMemory
{
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
    mixin template Snapshot()
    {
        mixin("public override typeof(this) snapshot()" ~
              "{" ~
              "    auto reg = new typeof(this)();" ~
              "    *reg.memory = *memory;" ~
              "    return reg;" ~
              "}");
    }

    private string _name;
    private RegisterMemory* _memory;

    invariant()
    {
        assert(_name);
        assert(_memory);
    }

    protected this(string name)
    in
    {
        assert(name);
    }
    body
    {
        this(name, new RegisterMemory());
    }

    protected this(string name, RegisterMemory memory)
    in
    {
        assert(name);
    }
    body
    {
        this(name);

        *_memory = memory;
    }

    protected this(string name, RegisterMemory* memory)
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

    @property public final RegisterMemory* memory()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _memory;
    }

    @property public final string name()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _name;
    }

    public abstract Register snapshot();

    public abstract string stringize();
}
