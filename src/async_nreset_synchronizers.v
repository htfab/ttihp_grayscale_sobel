module spi_dep_async_nreset_synchronizer (
	clk_i,
	async_nreset_i,
	tied_value_i,
	nreset_o
);
	input wire clk_i;
	input wire async_nreset_i;
	input wire tied_value_i;
	output reg nreset_o;
	reg r_sync;
	always @(posedge clk_i or negedge async_nreset_i)
		if (!async_nreset_i)
			{nreset_o, r_sync} <= 2'b00;
		else
			{nreset_o, r_sync} <= {r_sync, tied_value_i};
endmodule
module spi_dep_signal_synchronizer (
	clk_i,
	nreset_i,
	async_signal_i,
	signal_o
);
	input wire clk_i;
	input wire nreset_i;
	input wire async_signal_i;
	output reg signal_o;
	reg signal_sync;
	always @(posedge clk_i or negedge nreset_i)
		if (!nreset_i)
			{signal_o, signal_sync} <= 1'sb0;
		else
			{signal_o, signal_sync} <= {signal_sync, async_signal_i};
endmodule
