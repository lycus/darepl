module darepl.core.edit;

// TODO: This should really be a separate library binding.

alias extern (C) int function(int, int) rl_command_func_t;

extern (C)
{
    char* readline(const(char)*);
    int rl_insert(int, int);
    int rl_bind_key(int, rl_command_func_t);
    void add_history(const(char)*);
}
