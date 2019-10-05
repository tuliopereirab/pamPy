module BLOCK_STACK_TOS #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 12,
    parameter ULA_WIDTH = 24
    )(
        input clk, reset,
        input [(DATA_WIDTH-1):0] MUX_STACK_IN_0,       // REG ARG
        input [(DATA_WIDTH-1):0] MUX_STACK_IN_2,       // REG DATA DATA_RETURN
        input [(ULA_WIDTH-1):0] MUX_STACK_TOS_IN_3,       // ULA OUT - USED FOR TOS MUX AS INPUT 0
        input [(ADDR_WIDTH-1):0] REG_ADDR_IN,         // REG JUMP
        input [(ADDR_WIDTH-1):0] MUX_TOS_IN_1,        // STACK_TOS_RETURN
        //controls
        input [1:0] SEL_MUX_STACK, CTRL_REG_MEM_EXT, CTRL_REG_STACK,
        input SEL_MUX_TOS, CTRL_REG_TOS, CTRL_STACK, CTRL_MEM_EXT, CTRL_REG_ADDR,
        //outputs
        output reg [(DATA_WIDTH-1):0] REG_STACK_OUT_READ,
        output reg [(ADDR_WIDTH-1):0] REG_TOS_OUT
    );
wire [(DATA_WIDTH-1):0] MUX_STACK_OUT;
wire [(ADDR_WIDTH-1):0] MUX_TOS_OUT;
wire [(DATA_WIDTH-1):0] STACK_OUT, MEM_EXT_OUT;
reg [(DATA_WIDTH-1):0] REG_MEM_EXT_OUT_READ, REG_MEM_EXT_OUT_WRITE;
reg [(DATA_WIDTH-1):0] REG_STACK_OUT_WRITE;
reg [(ADDR_WIDTH-1):0] REG_ADDR_OUT;

    always @ (posedge clk)      // REG ADDR
    begin
        if(CTRL_REG_ADDR)
            REG_ADDR_OUT <= REG_ADDR_IN;
    end
    always @ (posedge clk)      // REG TOS
    begin
        if(reset)
            REG_TOS_OUT <= 0;
        else if(CTRL_REG_TOS)
            REG_TOS_OUT <= MUX_TOS_OUT;
    end
    always @ (posedge clk)      // REG MEM EXT
    begin
        if(CTRL_REG_MEM_EXT == 2'b01)
            REG_MEM_EXT_OUT_READ <= MEM_EXT_OUT;
        else if(CTRL_REG_MEM_EXT == 2'b10)
            REG_MEM_EXT_OUT_WRITE <= REG_STACK_OUT_READ;
        else if(CTRL_REG_MEM_EXT == 2'b11)
        begin
            REG_MEM_EXT_OUT_READ <= MEM_EXT_OUT;
            REG_MEM_EXT_OUT_WRITE <= REG_STACK_OUT_READ;
        end
    end
    always @ (posedge clk)      // REG STACK
    begin
        if(CTRL_REG_STACK == 2'b01)
            REG_STACK_OUT_READ <= STACK_OUT;
        else if(CTRL_REG_STACK == 2'b10)
            REG_STACK_OUT_WRITE <= MUX_STACK_OUT;
        else if(CTRL_REG_STACK == 2'b11)
        begin
            REG_STACK_OUT_READ <= STACK_OUT;
            REG_STACK_OUT_WRITE <= MUX_STACK_OUT;
        end
    end

    assign MUX_STACK_OUT =  (SEL_MUX_STACK == 2'b00) ? MUX_STACK_TOS_IN_3[(DATA_WIDTH-1):0] :
                            (SEL_MUX_STACK == 2'b01) ? REG_MEM_EXT_OUT_READ :
                            (SEL_MUX_STACK == 2'b10) ? MUX_STACK_IN_2 :
                            MUX_STACK_IN_0;
    assign MUX_TOS_OUT = (SEL_MUX_TOS == 1'b0) ? MUX_STACK_TOS_IN_3[(ADDR_WIDTH-1):0] :
                         MUX_TOS_IN_1;


    STACK_MEMORY #(
        .DATA_WIDTH_MEM (DATA_WIDTH),
        .ADDR_WIDTH_MEM (ADDR_WIDTH)
        ) mem_ext (
            .clk_mem (clk),
            .DATA_IN (REG_MEM_EXT_OUT_WRITE),
            .ADDR_IN (REG_ADDR_OUT),
            .CTRL_MEM_WRITE (CTRL_MEM_EXT),
            .DATA_OUT (MEM_EXT_OUT)
        );

    STACK_MEMORY #(
        .DATA_WIDTH_MEM (DATA_WIDTH),
        .ADDR_WIDTH_MEM (ADDR_WIDTH)
        ) stack (
            .clk_mem (clk),
            .DATA_IN (REG_STACK_OUT_WRITE),
            .ADDR_IN (REG_TOS_OUT),
            .CTRL_MEM_WRITE (CTRL_STACK),
            .DATA_OUT (STACK_OUT)
        );

endmodule
