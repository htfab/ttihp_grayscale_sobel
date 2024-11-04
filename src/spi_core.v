module spi_core (
	sck_i,
	sdi_i,
	cs_i,
	sdo_o,
	data_tx_i,
	data_rx_o,
	rxtx_done_o
);
	parameter WORD_SIZE = "mandatory";
	input wire sck_i;
	input wire sdi_i;
	input wire cs_i;
	output wire sdo_o;
	input wire [WORD_SIZE - 1:0] data_tx_i;
	output reg [WORD_SIZE - 1:0] data_rx_o;
	output reg rxtx_done_o;
	localparam CNT_SIZE = $clog2(WORD_SIZE);
	wire nreset_i;
	reg [WORD_SIZE - 1:0] sdo_register;
	reg [CNT_SIZE:0] counter;
	assign nreset_i = ~cs_i;
	assign sdo_o = sdo_register[WORD_SIZE - 1];
	always @(negedge sck_i or negedge nreset_i)
		if (!nreset_i)
			counter <= 1'sb0;
		else if (counter == WORD_SIZE)
			counter <= 'h1;
		else
			counter <= counter + 1;
	always @(posedge sck_i or negedge nreset_i)
		if (!nreset_i)
			data_rx_o <= 1'sb0;
		else
			data_rx_o <= {data_rx_o[WORD_SIZE - 2:0], sdi_i};
	always @(negedge sck_i or negedge nreset_i)
		if (!nreset_i)
			sdo_register <= 1'sb0;
		else if (counter == WORD_SIZE)
			sdo_register <= data_tx_i;
		else
			sdo_register <= {sdo_register[WORD_SIZE - 2:0], 1'b0};
	always @(posedge sck_i or negedge nreset_i)
		if (!nreset_i)
			rxtx_done_o <= 1'sb0;
		else if (counter == WORD_SIZE)
			rxtx_done_o <= 1'b1;
		else
			rxtx_done_o <= 1'b0;
endmodule
