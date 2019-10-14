module BLOCK_PC_INSTR_ARG #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 12,
    parameter INSTRUCTION_WIDTH = 16
    )(
        input clk, reset,
        input [(ADDR_WIDTH-1):0] MUX_IN_4,      // function_stack
        output reg [(DATA_WIDTH-1):0] REG_ARG_OUT,
        output reg [(DATA_WIDTH-1):0] REG_INSTR_OUT,
        output reg [(ADDR_WIDTH-1):0] REG_JUMP_OUT,
        output reg [(ADDR_WIDTH-1):0] REG_PC_OUT,
        // CONTROLS
        input CTRL_REG_ARG, CTRL_REG_INSTR, CTRL_REG_JUMP, CTRL_REG_PC,
        input SEL_PC_UPDATER,
        input [1:0] SEL_MUX
    );

    wire [(INSTRUCTION_WIDTH+DATA_WIDTH-1):0] CONCATENATE_REG_ARG_MEM_FULL;
    wire [(ADDR_WIDTH-1):0] MUX_OUT;
    wire [(DATA_WIDTH-1):0] MEM_ARG_OUT, MEM_INSTR_OUT;
    wire [(INSTRUCTION_WIDTH-1):0] MEM_FULL_OUT;
    wire [(ADDR_WIDTH-1):0] PC_UPDATER_OP_1, PC_UPDATER_OP_2, PC_UPDATER_OUT;
    wire [(ADDR_WIDTH-1):0] FORWARD_ADDER_OUT;

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

    // concatenate reg_arg_out and mem_full_out
    assign CONCATENATE_REG_ARG_MEM_FULL = {REG_ARG_OUT, MEM_FULL_OUT};
    always @ (posedge clk)      // regJump
    begin
        if(CTRL_REG_JUMP)
            REG_JUMP_OUT <= CONCATENATE_REG_ARG_MEM_FULL[(ADDR_WIDTH-1):0];
    end

    always @ (posedge clk)      // regPC
    begin
        if(reset)
            REG_PC_OUT <= 0;
        else if(CTRL_REG_PC)
            REG_PC_OUT <= MUX_OUT;
    end
// --------------------------------
    assign FORWARD_ADDER_OUT = REG_PC_OUT + REG_JUMP_OUT;
// --------------------------------
// PC_UPDATER
    assign PC_UPDATER_OP_1 = REG_PC_OUT + {ADDR_WIDTH{1'b1}};
    assign PC_UPDATER_OP_2 = REG_PC_OUT + {ADDR_WIDTH/2{2'b10}};

    assign PC_UPDATER_OUT = (SEL_PC_UPDATER == 1'b0) ? PC_UPDATER_OP_1 :
                            PC_UPDATER_OP_2;
    //---------------------
    assign MUX_OUT = (SEL_MUX == 2'b00) ? PC_UPDATER_OUT :
                     (SEL_MUX == 2'b01) ? REG_JUMP_OUT :
                     (SEL_MUX == 2'b10) ? FORWARD_ADDER_OUT :
                     MUX_IN_4;  // function_stack
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
