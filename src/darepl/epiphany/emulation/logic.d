module darepl.epiphany.emulation.logic;

import darepl.core.lexer,
       darepl.epiphany.instructions,
       darepl.epiphany.machine;

public extern (C)
{
    void epiphany_and_reg32_reg32_reg32(EpiphanyMachine machine, EpiphanyInstruction instruction,
                                        EpiphanyRegister32 rd, EpiphanyRegister32 rn, EpiphanyRegister32 rm)
    {
        // RD = RN & RM
        rd.memory.u32[0] = rn.memory.u32[0] & rm.memory.u32[0];

        // AN = RD[31]
        machine.status.memory.bits.b5 = rd.memory.bits.b31;

        // AV = 0
        machine.status.memory.bits.b7 = 0;

        // AC = 0
        machine.status.memory.bits.b6 = 0;

        // if (RD[31:0] == 0) { AZ = 1 } else { AZ = 0 }
        machine.status.memory.bits.b4 = !rd.memory.u32[0];
    }

    void epiphany_orr_reg32_reg32_reg32(EpiphanyMachine machine, EpiphanyInstruction instruction,
                                        EpiphanyRegister32 rd, EpiphanyRegister32 rn, EpiphanyRegister32 rm)
    {
        // RD = RN | RM
        rd.memory.u32[0] = rn.memory.u32[0] | rm.memory.u32[0];

        // AN = RD[31]
        machine.status.memory.bits.b5 = rd.memory.bits.b31;

        // AV = 0
        machine.status.memory.bits.b7 = 0;

        // AC = 0
        machine.status.memory.bits.b6 = 0;

        // if (RD[31:0] == 0) { AZ = 1 } else { AZ = 0 }
        machine.status.memory.bits.b4 = !rd.memory.u32[0];
    }

    void epiphany_eor_reg32_reg32_reg32(EpiphanyMachine machine, EpiphanyInstruction instruction,
                                        EpiphanyRegister32 rd, EpiphanyRegister32 rn, EpiphanyRegister32 rm)
    {
        // RD = RN ^ RM
        rd.memory.u32[0] = rn.memory.u32[0] ^ rm.memory.u32[0];

        // AN = RD[31]
        machine.status.memory.bits.b5 = rd.memory.bits.b31;

        // AV = 0
        machine.status.memory.bits.b7 = 0;

        // AC = 0
        machine.status.memory.bits.b6 = 0;

        // if (RD[31:0] == 0) { AZ = 1 } else { AZ = 0 }
        machine.status.memory.bits.b4 = !rd.memory.u32[0];
    }
}
