module pamPy #(
    parameter GENERAL_DATA_WIDTH = 8,
    parameter GENERAL_ADDR_WIDTH = 12,
    parameter GENERAL_ULA_WIDTH = 24,
    parameter GENERAL_INSTRUCTION_WIDTH = 16
    )(
        input general_clk, general_reset
    );

// block 1
    // CONTROLS
wire GENERAL_CTRL_REG_OP1, GENERAL_CTRL_REG_OP2;
wire [3:0] GENERAL_SEL_ULA;
    //outputs
wire [(GENERAL_ULA_WIDTH-1):0] GENERAL_ULA_OUT;
wire GENERAL_REG_OVERFLOW_OUT, GENERAL_STACK_COMP_OUT;
// ----------------------------------------------------------------------------
//block 2
wire [(GENERAL_ADDR_WIDTH-1):0] GENERAL_STACK_FUNCTION_OUT;
    // CONTROLS
wire GENERAL_CTRL_REG_ARG, GENERAL_CTRL_REG_INSTR, GENERAL_CTRL_REG_JUMP, GENERAL_CTRL_REG_PC, GENERAL_SEL_MUX_PC;
    //outputs
wire [(GENERAL_DATA_WIDTH-1):0] GENERAL_REG_ARG, GENERAL_REG_INSTR;
wire [(GENERAL_ADDR_WIDTH-1):0] GENERAL_REG_JUMP, GENERAL_REG_PC;
// ----------------------------------------------------------------------------
//block 3
wire [(GENERAL_ADDR_WIDTH-1):0] GENERAL_REG_TOS;
//controls
wire GENERAL_CTRL_REG_TOS_FUNCTION, GENERAL_SEL_SOMADOR_SUBTRATOR, GENERAL_CTRL_STACK_FUNCTION, GENERAL_CTRL_REG_DATA_RETURN;
//outputs
wire [(GENERAL_ADDR_WIDTH-1):0] GENERAL_STACK_TOS_OUT;
wire [(GENERAL_DATA_WIDTH-1):0] GENERAL_REG_DATA_RETURN_OUT;
// ----------------------------------------------------------------------------
// block 4
wire [(GENERAL_DATA_WIDTH-1):0] GENERAL_STACK_OUT;
//CONTROLS
wire [1:0] GENERAL_SEL_MUX_STACK, GENERAL_CTRL_REG_MEM_EXT, GENERAL_CTRL_REG_STACK;
wire GENERAL_SEL_MUX_TOS, GENERAL_CTRL_REG_TOS, GENERAL_CTRL_STACK, GENERAL_CTRL_MEM_EXT, GENERAL_CTRL_REG_ADDR;
// ----------------------------------------------------------------------------
BLOCK_ULA_OPS #(
    .DATA_WIDTH (GENERAL_DATA_WIDTH),
    .ADDR_WIDTH (GENERAL_ADDR_WIDTH)
    ) block_1 (
        .clk (general_clk),
        .REG1_IN (GENERAL_STACK_OUT),
        .REG2_IN (GENERAL_STACK_OUT),
        .TOS_IN (GENERAL_REG_TOS),
        // CONTROLS
        .CTRL_REG_OP1 (GENERAL_CTRL_REG_OP1),
        .CTRL_REG_OP2 (GENERAL_CTRL_REG_OP2),
        .CTRL_STACK_COMP (GENERAL_CTRL_STACK_COMP),
        .SEL_ULA (GENERAL_SEL_ULA),
        // OUTPUT
        .STACK_COMP_OUT (GENERAL_STACK_COMP_OUT),
        .REG_OVERFLOW_OUT (GENERAL_REG_OVERFLOW_OUT),
        .ULA_OUT (GENERAL_ULA_OUT)
        );
endmodule
