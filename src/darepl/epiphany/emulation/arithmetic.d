module darepl.epiphany.emulation.arithmetic;

import darepl.core.lexer,
       darepl.epiphany.instructions,
       darepl.epiphany.machine;

public extern (C)
{
    void epiphany_add_reg32_reg32_reg32(EpiphanyMachine machine, EpiphanyInstruction instruction,
                                        EpiphanyRegister32 dst, EpiphanyRegister32 r0, EpiphanyRegister32 r1)
    {
        dst.memory.u32[0] = r0.memory.u32[0] + r1.memory.u32[0];
    }

    void epiphany_add_reg32_reg32_int8(EpiphanyMachine machine, EpiphanyInstruction instruction,
                                       EpiphanyRegister32 dst, EpiphanyRegister32 r0, Literal imm)
    {
        dst.memory.u32[0] = r0.memory.u32[0] + imm.value.intValue.value8u;
    }

    void epiphany_add_reg32_reg32_int16(EpiphanyMachine machine, EpiphanyInstruction instruction,
                                        EpiphanyRegister32 dst, EpiphanyRegister32 r0, Literal imm)
    {
        dst.memory.u32[0] = r0.memory.u32[0] + imm.value.intValue.value16u;
    }
}
