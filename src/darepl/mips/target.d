module darepl.mips.target;

import darepl.core.console,
       darepl.core.target;

public final class MIPSTarget : Target
{
    public override bool run(ubyte bits)
    {
        auto lp64 = bits == 64;

        switch (bits)
        {
            case 32:
            case 64:
                break;
            default:
                writef("Unsupported bits: %s", bits);
                return false;
        }

        return true;
    }
}
