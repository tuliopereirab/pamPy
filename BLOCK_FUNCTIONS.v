module BLOCK_FUNCTIONS #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 12
    )(
        input clk, reset,
        input [(ADDR_WIDTH-1):0] STACK_FUNCTION_IN, STACK_TOS_IN,
        //controls
        input CTRL_REG_TOS_FUNCTION, CTRL_STACK_FUNCTION, SEL_SOMADOR_SUBTRATOR,
        //output
        output wire [(ADDR_WIDTH-1):0] STACK_FUNCTION_OUT, STACK_TOS_OUT
    );

    reg [(ADDR_WIDTH-1):0] REG_TOS_FUNCTION_OUT;
    wire [(ADDR_WIDTH-1):0] SOMADOR_SUBTRATOR_OUT;

    always @ (posedge clk) begin
        if(reset)
            REG_TOS_FUNCTION_OUT <= 0;
        else if(CTRL_REG_TOS_FUNCTION)
            REG_TOS_FUNCTION_OUT <= SOMADOR_SUBTRATOR_OUT;
    end

    assign SOMADOR_SUBTRATOR_OUT = (SEL_SOMADOR_SUBTRATOR == 1'b0) ? (REG_TOS_FUNCTION_OUT+1) :
                                   (REG_TOS_FUNCTION_OUT-1);

    STACK_MEMORY #(
        .DATA_WIDTH_MEM (ADDR_WIDTH),
        .ADDR_WIDTH_MEM (ADDR_WIDTH)
        ) stack_function (
            .clk_mem (clk),
            .DATA_IN (STACK_FUNCTION_IN),
            .ADDR_IN (REG_TOS_FUNCTION_OUT),
            //controls
            .CTRL_MEM_WRITE (CTRL_STACK_FUNCTION),
            //outputs
            .DATA_OUT (STACK_FUNCTION_OUT)
        );

    STACK_MEMORY #(
        .DATA_WIDTH_MEM (ADDR_WIDTH),
        .ADDR_WIDTH_MEM (ADDR_WIDTH)
        ) stack_tos (
            .clk_mem (clk),
            .DATA_IN (STACK_TOS_IN),
            .ADDR_IN (REG_TOS_FUNCTION_OUT),
            //controls
            .CTRL_MEM_WRITE (CTRL_STACK_FUNCTION),
            //outputs
            .DATA_OUT (STACK_FUNCTION_OUT)
        );
endmodule
