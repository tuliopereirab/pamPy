// Quartus II Verilog Template
// Single port RAM with single read/write ADDR_INess

module STACK_MEMORY
#(parameter DATA_WIDTH_MEM=8, parameter ADDR_WIDTH_MEM=12)
(
	input [(DATA_WIDTH_MEM-1):0] DATA_IN,
	input [(ADDR_WIDTH_MEM-1):0] ADDR_IN,
	input CTRL_MEM_WRITE, clk_mem,
	output wire [(DATA_WIDTH_MEM-1):0] DATA_OUT
);

	// Declare the RAM variable
	reg [DATA_WIDTH_MEM-1:0] ram[2**ADDR_WIDTH_MEM-1:0];

	// Variable to hold the registered read ADDR_INess
	reg [ADDR_WIDTH_MEM-1:0] ADDR_IN_reg;

	always @ (posedge clk_mem)
	begin
		// Write
		if (CTRL_MEM_WRITE)
			ram[ADDR_IN] <= DATA_IN;

		ADDR_IN_reg <= ADDR_IN;
	end

	// Continuous assignment implies read returns NEW DATA_IN.
	// This is the natural behavior of the TriMatrix memory
	// blocks in Single Port mode.
	assign DATA_OUT = ram[ADDR_IN_reg];

endmodule
