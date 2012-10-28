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
                                 EpiphanyRegister32 rd, Literal imm8)
    {
        // RD = IMM8
        rd.memory.u32[0] = imm8.value.intValue.value8u;
    }

    void epiphany_mov_reg32_int16(EpiphanyMachine machine, EpiphanyInstruction instruction,
                                  EpiphanyRegister32 rd, Literal imm16)
    {
        // RD = IMM16
        rd.memory.u32[0] = imm16.value.intValue.value16u;
    }

    void epiphany_movt_reg32_int16(EpiphanyMachine machine, EpiphanyInstruction instruction,
                                   EpiphanyRegister32 rd, Literal imm16)
    {
        // RD = RD[15:0] | (IMM16 << 16)
        rd.memory.u32[0] = rd.memory.u16[0] | (imm16.value.intValue.value16u << 16);
    }
}
