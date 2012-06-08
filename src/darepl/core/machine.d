module darepl.core.machine;

import darepl.core.parser;

public abstract class Machine
{
    private Register[ushort] _registers;

    @property public final Register[ushort] registers()
    {
        return _registers;
    }

    public final RegisterState[Register] copyState()
    {
        RegisterState[Register] regs;

        foreach (id, reg; _registers)
            regs[reg] = reg.state.copy();

        return regs;
    }
}

public abstract class Register
{
    private RegisterState _state;

    protected this(RegisterState state)
    in
    {
        assert(state);
    }
    body
    {
        _state = state;
    }

    @property public final RegisterState state()
    out (result)
    {
        assert(result);
    }
    body
    {
        return _state;
    }
}

public abstract class RegisterState
{
    public abstract RegisterState copy();
}
