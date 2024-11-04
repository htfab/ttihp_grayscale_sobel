module spi_control (
	clk_i,
	nreset_i,
	spi_sck_i,
	spi_sdi_i,
	spi_cs_i,
	spi_sdo_o,
	input_px_gray_o,
	output_px_sobel_i,
	px_rdy_o_spi_i,
	px_rdy_i_spi_o
);
	input wire clk_i;
	input wire nreset_i;
	input wire spi_sck_i;
	input wire spi_sdi_i;
	input wire spi_cs_i;
	output wire spi_sdo_o;
	localparam MAX_PIXEL_BITS = 24;
	output wire [23:0] input_px_gray_o;
	input wire [23:0] output_px_sobel_i;
	input wire px_rdy_o_spi_i;
	output reg px_rdy_i_spi_o;
	reg [23:0] data_rx;
	reg [23:0] data_tx;
	wire [23:0] spi_data_rx;
	wire spi_rxtx_done;
	wire rxtx_done;
	reg rxtx_done_reg;
	spi_dep_signal_synchronizer signal_sync1(
		.clk_i(clk_i),
		.nreset_i(nreset_i),
		.async_signal_i(spi_rxtx_done),
		.signal_o(rxtx_done)
	);
	wire rxtx_done_rising;
	assign rxtx_done_rising = rxtx_done & ~rxtx_done_reg;
	always @(posedge clk_i or negedge nreset_i)
		if (!nreset_i) begin
			rxtx_done_reg <= 1'sb0;
			data_rx <= 1'sb0;
			px_rdy_i_spi_o <= 1'sb0;
		end
		else begin
			rxtx_done_reg <= rxtx_done;
			if (rxtx_done_rising) begin
				data_rx <= spi_data_rx;
				px_rdy_i_spi_o <= 1'b1;
			end
			else begin
				data_rx <= data_rx;
				px_rdy_i_spi_o <= 1'sb0;
			end
		end
	always @(posedge clk_i or negedge nreset_i)
		if (!nreset_i)
			data_tx <= 1'sb0;
		else if (px_rdy_o_spi_i)
			data_tx <= output_px_sobel_i;
	spi_core #(.WORD_SIZE(MAX_PIXEL_BITS)) spi0(
		.sck_i(spi_sck_i),
		.sdi_i(spi_sdi_i),
		.cs_i(spi_cs_i),
		.sdo_o(spi_sdo_o),
		.data_tx_i({data_tx[7:0], data_tx[15:8], data_tx[23:16]}),
		.data_rx_o({spi_data_rx[7:0], spi_data_rx[15:8], spi_data_rx[23:16]}),
		.rxtx_done_o(spi_rxtx_done)
	);
	assign input_px_gray_o = data_rx;
endmodule
