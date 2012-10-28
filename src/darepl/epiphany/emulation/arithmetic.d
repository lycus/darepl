module darepl.epiphany.emulation.arithmetic;

import darepl.core.lexer,
       darepl.core.utilities,
       darepl.epiphany.instructions,
       darepl.epiphany.machine;

public extern (C)
{
    void epiphany_add_reg32_reg32_reg32(EpiphanyMachine machine, EpiphanyInstruction instruction,
                                        EpiphanyRegister32 rd, EpiphanyRegister32 rn, EpiphanyRegister32 rm)
    {
        // RD = RN + RM
        rd.memory.u32[0] = rn.memory.u32[0] + rm.memory.u32[0];

        // AN = RD[31]
        machine.status.memory.bits.b5 = rd.memory.bits.b31;

        // AC = RD[31:0] < RN[31:0]
        machine.status.memory.bits.b6 = rd.memory.u32[0] < rn.memory.u32[0];

        // if (RD[31:0] == 0) { AZ = 1 } else { AZ = 0 }
        machine.status.memory.bits.b4 = !rd.memory.u32[0];

        // if ((RD[31] & ~RM[31] & ~RN[31]) | (~RD[31] & RM[31] & RN[31])) { AV = 1 } else { AV = 0 }
        machine.status.memory.bits.b7 = (rd.memory.bits.b31 & ~rm.memory.bits.b31 & ~rn.memory.bits.b31) |
                                        (~rd.memory.bits.b31 & rm.memory.bits.b31 & rn.memory.bits.b31);

        // AVS = AVS | AV
        machine.status.memory.bits.b12 = machine.status.memory.bits.b12 | machine.status.memory.bits.b7;
    }

    void epiphany_add_reg32_reg32_int8(EpiphanyMachine machine, EpiphanyInstruction instruction,
                                       EpiphanyRegister32 rd, EpiphanyRegister32 rn, Literal imm)
    {
        auto simm3 = limitTo(imm.value.value8u, 3);

        // RD = RN + SIMM3
        rd.memory.u32[0] = rn.memory.u32[0] + simm3;

        // AN = RD[31]
        machine.status.memory.bits.b5 = rd.memory.bits.b31;

        // AC = RD[31:0] < RN[31:0]
        machine.status.memory.bits.b6 = rd.memory.u32[0] < rn.memory.u32[0];

        // if (RD[31:0] == 0) { AZ = 1 } else { AZ = 0 }
        machine.status.memory.bits.b4 = !rd.memory.u32[0];

        // if ((RD[31] & ~SIMM3[2] & ~RN[31]) | (~RD[31] & SIMM3[2] & RN[31])) { AV = 1 } else { AV = 0 }
        machine.status.memory.bits.b7 = (rd.memory.bits.b31 & ~(simm3 & 0b001) & ~rn.memory.bits.b31) |
                                        (~rd.memory.bits.b31 & (simm3 & 0b001) & rn.memory.bits.b31);

        // AVS = AVS | AV
        machine.status.memory.bits.b12 = machine.status.memory.bits.b12 | machine.status.memory.bits.b7;
    }

    void epiphany_add_reg32_reg32_int16(EpiphanyMachine machine, EpiphanyInstruction instruction,
                                        EpiphanyRegister32 rd, EpiphanyRegister32 rn, Literal imm)
    {
        auto simm11 = limitTo(imm.value.value16u, 11);

        // RD = RN + SIMM10
        rd.memory.u32[0] = rn.memory.u32[0] + simm11;

        // AN = RD[31]
        machine.status.memory.bits.b5 = rd.memory.bits.b31;

        // AC = RD[31:0] < RN[31:0]
        machine.status.memory.bits.b6 = rd.memory.u32[0] < rn.memory.u32[0];

        // if (RD[31:0] == 0) { AZ = 1 } else { AZ = 0 }
        machine.status.memory.bits.b4 = !rd.memory.u32[0];

        // if ((RD[31] & ~SIMM11[10] & ~RN[31]) | (~RD[31] & SIMM11[10] & RN[31])) { AV = 1 } else { AV = 0 }
        machine.status.memory.bits.b7 = (rd.memory.bits.b31 & ~(simm11 & 0b00000000001) & ~rn.memory.bits.b31) |
                                        (~rd.memory.bits.b31 & (simm11 & 0b00000000001) & rn.memory.bits.b31);

        // AVS = AVS | AV
        machine.status.memory.bits.b12 = machine.status.memory.bits.b12 | machine.status.memory.bits.b7;
    }

    void epiphany_sub_reg32_reg32_reg32(EpiphanyMachine machine, EpiphanyInstruction instruction,
                                        EpiphanyRegister32 rd, EpiphanyRegister32 rn, EpiphanyRegister32 rm)
    {
        // RD = RN - RM
        rd.memory.u32[0] = rn.memory.u32[0] - rm.memory.u32[0];

        // AN = RD[31]
        machine.status.memory.bits.b5 = rd.memory.bits.b31;

        // AC = RD[31:0] < RN[31:0]
        machine.status.memory.bits.b6 = rd.memory.u32[0] < rn.memory.u32[0];

        // if (RD[31:0] == 0) { AZ = 1 } else { AZ = 0 }
        machine.status.memory.bits.b4 = !rd.memory.u32[0];

        // if ((RD[31] & ~RM[31] & ~RN[31]) | (~RD[31] & RM[31] & RN[31])) { AV = 1 } else { AV = 0 }
        machine.status.memory.bits.b7 = (rd.memory.bits.b31 & ~rm.memory.bits.b31 & ~rn.memory.bits.b31) |
                                        (~rd.memory.bits.b31 & rm.memory.bits.b31 & rn.memory.bits.b31);

        // AVS = AVS | AV
        machine.status.memory.bits.b12 = machine.status.memory.bits.b12 | machine.status.memory.bits.b7;
    }

    void epiphany_sub_reg32_reg32_int8(EpiphanyMachine machine, EpiphanyInstruction instruction,
                                       EpiphanyRegister32 rd, EpiphanyRegister32 rn, Literal imm)
    {
        auto simm3 = limitTo(imm.value.value8u, 3);

        // RD = RN - SIMM3
        rd.memory.u32[0] = rn.memory.u32[0] - simm3;

        // AN = RD[31]
        machine.status.memory.bits.b5 = rd.memory.bits.b31;

        // AC = RD[31:0] < RN[31:0]
        machine.status.memory.bits.b6 = rd.memory.u32[0] < rn.memory.u32[0];

        // if (RD[31:0] == 0) { AZ = 1 } else { AZ = 0 }
        machine.status.memory.bits.b4 = !rd.memory.u32[0];

        // if ((RD[31] & ~SIMM3[2] & ~RN[31]) | (~RD[31] & SIMM3[2] & RN[31])) { AV = 1 } else { AV = 0 }
        machine.status.memory.bits.b7 = (rd.memory.bits.b31 & ~(simm3 & 0b001) & ~rn.memory.bits.b31) |
                                        (~rd.memory.bits.b31 & (simm3 & 0b001) & rn.memory.bits.b31);

        // AVS = AVS | AV
        machine.status.memory.bits.b12 = machine.status.memory.bits.b12 | machine.status.memory.bits.b7;
    }

    void epiphany_sub_reg32_reg32_int16(EpiphanyMachine machine, EpiphanyInstruction instruction,
                                        EpiphanyRegister32 rd, EpiphanyRegister32 rn, Literal imm)
    {
        auto simm11 = limitTo(imm.value.value16u, 11);

        // RD = RN - SIMM10
        rd.memory.u32[0] = rn.memory.u32[0] - simm11;

        // AN = RD[31]
        machine.status.memory.bits.b5 = rd.memory.bits.b31;

        // AC = RD[31:0] < RN[31:0]
        machine.status.memory.bits.b6 = rd.memory.u32[0] < rn.memory.u32[0];

        // if (RD[31:0] == 0) { AZ = 1 } else { AZ = 0 }
        machine.status.memory.bits.b4 = !rd.memory.u32[0];

        // if ((RD[31] & ~SIMM11[10] & ~RN[31]) | (~RD[31] & SIMM11[10] & RN[31])) { AV = 1 } else { AV = 0 }
        machine.status.memory.bits.b7 = (rd.memory.bits.b31 & ~(simm11 & 0b00000000001) & ~rn.memory.bits.b31) |
                                        (~rd.memory.bits.b31 & (simm11 & 0b00000000001) & rn.memory.bits.b31);

        // AVS = AVS | AV
        machine.status.memory.bits.b12 = machine.status.memory.bits.b12 | machine.status.memory.bits.b7;
    }
}
