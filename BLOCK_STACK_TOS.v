module BLOCK_STACK_TOS #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 12
    )(
        input clk, reset,
        input [(DATA_WIDTH-1):0] MUX_STACK_IN_0,       // ula
        input [(DATA_WIDTH-1):0] MUX_STACK_IN_2,       // reg data return'
        input [(DATA_WIDTH-1):0] MUX_STACK_IN_3,        // reg arg
        input [(ADDR_WIDTH-1):0] MEMORY_ADDR_IN,         // REG JUMP
        input [(ADDR_WIDTH-1):0] MUX_TOS_IN_1,        // STACK_TOS_RETURN
        //controls
        input [2:0] SEL_MUX_STACK,
        input CTRL_REG_READ_STACK, CTRL_REG_WRITE_STACK,
        input CTRL_REG_READ_MEM, CTRL_REG_WRITE_MEM,
        input SEL_MUX_TOS, CTRL_REG_TOS, SEL_TOS_UPDATER,
        input CTRL_STACK, CTRL_MEM_EXT,
        //outputs
        output reg [(DATA_WIDTH-1):0] REG_STACK_OUT_READ,
        output reg [(ADDR_WIDTH-1):0] REG_TOS_OUT,
        output wire [(DATA_WIDTH-1):0] TOP_STACK
    );
wire [(DATA_WIDTH-1):0] MUX_STACK_OUT;
wire [(ADDR_WIDTH-1):0] MUX_TOS_OUT;
wire [(DATA_WIDTH-1):0] STACK_OUT, MEM_EXT_OUT;
reg [(ADDR_WIDTH-1):0] REG_ADDR_OUT;
// regs memories
reg [(DATA_WIDTH-1):0] REG_WRITE_STACK_OUT;
reg [(DATA_WIDTH-1):0] REG_READ_MEMORY_OUT, REG_WRITE_MEMORY_OUT;
// tos updater
wire [(ADDR_WIDTH-1):0] TOS_UPDATER_OP_ADD, TOS_UPDATER_OP_SUB, TOS_UPDATER_OUT;
// -----------------------------------------
assign TOP_STACK = STACK_OUT;
// -----------------------------------------


    always @ (posedge clk)      // REG TOS
    begin
        if(reset)
            REG_TOS_OUT <= 0;
        else if(CTRL_REG_TOS)
            REG_TOS_OUT <= MUX_TOS_OUT;
    end

// --------------------------
//STACK
    always @ (posedge clk) // REG READ STACK
    begin
        if(CTRL_REG_READ_STACK)
            REG_STACK_OUT_READ <= STACK_OUT;
    end
    always @ (posedge clk)          // reg write stack
    begin
        if(CTRL_REG_WRITE_STACK)
            REG_WRITE_STACK_OUT <= MUX_STACK_OUT;
    end

// ----------------------------
// MEM EXT
    always @ (posedge clk) // REG READ STACK
    begin
        if(CTRL_REG_READ_MEM)
            REG_READ_MEMORY_OUT <= MEM_EXT_OUT;
    end
    always @ (posedge clk)          // reg write stack
    begin
        if(CTRL_REG_WRITE_MEM)
            REG_WRITE_MEMORY_OUT <= REG_STACK_OUT_READ;
    end
// ----------------------------
// tos updater
    assign TOS_UPDATER_OP_ADD = REG_TOS_OUT + 1;
    assign TOS_UPDATER_OP_SUB = REG_TOS_OUT - 1;
    assign TOS_UPDATER_OUT = (SEL_TOS_UPDATER == 1'b0) ? TOS_UPDATER_OP_ADD :
                             TOS_UPDATER_OP_SUB;
// ----------------------------
    assign MUX_STACK_OUT =  (SEL_MUX_STACK == 3'b000) ? MUX_STACK_IN_0 :
                            (SEL_MUX_STACK == 3'b001) ? REG_READ_MEMORY_OUT :
                            (SEL_MUX_STACK == 3'b010) ? MUX_STACK_IN_2 :
                            (SEL_MUX_STACK == 3'b011) ? MUX_STACK_IN_3 :
                            (SEL_MUX_STACK == 3'b100) ? REG_STACK_OUT_READ :
                            MUX_STACK_IN_0;     // most used

    assign MUX_TOS_OUT = (SEL_MUX_TOS == 1'b0) ? TOS_UPDATER_OUT :
                         MUX_TOS_IN_1;      // stack function return


    STACK_MEMORY #(
        .DATA_WIDTH_MEM (DATA_WIDTH),
        .ADDR_WIDTH_MEM (ADDR_WIDTH)
        ) mem_ext (
            .clk_mem (clk),
            .DATA_IN (REG_WRITE_MEMORY_OUT),
            .ADDR_IN (MEMORY_ADDR_IN),
            .CTRL_MEM_WRITE (CTRL_MEM_EXT),
            .DATA_OUT (MEM_EXT_OUT)
        );

    STACK_MEMORY #(
        .DATA_WIDTH_MEM (DATA_WIDTH),
        .ADDR_WIDTH_MEM (ADDR_WIDTH)
        ) stack (
            .clk_mem (clk),
            .DATA_IN (REG_WRITE_STACK_OUT),
            .ADDR_IN (REG_TOS_OUT),
            .CTRL_MEM_WRITE (CTRL_STACK),
            .DATA_OUT (STACK_OUT)
        );

endmodule
