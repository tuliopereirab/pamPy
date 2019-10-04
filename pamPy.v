module pamPy #(
    parameter GENERAL_DATA_WIDTH = 8,
    parameter GENERAL_ADDR_WIDTH = 12,
    parameter GENERAL_ULA_WIDTH = 24
    )(
        input general_clk, general_reset
    );

// block 1
wire [(GENERAL_ADDR_WIDTH-1):0] GENERAL_MUX_REG1_IN;                   // regJump
wire [(GENERAL_DATA_WIDTH-1):0] GENERAL_REG1_IN;
wire [(GENERAL_DATA_WIDTH-1):0] GENERAL_MUX_REG2_IN_0; // regArg
wire [(GENERAL_ADDR_WIDTH-1):0] GENERAL_MUX_REG2_IN_1; // tos
wire [(GENERAL_ADDR_WIDTH-1):0] GENERAL_MUX_REG2_IN_2; // pc
wire [(GENERAL_DATA_WIDTH-1):0] GENERAL_REG2_IN;

wire [1:0] GENERAL_SEL_MUX_OP1, GENERAL_SEL_MUX_OP2;
wire GENERAL_CTRL_REG_OP1, GENERAL_CTRL_REG_OP2;
wire [3:0] GENERAL_SEL_ULA;

wire [(GENERAL_ULA_WIDTH-1):0] GENERAL_ULA_OUT;
wire GENERAL_REG_OVERFLOW_OUT, GENERAL_REG_COMP_OUT;
// ----------------------------------------------------------------------------
//block 2

// ----------------------------------------------------------------------------
BLOCK_ULA_OPS #(
    .DATA_WIDTH (GENERAL_DATA_WIDTH),
    .ADDR_WIDTH (GENERAL_ADDR_WIDTH),
    .ULA_WIDTH (GENERAL_ULA_WIDTH)
    ) block_1 (
        .clk (general_clk),
        .MUX_REG1_IN (GENERAL_MUX_REG1_IN),
        .REG1_IN (GENERAL_REG1_IN),
        .MUX_REG2_IN_0 (GENERAL_MUX_REG2_IN_0),
        .MUX_REG2_IN_1 (GENERAL_MUX_REG2_IN_1),
        .MUX_REG2_IN_2 (GENERAL_MUX_REG2_IN_2),
        .REG2_IN (GENERAL_REG2_IN),
        // CONTROLS
        .SEL_MUX1 (GENERAL_SEL_MUX_OP1),
        .SEL_MUX2 (GENERAL_SEL_MUX_OP2),
        .CTRL_REG_OP1 (GENERAL_CTRL_REG_OP1),
        .CTRL_REG_OP2 (GENERAL_CTRL_REG_OP2),
        .SEL_ULA (GENERAL_SEL_ULA),
        // OUTPUT
        .REG_COMP_OUT (GENERAL_REG_COMP_OUT),
        .REG_OVERFLOW_OUT (GENERAL_REG_OVERFLOW_OUT),
        .ULA_OUT (GENERAL_ULA_OUT)
        );
endmodule
