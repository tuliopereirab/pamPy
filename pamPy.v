module pamPy (
    parameter GENERAl_DATA_WIDTH = 8;
    parameter GENERAL_ADDR_WIDTH = 12;
    parameter GENERAL_ULA_WIDTH = 24;
    input general_clk, general_reset;
    );
    wire [(ADDR_WIDTH):0] GENERAL_MUX_REG1_IN,                   // regJump
    wire [(DATA_WIDTH):0] GENERAL_REG1_IN,
    wire [(DATA_WIDTH):0] GENERAL_MUX_REG2_IN_0, // regArg
    wire [(ADDR_WIDTH):0] GENERAL_MUX_REG2_IN_1, // tos
    wire [(ADDR_WIDTH):0] GENERAL_MUX_REG2_IN_2, // pc
    wire [(DATA_WIDTH):0] GENERAL_REG2_IN,

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
            .REG2_IN (GENERAL_REG2_IN)
            );
endmodule
