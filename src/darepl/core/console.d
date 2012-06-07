module darepl.core.console;

import std.stdio,
       darepl.core.common;

public void write(T ...)(T args)
{
    writeln(args);
}

public void writef(T ...)(T args)
in
{
    static assert(args.length);
}
body
{
    writefln(args);
}

public string read(Architecture arch, ubyte bits)
out (result)
{
    assert(result);
}
body
{
    std.stdio.writef("%s (%s)> ", arch, bits);

    return readln();
}
