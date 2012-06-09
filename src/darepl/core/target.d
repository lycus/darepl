module darepl.core.target;

import std.algorithm,
       std.string,
       darepl.core.common,
       darepl.core.console,
       darepl.core.lexer,
       darepl.core.machine,
       darepl.core.parser;

public abstract class Target
{
    @property public abstract Architecture architecture();

    @property public abstract ubyte[] supportedBits();

    public abstract bool run(ubyte bits);

    protected Lexer createLexer(string input)
    {
        return new Lexer(input);
    }

    protected abstract Parser createParser(Machine machine, Token[] tokens);

    protected abstract bool handleInstruction(Machine machine, Instruction instruction);

    protected final bool repl(Machine machine, ubyte bits)
    in
    {
        assert(machine);
    }
    body
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

                    switch (toLower(command))
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

                    auto parser = createParser(machine, tokens);
                    Instruction insn;

                    try
                        insn = parser.parse();
                    catch (ParserException ex)
                        write(ex.msg);

                    if (!insn)
                        continue;

                    if (!handleInstruction(machine, insn))
                        return false;
                }
            }
        }
    }
}
