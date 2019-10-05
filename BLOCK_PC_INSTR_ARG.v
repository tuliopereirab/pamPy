module BLOCK_PC_INSTR_ARG #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 12,
    parameter ULA_WIDTH = 24,
    parameter INSTRUCTION_WIDTH = 16
    )(
        input clk,
        input [(ULA_WIDTH-1):0] MUX_IN_0,       // ula_out
        input [(ADDR_WIDTH-1):0] MUX_IN_1,      // function_stack
        output reg [(DATA_WIDTH-1):0] REG_ARG_OUT,
        output reg [(DATA_WIDTH-1):0] REG_INSTR_OUT,
        output reg [(ADDR_WIDTH-1):0] REG_JUMP_OUT,
        output reg [(ADDR_WIDTH-1):0] REG_PC_OUT,
        // CONTROLS
        input CTRL_REG_ARG, CTRL_REG_INSTR, CTRL_REG_JUMP, CTRL_REG_PC, SEL_MUX
    );
    wire [(ADDR_WIDTH-1):0] MUX_OUT;
    wire [(DATA_WIDTH-1):0] MEM_ARG_OUT, MEM_INSTR_OUT;
    wire [(INSTRUCTION_WIDTH-1):0] MEM_FULL_OUT;

    always @ (posedge clk)
    begin
        if(CTRL_REG_ARG)        // regInstr
            REG_ARG_OUT <= MEM_ARG_OUT;
    end

    always @ (posedge clk)      // reg Instr
    begin
        if(CTRL_REG_INSTR)
            REG_INSTR_OUT <= MEM_INSTR_OUT;
    end

    always @ (posedge clk)      // regJump
    begin
        if(CTRL_REG_JUMP)
            REG_JUMP_OUT <= {REG_ARG_OUT, MEM_FULL_OUT};
    end

    always @ (posedge clk)      // regPC
    begin
        if(CTRL_REG_PC)
            REG_PC_OUT <= MUX_OUT;
    end


    //---------------------
    assign MUX_OUT = (SEL_MUX == 1'b0) ? MUX_IN_0 :
                     MUX_IN_1;
    //---------------------
    INSTRUCTION_MEMORY #(
        .DATA_WIDTH_MEM (DATA_WIDTH),
        .INSTRUCTION_WIDTH_MEM (INSTRUCTION_WIDTH),
        .ADDR_WIDTH_MEM (ADDR_WIDTH)
        ) memInstr (
            .addr (REG_PC_OUT),
            .clk_mem (clk),
            .DATA_FULL_OUT (MEM_FULL_OUT),
            .DATA_INSTR_OUT (MEM_INSTR_OUT),
            .DATA_ARG_OUT (MEM_ARG_OUT)
        );

endmodule
