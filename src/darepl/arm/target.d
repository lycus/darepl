module darepl.arm.target;

import darepl.core.console,
       darepl.core.target;

public final class ARMTarget : Target
{
    @property public override ubyte[] supportedBits()
    {
        return [32, 64];
    }

    public override bool run(ubyte bits)
    {
        auto lp64 = bits == 64;

        return true;
    }
}
