module CONTROL_UNIT #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 12,
    parameter ULA_WIDTH = 24,
    parameter INSTRUCTION_WIDTH = 16
    ) (
        //input
        input clk, reset,
        input [(DATA_WIDTH-1):0] INSTR_IN, ARG_IN,
        input COMPARE_IN, OVERFLOW_IN,
        input [(ADDR_WIDTH-1):0] TOS_IN,
        //outputs
        output reg CTRL_REG_TOS_FUNCTION, SEL_SOMADOR_SUBTRATOR, CTRL_STACK_FUNCTION, CTRL_REG_DATA_RETURN,
        output reg [(DATA_WIDTH-1):0] STACK_OUT,
        output reg CTRL_REG_OP1, CTRL_REG_OP2,
        output reg CTRL_STACK_COMP,
        output reg [3:0] SEL_ULA,
        output reg CTRL_REG_ARG, CTRL_REG_INSTR, CTRL_REG_JUMP, CTRL_REG_PC, SEL_MUX_PC
    );


endmodule
