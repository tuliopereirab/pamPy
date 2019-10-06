module BLOCK_ULA_OPS #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 12,
    parameter ULA_WIDTH = 24
    ) (
        input clk,
        input [(ADDR_WIDTH-1):0] MUX_REG1_IN,                   // regJump
        input [(DATA_WIDTH-1):0] REG1_IN,
        input [(DATA_WIDTH-1):0] MUX_REG2_IN_0, // regArg
        input [(ADDR_WIDTH-1):0] MUX_REG2_IN_1, // tos
        input [(ADDR_WIDTH-1):0] MUX_REG2_IN_2, // pc
        input [(DATA_WIDTH-1):0] REG2_IN,
        output wire [(ULA_WIDTH-1):0] ULA_OUT,
        output reg REG_COMP_OUT,
        output reg REG_OVERFLOW_OUT,
        // CONTROLS
        input SEL_MUX1,
        input [1:0] SEL_MUX2,
        input CTRL_REG_OP1, CTRL_REG_OP2,
        input CTRL_REG_OVERFLOW, CTRL_REG_COMP,
        input [3:0] SEL_ULA
    );

reg [(DATA_WIDTH-1):0] REG1_OUT, REG2_OUT;
wire [(ULA_WIDTH-1):0] MUX1_OUT, MUX2_OUT;
wire [(ULA_WIDTH-1):0] ULA_IN_1, ULA_IN_2;
wire ULA_COMP_OUT, ULA_OVERFLOW_OUT;
wire [(ULA_WIDTH-1):0] ULA_MATH_ADD, ULA_MATH_SUB, ULA_MATH_MULT, ULA_MATH_DIV;
wire [(ULA_WIDTH-1):0] ULA_DATA1, ULA_DATA2;
wire [(ULA_WIDTH-1):0] ULA_MATH_PLUS1, ULA_MATH_LESS1, ULA_MATH_PLUS2;
wire ULA_COMP_EQUAL, ULA_COMP_BIGGER, ULA_COMP_SMALLER;
wire [(ULA_WIDTH-1):0] ULA_LOGIC_NOT, ULA_LOGIC_AND, ULA_LOGIC_OR, ULA_LOGIC_XOR;


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

    always @ (posedge clk)  // REG_COMP
    begin
        if(CTRL_REG_COMP)
            REG_COMP_OUT <= ULA_COMP_OUT;
    end
    always @ (posedge clk) // REG_OVERFLOW
    begin
        if(CTRL_REG_OVERFLOW)
            REG_OVERFLOW_OUT <= ULA_OVERFLOW_OUT;
    end

    // -------------------------------
    // ula
    assign ULA_MATH_ADD = ULA_IN_2 + ULA_IN_1;
    assign ULA_MATH_SUB = ULA_IN_2 - ULA_IN_1;
    assign ULA_MATH_MULT = ULA_IN_2 * ULA_IN_1;
    assign ULA_MATH_DIV = {ULA_WIDTH{1'b0}};
    assign ULA_DATA1 = ULA_IN_1;
    assign ULA_DATA2 = ULA_IN_2;
    assign ULA_MATH_PLUS1 = ULA_IN_2 + {ULA_WIDTH{1'b1}};
    assign ULA_MATH_LESS1 = ULA_IN_2 - {ULA_WIDTH{1'b1}};
    assign ULA_MATH_PLUS2 = ULA_IN_2 + {ULA_WIDTH/2{2'b10}};
    assign ULA_COMP_EQUAL = (ULA_IN_2 == ULA_IN_1) ? 1'b1 :
                            1'b0;
    assign ULA_COMP_BIGGER = (ULA_IN_2 > ULA_IN_1) ? 1'b1 :
                             1'b0;
    assign ULA_COMP_SMALLER = (ULA_IN_2 < ULA_IN_1) ? 1'b1 :
                              1'b0;
    assign ULA_LOGIC_NOT = ~ULA_IN_1;
    assign ULA_LOGIC_AND = ULA_IN_2 & ULA_IN_1;
    assign ULA_LOGIC_OR = ULA_IN_2 | ULA_IN_1;
    assign ULA_LOGIC_XOR = ULA_IN_2 ^ ULA_IN_1;

    assign ULA_OUT = (SEL_ULA == 4'b0000) ? ULA_MATH_ADD :
                     (SEL_ULA == 4'b0001) ? ULA_MATH_SUB :
                     (SEL_ULA == 4'b0010) ? ULA_MATH_MULT :
                     (SEL_ULA == 4'b0011) ? ULA_MATH_DIV :
                     (SEL_ULA == 4'b0100) ? ULA_DATA1 :
                     (SEL_ULA == 4'b0101) ? ULA_DATA2 :
                     (SEL_ULA == 4'b0110) ? ULA_MATH_PLUS1 :
                     (SEL_ULA == 4'b0111) ? ULA_MATH_LESS1 :
                     (SEL_ULA == 4'b1000) ? ULA_MATH_PLUS2 :
                     (SEL_ULA == 4'b1100) ? ULA_LOGIC_NOT :
                     (SEL_ULA == 4'b1101) ? ULA_LOGIC_AND :
                     (SEL_ULA == 4'b1110) ? ULA_LOGIC_OR :
                     (SEL_ULA == 4'b1111) ? ULA_LOGIC_XOR :
                     {ULA_WIDTH{1'b0}};

    assign ULA_COMP_OUT = (SEL_ULA == 4'b1001) ? ULA_COMP_EQUAL :
                          (SEL_ULA == 4'b1010) ? ULA_COMP_SMALLER :
                          (SEL_ULA == 4'b1011) ? ULA_COMP_BIGGER :
                          1'b0;

    assign ULA_OVERFLOW_OUT = ((SEL_ULA == 4'b0000) && (ULA_MATH_ADD > 255)) ? 1'b1 :
                              ((SEL_ULA == 4'b0001) && (ULA_MATH_SUB < 0)) ? 1'b1 :
                              ((SEL_ULA == 4'b0010) && (ULA_MATH_MULT > 255)) ? 1'b1 :
                              1'b0;
    // -------------------------------
    // muxes
    assign MUX1_OUT = (SEL_MUX1 == 2'b00) ? {ULA_WIDTH{1'b0}} :
                      (SEL_MUX1 == 2'b01) ? {ULA_WIDTH{1'b1}} :
                      (SEL_MUX1 == 2'b10) ? MUX_REG1_IN :   // REG JUMP
                      (SEL_MUX1 == 2'b11) ? REG1_OUT :      // regOp1
                      {ULA_WIDTH{1'b0}};

    assign MUX2_OUT = (SEL_MUX2 == 2'b00) ? MUX_REG2_IN_2 :   // REG PC
                      (SEL_MUX2 == 2'b01) ? MUX_REG2_IN_1 :
                      (SEL_MUX2 == 2'b10) ? MUX_REG2_IN_0 :
                      (SEL_MUX2 == 2'b11) ? REG2_OUT :      // regOp2
                      {ULA_WIDTH{1'b0}};
    // --------------------------------
    // CONNECTIONS
    assign ULA_IN_1 = MUX1_OUT;
    assign ULA_IN_2 = MUX2_OUT;
endmodule
