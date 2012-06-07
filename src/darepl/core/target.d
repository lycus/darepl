module darepl.core.target;

import std.algorithm,
       std.string,
       darepl.core.common,
       darepl.core.console,
       darepl.core.lexer;

public abstract class Target
{
    @property public abstract Architecture architecture();

    @property public abstract ubyte[] supportedBits();

    public abstract bool run(ubyte bits);

    protected Lexer createLexer(string input)
    {
        return new Lexer(input);
    }

    protected abstract bool handleStatement(Token[] tokens);

    protected final bool repl(ubyte bits)
    {
        writef("Running REPL for architecture %s (%s)...", architecture, bits);
        write();

        while (true)
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
                            return true;
                        case "arch":
                            writef("Emulating architecture: %s", architecture);
                            break;
                        case "bits":
                            writef("Emulating bitness: %s", bits);
                            break;
                        default:
                            writef("Unknown REPL command: %s", command);
                    }
                }
                else
                {
                    auto lexer = createLexer(trimmed);
                    auto tokens = lexer.lex();

                    if (!tokens)
                        continue;

                    if (!handleStatement(tokens))
                        return false;
                }
            }
        }
    }
}
