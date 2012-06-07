module darepl.cli.main;

import core.memory,
       std.conv,
       std.getopt,
       std.stdio,
       std.traits,
       darepl.core.common;

private ubyte run(string[] args)
in
{
    assert(args);

    foreach (arg; args)
        assert(arg);
}
body
{
    auto cli = args[0];

    bool help;

    try
    {
        getopt(args,
               config.caseSensitive,
               config.bundling,
               "help|h", &help);
    }
    catch (Exception ex)
    {
        logf("Error: Could not parse command line: %s", ex.msg);
        return 2;
    }

    log("D Architecture REPL (DAREPL) 1.0");
    log("Copyright (c) 2012 The Lycus Foundation - http://lycus.org");
    log("Available under the terms of the MIT License");
    log();

    if (help)
    {
        usage(cli);
        log();

        log("    arch: Which architecture to emulate in the REPL instance.");
        log("    bits: Pointer length to emulate (32/64). Some targets only support 32.");
        log();

        log("Available architectures:");
        log();

        foreach (val; EnumMembers!Architecture)
            logf("    * %s", val);

        log();

        return 0;
    }

    if (args.length < 3)
    {
        usage(cli);

        return 2;
    }

    Architecture arch;
    ubyte bits;

    try
    {
        arch = to!Architecture(args[1]);
        bits = to!ubyte(args[2]);
    }
    catch (ConvException ex)
    {
        logf("Could not parse architecture/bitness arguments: %s", ex.msg);
        return 2;
    }

    return 0;
}

private void usage(string cli)
in
{
    assert(cli);
}
body
{
    logf("Usage: %s [--help|-h] <arch> <bits>", cli);
}

public void log(T ...)(T args)
{
    writeln(args);
}

public void logf(T ...)(T args)
{
    writefln(args);
}

private int main(string[] args)
{
    scope (exit)
        GC.collect();

    return run(args);
}
