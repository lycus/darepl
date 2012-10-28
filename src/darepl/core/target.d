module darepl.core.target;

import std.algorithm,
       std.array,
       std.string,
       darepl.core.common,
       darepl.core.console,
       darepl.core.lexer,
       darepl.core.machine,
       darepl.core.parser;

public abstract class Target
{
    @property public abstract Architecture architecture() pure nothrow;

    @property public abstract ubyte[] supportedBits() pure nothrow;

    public abstract bool run(ubyte bits);

    protected Lexer createLexer(string input) pure nothrow
    {
        return new Lexer(input);
    }

    protected abstract Parser createParser(Machine machine, Token[] tokens) pure nothrow;

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
            auto str = read(architecture, bits);

            if (str.isNull)
            {
                writef("Exiting...");
                return true;
            }

            auto line = str.get;

            foreach (stmt; splitter(line, ';'))
            {
                auto trimmed = strip(stmt);

                if (!trimmed.length)
                    continue;

                if (trimmed[0] == '!')
                {
                    auto command = array(splitter(trimmed[1 .. $], ' '))[0];

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
                        case "print":
                        case "p":
                        case "show":
                        case "s":
                            bool any;

                            foreach (elem; splitter(trimmed[1 + command.length .. $], ' '))
                            {
                                auto arg = strip(elem);

                                if (!arg.length)
                                    continue;

                                bool found;

                                foreach (reg; machine.registers)
                                {
                                    if (reg.name == arg)
                                    {
                                        any = true;
                                        found = true;
                                        writef("%-15s %s", arg, reg.stringize());

                                    }
                                }

                                if (!found)
                                    write("Unknown register: %s", arg);
                            }

                            if (!any)
                                foreach (reg; sort!((a, b) => a.name < b.name)(machine.registers.values))
                                    writef("%-15s %s", reg.name, reg.stringize());

                            break;
                        case "reset":
                            machine.beginMutation();

                            foreach (reg; machine.registers)
                                reg.memory.u8[] = 0;

                            machine.finishMutation();

                            write("Machine state has been reset.");
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
