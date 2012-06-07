module darepl.ia64.target;

import darepl.core.console,
       darepl.core.target;

public final class IA64Target : Target
{
    public override bool run(ubyte bits)
    {
        switch (bits)
        {
            case 64:
                break;
            default:
                writef("Unsupported bits: %s", bits);
                return false;
        }

        return true;
    }
}
