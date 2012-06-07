module darepl.cli.main;

import core.memory,
       std.stdio,
       std.getopt;

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
               config.passThrough,
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
        return 0;
    }

    if (args.length < 2)
    {
        usage(cli);
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
    logf("Usage: %s [--help|-h]", cli);
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
