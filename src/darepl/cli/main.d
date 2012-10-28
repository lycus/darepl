module darepl.cli.main;

import core.memory,
       std.algorithm,
       std.conv,
       std.getopt,
       std.traits,
       darepl.core.common,
       darepl.core.console,
       darepl.core.edit,
       darepl.arm.target,
       darepl.core.target,
       darepl.epiphany.target,
       darepl.ia64.target,
       darepl.mips.target,
       darepl.ppc.target,
       darepl.x86.target;

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
        writef("Error: Could not parse command line: %s", ex.msg);
        return 2;
    }

    write("D Architecture REPL (DAREPL) 1.0");
    write("Copyright (c) 2012 The Lycus Foundation - http://lycus.org");
    write("Available under the terms of the MIT License");
    write();

    if (help)
    {
        usage(cli);
        write();

        write("    arch: Which architecture to emulate in the REPL instance.");
        write("    bits: Pointer length to emulate (32/64). Some targets only support 32.");
        write();

        write("Available architectures:");
        write();

        foreach (val; EnumMembers!Architecture)
            writef("    * %s", val);

        write();

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
        writef("Could not parse architecture/bitness arguments: %s", ex.msg);
        return 2;
    }

    Target target;

    final switch (arch)
    {
        case Architecture.arm:
            target = new ARMTarget();
            break;
        case Architecture.epiphany:
            target = new EpiphanyTarget();
            break;
        case Architecture.ia64:
            target = new IA64Target();
            break;
        case Architecture.mips:
            target = new MIPSTarget();
            break;
        case Architecture.ppc:
            target = new PPCTarget();
            break;
        case Architecture.x86:
            target = new X86Target();
            break;
    }

    if (!target.supportedBits.canFind(bits))
    {
        writef("The architecture %s doesn't support bitness: %s", arch, bits);
        return 2;
    }

    // Tab completion of files doesn't really make sense for us.
    rl_bind_key('\t', &rl_insert);

    return target.run(bits, true) ? 0 : 1;
}

private void usage(string cli)
in
{
    assert(cli);
}
body
{
    writef("Usage: %s [--help|-h] <arch> <bits>", cli);
}

private int main(string[] args)
in
{
    assert(args);

    foreach (arg; args)
        assert(arg);
}
body
{
    scope (exit)
        GC.collect();

    return run(args);
}
