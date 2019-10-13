module CONTROL_UNIT #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 12,
    parameter INSTRUCTION_WIDTH = 16
    ) (
        //input
        input clk, reset,
        input [(DATA_WIDTH-1):0] INSTR_IN, ARG_IN,
        input COMPARE_IN, OVERFLOW_IN,
        input [(ADDR_WIDTH-1):0] TOS_IN,
        //outputs
        output reg CTRL_REG_TOS_FUNCTION, SEL_SOMADOR_SUBTRATOR, CTRL_STACK_FUNCTION, CTRL_REG_DATA_RETURN,
        output reg SEL_PC_UPDATER, SEL_TOS_UPDATER,
        output reg CTRL_STACK, CTRL_MEM_EXT,
        output reg CTRL_REG_OP1, CTRL_REG_OP2,
        output reg CTRL_STACK_COMP,
        output reg [3:0] SEL_ULA,
        output reg CTRL_REG_READ_STACK, CTRL_REG_WRITE_STACK,
        output reg CTRL_REG_READ_MEMORY, CTRL_REG_WRITE_MEMORY,
        output reg CTRL_REG_ARG, CTRL_REG_INSTR, CTRL_REG_JUMP, CTRL_REG_PC,
        output reg SEL_MUX_TOS,
        output reg [1:0] SEL_MUX_PC
    );


endmodule
