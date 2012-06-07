module darepl.core.target;

import std.algorithm,
       std.string,
       darepl.core.common,
       darepl.core.console;

public abstract class Target
{
    @property public abstract Architecture architecture();

    @property public abstract ubyte[] supportedBits();

    public abstract bool run(ubyte bits);

    protected abstract bool handleStatement(string statement);

    protected final void repl(ubyte bits)
    {
        bool stop;

        writef("Running REPL for architecture %s (%s)...", architecture, bits);
        write();

        while (!stop)
        {
            auto line = read(architecture, bits);

            foreach (stmt; splitter(line, ';'))
            {
                auto trimmed = strip(stmt);

                if (!trimmed.length)
                    continue;

                if (trimmed[0] == '!')
                {
                    auto command = trimmed[1 .. $];

                    switch (command)
                    {
                        case "exit":
                        case "quit":
                        case "q":
                            writef("Exiting...");
                            return;
                        default:
                            writef("Unknown REPL command: %s", command);
                    }
                }
                else if (!handleStatement(trimmed))
                    return;
            }
        }
    }
}
