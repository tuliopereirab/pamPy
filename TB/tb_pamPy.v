module TB_PAMPY ();

reg tb_clk, tb_reset;
wire [11:0] TB_PC_OUT;
wire [7:0] TB_INSTR_OUT, TB_ARG_OUT, TB_TOP_STACK;

initial begin
    tb_clk = 0;
    tb_reset = 0;
    #2 tb_reset = 1;
    #15 tb_reset = 0;
end

always
    #10 tb_clk = !tb_clk;

pamPy #() pamPy_arc (
    .general_clk (tb_clk),
    .general_reset (tb_reset),
    .GENERAL_PC_OUT (TB_PC_OUT),
    .GENERAL_INSTR_OUT (TB_INSTR_OUT),
    .GENERAL_ARG_OUT (TB_ARG_OUT),
    .TOP_STACK_OUT (TB_TOP_STACK)
    );

endmodule
