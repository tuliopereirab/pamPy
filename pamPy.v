module pamPy #(
    parameter GENERAL_DATA_WIDTH = 8,
    parameter GENERAL_ADDR_WIDTH = 12,
    parameter GENERAL_INSTRUCTION_WIDTH = 16
    )(
        input general_clk, general_reset,
        output wire [(GENERAL_ADDR_WIDTH-1):0] GENERAL_PC_OUT,
        output wire [(GENERAL_DATA_WIDTH-1):0] GENERAL_INSTR_OUT, GENERAL_ARG_OUT, TOP_STACK_OUT,
        output wire GENERAL_FINISH
    );

// block 1
    // CONTROLS
wire GENERAL_CTRL_REG_OP1, GENERAL_CTRL_REG_OP2, GENERAL_CTRL_STACK_COMP;
wire [3:0] GENERAL_SEL_ULA;
    //outputs
wire [(GENERAL_DATA_WIDTH-1):0] GENERAL_ULA_OUT;
wire GENERAL_REG_OVERFLOW_OUT, GENERAL_STACK_COMP_OUT;
// ----------------------------------------------------------------------------
//block 2
wire [(GENERAL_ADDR_WIDTH-1):0] GENERAL_STACK_FUNCTION_OUT;
    // CONTROLS
wire GENERAL_CTRL_REG_ARG, GENERAL_CTRL_REG_INSTR, GENERAL_CTRL_REG_JUMP, GENERAL_CTRL_REG_PC, GENERAL_SEL_PC_UPDATER;
wire [1:0] GENERAL_SEL_MUX_PC;

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
wire GENERAL_CTRL_REG_READ_STACK, GENERAL_CTRL_REG_WRITE_STACK;
wire GENERAL_CTRL_REG_READ_MEMORY, GENERAL_CTRL_REG_WRITE_MEMORY;
wire [2:0] GENERAL_SEL_MUX_STACK;
wire GENERAL_SEL_TOS_UPDATER;
wire GENERAL_SEL_MUX_TOS, GENERAL_CTRL_REG_TOS, GENERAL_CTRL_STACK, GENERAL_CTRL_MEM_EXT;
// ----------------------------------------------------------------------------
assign GENERAL_PC_OUT = GENERAL_REG_PC;
assign GENERAL_INSTR_OUT = GENERAL_REG_INSTR;
assign GENERAL_ARG_OUT = GENERAL_REG_ARG;
// ----------------------------------------------------------------------------
BLOCK_ULA_OPS #(
    .DATA_WIDTH (GENERAL_DATA_WIDTH),
    .ADDR_WIDTH (GENERAL_ADDR_WIDTH)
    ) block_1 (
        .clk (general_clk),
        .REG_IN (GENERAL_STACK_OUT),
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

BLOCK_PC_INSTR_ARG #(
    .DATA_WIDTH (GENERAL_DATA_WIDTH),
    .ADDR_WIDTH (GENERAL_ADDR_WIDTH),
    .INSTRUCTION_WIDTH (GENERAL_INSTRUCTION_WIDTH)
    ) block_2 (
        .clk (general_clk),
        .reset (general_reset),
        .MUX_IN_4 (GENERAL_STACK_FUNCTION_OUT),
        .REG_ARG_OUT (GENERAL_REG_ARG),
        .REG_INSTR_OUT (GENERAL_REG_INSTR),
        .REG_JUMP_OUT (GENERAL_REG_JUMP),
        .REG_PC_OUT (GENERAL_REG_PC),        // used only as general output
        //CONTROLS
        .CTRL_REG_ARG (GENERAL_CTRL_REG_ARG),
        .CTRL_REG_INSTR (GENERAL_CTRL_REG_INSTR),
        .CTRL_REG_PC (GENERAL_CTRL_REG_PC),
        .CTRL_REG_JUMP (GENERAL_CTRL_REG_JUMP),
        .SEL_PC_UPDATER (GENERAL_SEL_PC_UPDATER),
        .SEL_MUX (GENERAL_SEL_MUX_PC)
    );

BLOCK_FUNCTIONS #(
    .DATA_WIDTH (GENERAL_DATA_WIDTH),
    .ADDR_WIDTH (GENERAL_ADDR_WIDTH)
    ) block_3 (
        .clk (general_clk),
        .reset (general_reset),
        .STACK_FUNCTION_IN (GENERAL_REG_PC),
        .STACK_TOS_IN (GENERAL_REG_TOS),
        .REG_DATA_RETURN_IN (GENERAL_STACK_OUT),
        //contrls
        .CTRL_REG_TOS_FUNCTION (GENERAL_CTRL_REG_TOS_FUNCTION),
        .CTRL_STACK_FUNCTION (GENERAL_CTRL_STACK_FUNCTION),
        .SEL_SOMADOR_SUBTRATOR (GENERAL_SEL_SOMADOR_SUBTRATOR),
        .CTRL_REG_DATA_RETURN (GENERAL_CTRL_REG_DATA_RETURN),
        //outputs
        .STACK_FUNCTION_OUT (GENERAL_STACK_FUNCTION_OUT),
        .STACK_TOS_OUT (GENERAL_STACK_TOS_OUT),
        .REG_DATA_RETURN_OUT (GENERAL_REG_DATA_RETURN_OUT)
    );

BLOCK_STACK_TOS #(
    .DATA_WIDTH (GENERAL_DATA_WIDTH),
    .ADDR_WIDTH (GENERAL_ADDR_WIDTH)
    ) block_4 (
        .clk (general_clk),
        .reset (general_reset),
        .MUX_STACK_IN_0 (GENERAL_ULA_OUT),
        .MUX_STACK_IN_2 (GENERAL_REG_DATA_RETURN_OUT),
        .MUX_STACK_IN_3 (GENERAL_REG_ARG),
        .MEMORY_ADDR_IN (GENERAL_REG_JUMP),
        .MUX_TOS_IN_1 (GENERAL_STACK_TOS_OUT),
        //controls
        .SEL_MUX_STACK (GENERAL_SEL_MUX_STACK),
        .CTRL_REG_READ_STACK (GENERAL_CTRL_REG_READ_STACK),
        .CTRL_REG_WRITE_STACK (GENERAL_CTRL_REG_WRITE_STACK),
        .CTRL_REG_READ_MEM (GENERAL_CTRL_REG_READ_MEMORY),
        .CTRL_REG_WRITE_MEM (GENERAL_CTRL_REG_WRITE_MEMORY),
        .SEL_MUX_TOS (GENERAL_SEL_MUX_TOS),
        .CTRL_REG_TOS (GENERAL_CTRL_REG_TOS),
        .SEL_TOS_UPDATER (GENERAL_SEL_TOS_UPDATER),
        .CTRL_STACK (GENERAL_CTRL_STACK),
        .CTRL_MEM_EXT (GENERAL_CTRL_MEM_EXT),
        // outputs
        .REG_STACK_OUT_READ (GENERAL_STACK_OUT),
        .REG_TOS_OUT (GENERAL_REG_TOS),
        .TOP_STACK (TOP_STACK_OUT)
    );

CONTROL_UNIT #(
    .DATA_WIDTH (GENERAL_DATA_WIDTH),
    .ADDR_WIDTH (GENERAL_ADDR_WIDTH),
    .INSTRUCTION_WIDTH (GENERAL_INSTRUCTION_WIDTH)
    ) control (
        .clk (general_clk),
        .reset (general_reset),
        .INSTR_IN (GENERAL_REG_INSTR),
        .ARG_IN (GENERAL_REG_ARG),
        .COMPARE_IN (GENERAL_STACK_COMP_OUT),
        .OVERFLOW_IN (GENERAL_REG_OVERFLOW_OUT),
        .TOS_IN (GENERAL_REG_TOS),
        // outputs
        .CTRL_REG_TOS_FUNCTION (GENERAL_CTRL_REG_TOS_FUNCTION),
        .SEL_SOMADOR_SUBTRATOR (GENERAL_SEL_SOMADOR_SUBTRATOR),
        .CTRL_STACK_FUNCTION (GENERAL_CTRL_STACK_FUNCTION),
        .CTRL_REG_DATA_RETURN (GENERAL_CTRL_REG_DATA_RETURN),
        .SEL_PC_UPDATER (GENERAL_SEL_PC_UPDATER),
        .SEL_TOS_UPDATER (GENERAL_SEL_TOS_UPDATER),
        .CTRL_STACK (GENERAL_CTRL_STACK),
        .CTRL_MEM_EXT (GENERAL_CTRL_MEM_EXT),
        .CTRL_REG_OP1 (GENERAL_CTRL_REG_OP1),
        .CTRL_REG_OP2 (GENERAL_CTRL_REG_OP2),
        .CTRL_STACK_COMP (GENERAL_CTRL_STACK_COMP),
        .SEL_ULA (GENERAL_SEL_ULA),
        .CTRL_REG_READ_STACK (GENERAL_CTRL_REG_READ_STACK),
        .CTRL_REG_WRITE_STACK (GENERAL_CTRL_REG_WRITE_STACK),
        .CTRL_REG_READ_MEMORY (GENERAL_CTRL_REG_READ_MEMORY),
        .CTRL_REG_WRITE_MEMORY (GENERAL_CTRL_REG_WRITE_MEMORY),
        .CTRL_REG_ARG (GENERAL_CTRL_REG_ARG),
        .CTRL_REG_INSTR (GENERAL_CTRL_REG_INSTR),
        .CTRL_REG_JUMP (GENERAL_CTRL_REG_JUMP),
        .CTRL_REG_PC (GENERAL_CTRL_REG_PC),
        .SEL_MUX_TOS (GENERAL_SEL_MUX_TOS),
        .SEL_MUX_PC (GENERAL_SEL_MUX_PC),
        .CTRL_REG_TOS (GENERAL_CTRL_REG_TOS),
        .SEL_MUX_STACK (GENERAL_SEL_MUX_STACK),
        .FINISH_SIGN (GENERAL_FINISH)
    );
endmodule
