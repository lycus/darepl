module darepl.core.console;

import core.stdc.stdlib,
       std.conv,
       std.stdio,
       std.string,
       std.typecons,
       darepl.core.common,
       darepl.core.edit;

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

public Nullable!string read(Architecture arch, ubyte bits)
{
    auto line = readline(toStringz(format("%s-%s> ", arch, bits)));

    scope (exit)
        free(line);

    // Did we get EOF?
    if (!line)
        return Nullable!string();

    auto str = to!string(line); // Note that this creates a GC copy of line.

    // If the line is not white space, add it to history.
    if (strip(str).length)
        add_history(line);

    return Nullable!string(str);
}
