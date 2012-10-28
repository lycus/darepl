module darepl.epiphany.emulation.misc;

import darepl.core.lexer,
       darepl.epiphany.instructions,
       darepl.epiphany.machine;

public extern (C)
{
    void epiphany_nop(EpiphanyMachine machine, EpiphanyInstruction instruction)
    {
    }

    void epiphany_mov_reg32_int8(EpiphanyMachine machine, EpiphanyInstruction instruction,
                                 EpiphanyRegister32 dst, Literal imm)
    {
        dst.memory.u32[0] = imm.value.intValue.value8u;
    }

    void epiphany_mov_reg32_int16(EpiphanyMachine machine, EpiphanyInstruction instruction,
                                  EpiphanyRegister32 dst, Literal imm)
    {
        dst.memory.u32[0] = imm.value.intValue.value16u;
    }

    void epiphany_movt_reg32_int16(EpiphanyMachine machine, EpiphanyInstruction instruction,
                                   EpiphanyRegister32 dst, Literal imm)
    {
        dst.memory.u32[0] = dst.memory.u16[0] | (imm.value.intValue.value16u << 16);
    }
}
