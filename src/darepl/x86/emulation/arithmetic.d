module darepl.x86.emulation.arithmetic;

import darepl.core.lexer,
       darepl.x86.instructions,
       darepl.x86.machine;

public extern (C)
{
    void x86_add_reg32_reg32(X86Machine machine, X86Instruction instruction, X86Register32 dst, X86Register32 src)
    {
        dst.memory.u32[0] += src.memory.u32[0];
    }

    void x86_add_reg32_int32(X86Machine machine, X86Instruction instruction, X86Register32 dst, Literal imm)
    {
        dst.memory.u32[0] += imm.value.value32u;
    }
}
