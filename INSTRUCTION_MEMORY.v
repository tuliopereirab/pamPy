// Quartus II Verilog Template
// Single Port ROM

module INSTRUCTION_MEMORY
#(parameter DATA_WIDTH_MEM=8, parameter INSTRUCTION_WIDTH_MEM=16, parameter ADDR_WIDTH_MEM=12)
(
	input [(ADDR_WIDTH_MEM-1):0] addr,
	input clk_mem,
	output wire [(INSTRUCTION_WIDTH_MEM-1):0] DATA_FULL_OUT,
	output wire [(DATA_WIDTH_MEM-1):0] DATA_ARG_OUT, DATA_INSTR_OUT
);

	reg [(INSTRUCTION_WIDTH_MEM-1):0] DATA_TEMP;

	// Declare the ROM variable
	reg [INSTRUCTION_WIDTH_MEM-1:0] rom[2**ADDR_WIDTH_MEM-1:0];

	// Initialize the ROM with $readmemb.  Put the memory contents
	// in the file single_port_rom_init.txt.  Without this file,
	// this design will not compile.

	// See Verilog LRM 1364-2001 Section 17.2.8 for details on the
	// format of this file, or see the "Using $readmemb and $readmemh"
	// template later in this section.

	initial
	begin
		//$readmemb("MEMORY_INICIALIZATION/1.txt", rom);
	end

	always @ (posedge clk_mem)
	begin
		DATA_TEMP <= rom[addr];
	end

	assign DATA_FULL_OUT = DATA_TEMP;
	assign DATA_INSTR_OUT = DATA_TEMP[(DATA_WIDTH_MEM-1):0];
	assign DATA_ARG_OUT = DATA_TEMP[(INSTRUCTION_WIDTH_MEM-1):DATA_WIDTH_MEM];

endmodule
