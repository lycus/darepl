module darepl.core.target;

public abstract class Target
{
    @property public abstract ubyte[] supportedBits();

    public abstract bool run(ubyte bits);
}
