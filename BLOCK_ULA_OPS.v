module BLOCK_ULA_OPS #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 12
    ) (
        input clk,
        input [(DATA_WIDTH-1):0] REG1_IN,
        input [(DATA_WIDTH-1):0] REG2_IN,
        input [(ADDR_WIDTH-1):0] TOS_IN,        // regTOS
        output wire [(DATA_WIDTH-1):0] ULA_OUT,
        output wire STACK_COMP_OUT,
        output reg REG_OVERFLOW_OUT,
        // CONTROLS
        input CTRL_REG_OP1, CTRL_REG_OP2,
        input CTRL_REG_OVERFLOW, CTRL_STACK_COMP,
        input [3:0] SEL_ULA
    );

reg [(DATA_WIDTH-1):0] REG1_OUT, REG2_OUT;
wire [(DATA_WIDTH-1):0] ULA_IN_1, ULA_IN_2;
wire ULA_COMP_OUT, ULA_OVERFLOW_OUT;
wire [(DATA_WIDTH-1):0] ULA_MATH_ADD, ULA_MATH_SUB, ULA_MATH_MULT;
wire [(DATA_WIDTH-1):0] ULA_RSHIFT, ULA_LSHIFT;
wire ULA_COMP_EQUAL, ULA_COMP_GREATER, ULA_COMP_LESS;
wire ULA_COMP_GREATER_EQUAL, ULA_COMP_LESS_EQUAL, ULA_COMP_DIFFERENT;
wire [(DATA_WIDTH-1):0] ULA_LOGIC_NOT, ULA_LOGIC_AND, ULA_LOGIC_OR, ULA_LOGIC_XOR;


    always @ (posedge clk) // REG_OP1
    begin
        if(CTRL_REG_OP1)
            REG1_OUT <= REG1_IN;
    end

    always @ (posedge clk) // REG_OP2
    begin
        if(CTRL_REG_OP2)
            REG2_OUT <= REG1_IN;
    end

    always @ (posedge clk) // REG_OVERFLOW
    begin
        if(CTRL_REG_OVERFLOW)
            REG_OVERFLOW_OUT <= ULA_OVERFLOW_OUT;
    end
    // -------------------------------
    // stack_comp
    STACK_MEMORY #(
        .DATA_WIDTH_MEM (1),
        .ADDR_WIDTH_MEM (ADDR_WIDTH)
        ) stack_comp (
            .DATA_IN (ULA_COMP_OUT),
            .ADDR_IN (TOS_IN),
            .CTRL_MEM_WRITE (CTRL_STACK_COMP),
            .clk_mem (clk),
            .DATA_OUT (STACK_COMP_OUT)
        );
    // -------------------------------
    // ula
    assign ULA_MATH_ADD = ULA_IN_2 + ULA_IN_1;
    assign ULA_MATH_SUB = ULA_IN_2 - ULA_IN_1;
    assign ULA_MATH_MULT = ULA_IN_2 * ULA_IN_1;

    assign ULA_RSHIFT = ULA_IN_2 >> ULA_IN_1;
    assign ULA_LSHIFT = ULA_IN_2 << ULA_IN_1;

    assign ULA_COMP_EQUAL = (ULA_IN_2 == ULA_IN_1) ? 1'b1 :
                            1'b0;
    assign ULA_COMP_DIFFERENT = (ULA_IN_2 != ULA_IN_1) ? 1'b1 :
                                1'b0;
    assign ULA_COMP_GREATER_EQUAL = (ULA_IN_2 >= ULA_IN_1) ? 1'b1 :
                                    1'b0;
    assign ULA_COMP_LESS_EQUAL = (ULA_IN_2 <= ULA_IN_1) ? 1'b1 :
                                 1'b0;
    assign ULA_COMP_GREATER = (ULA_IN_2 > ULA_IN_1) ? 1'b1 :
                              1'b0;
    assign ULA_COMP_LESS = (ULA_IN_2 < ULA_IN_1) ? 1'b1 :
                           1'b0;

    assign ULA_LOGIC_NOT = ~ULA_IN_1;
    assign ULA_LOGIC_AND = ULA_IN_2 & ULA_IN_1;
    assign ULA_LOGIC_OR = ULA_IN_2 | ULA_IN_1;
    assign ULA_LOGIC_XOR = ULA_IN_2 ^ ULA_IN_1;

    assign ULA_OUT = (SEL_ULA == 4'b0000) ? ULA_MATH_ADD :
                     (SEL_ULA == 4'b0001) ? ULA_MATH_SUB :
                     (SEL_ULA == 4'b0010) ? ULA_MATH_MULT :
                     (SEL_ULA == 4'b0011) ? ULA_LSHIFT :
                     (SEL_ULA == 4'b0100) ? ULA_RSHIFT :
                     (SEL_ULA == 4'b0101) ? ULA_LOGIC_OR :
                     (SEL_ULA == 4'b0110) ? ULA_LOGIC_AND :
                     (SEL_ULA == 4'b0111) ? ULA_LOGIC_XOR :
                     (SEL_ULA == 4'b1000) ? ULA_LOGIC_NOT :
                     {DATA_WIDTH{1'b0}};

    assign ULA_COMP_OUT = (SEL_ULA == 4'b1001) ? ULA_COMP_EQUAL :
                          (SEL_ULA == 4'b1010) ? ULA_COMP_DIFFERENT :
                          (SEL_ULA == 4'b1011) ? ULA_COMP_GREATER :
                          (SEL_ULA == 4'b1100) ? ULA_COMP_LESS :
                          (SEL_ULA == 4'b1101) ? ULA_COMP_GREATER_EQUAL :
                          (SEL_ULA == 4'b1110) ? ULA_COMP_LESS_EQUAL :
                          1'b0;

    assign ULA_OVERFLOW_OUT = ((SEL_ULA == 4'b0000) && ((ULA_IN_2 + ULA_IN_1) > 255)) ? 1'b1 :
                              ((SEL_ULA == 4'b0001) && ((ULA_IN_2 - ULA_IN_1) < 0)) ? 1'b1 :
                              ((SEL_ULA == 4'b0010) && ((ULA_IN_2 * ULA_IN_1) > 255)) ? 1'b1 :
                              ((SEL_ULA == 4'b0011) && ((ULA_IN_2 << ULA_IN_1) > 255)) ? 1'b1 :
                              ((SEL_ULA == 4'b0100) && ((ULA_IN_2 >> ULA_IN_1) > 255)) ? 1'b1 :
                              1'b0;
    // -------------------------------
    // CONNECTIONS
    assign ULA_IN_1 = REG1_OUT;
    assign ULA_IN_2 = REG2_OUT;
endmodule
