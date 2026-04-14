// file: MIPS_SCP_tb.v
// Testbench for MIPS_SCP

`timescale 1ns/1ns

module MIPS_SCP_tb;

	//Inputs
	reg clk;
    reg reset;

	//Outputs


	//Instantiation of Unit Under Test
	MIPS_SCP uut (
		.clk(clk),
		.reset(reset)
	);

    always
        #50 clk=!clk;
	initial begin
		clk = 0;
		reset = 1;
		#100;
		reset = 0;

		repeat(300) @(posedge clk);

		$writememb("generated/outputs/dmem.bin", uut.dmem.Dmem, 0, 255);
		$writememb("generated/outputs/reg.bin", uut.datapathcomp.RF.register, 0, 31);
		$writememb("generated/outputs/imem.bin", uut.imem.Imem, 0, 255);

		$display("Simulation done. Dumped generated/outputs/*.bin");
		$finish;
	end
endmodule