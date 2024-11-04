`default_nettype none
module tt_um_gray_sobel (
	ui_in,
	uo_out,
	uio_in,
	uio_out,
	uio_oe,
	ena,
	clk,
	rst_n
);
	input wire [7:0] ui_in;
	output wire [7:0] uo_out;
	input wire [7:0] uio_in;
	output wire [7:0] uio_out;
	output wire [7:0] uio_oe;
	input wire ena;
	input wire clk;
	input wire rst_n;
	localparam MAX_PIXEL_BITS = 24;
	wire [23:0] output_px;
	assign uo_out[7:3] = output_px[4:0];
	assign uio_out = 0;
	assign uio_oe = 0;
	wire nreset_async_i;
	assign nreset_async_i = rst_n;
	wire spi_sck_i;
	wire spi_sdi_i;
	wire spi_cs_i;
	wire spi_sdo_o;
	assign spi_sck_i = ui_in[0];
	assign spi_cs_i = ui_in[1];
	assign spi_sdi_i = ui_in[2];
	assign uo_out[0] = spi_sdo_o;
	wire [1:0] select_process_i;
	wire start_sobel_i;
	assign select_process_i = ui_in[4:3];
	assign start_sobel_i = ui_in[5];
	wire LFSR_enable_i;
	wire seed_stop_i;
	wire lfsr_en_i;
	wire lfsr_done;
	assign LFSR_enable_i = uio_in[0];
	assign seed_stop_i = uio_in[1];
	assign lfsr_en_i = uio_in[2];
	assign uo_out[1] = lfsr_done;
	assign uo_out[2] = ena;
	wire nreset_i;
	spi_dep_async_nreset_synchronizer nreset_sync0(
		.clk_i(clk),
		.async_nreset_i(nreset_async_i),
		.tied_value_i(1'b1),
		.nreset_o(nreset_i)
	);
	wire LFSR_enable_i_sync;
	spi_dep_signal_synchronizer sgnl_sync0(
		.clk_i(clk),
		.nreset_i(nreset_i),
		.async_signal_i(LFSR_enable_i),
		.signal_o(LFSR_enable_i_sync)
	);
	wire seed_stop_i_sync;
	spi_dep_signal_synchronizer sgnl_sync1(
		.clk_i(clk),
		.nreset_i(nreset_i),
		.async_signal_i(seed_stop_i),
		.signal_o(seed_stop_i_sync)
	);
	wire lfsr_en_i_sync;
	spi_dep_signal_synchronizer sgnl_sync2(
		.clk_i(clk),
		.nreset_i(nreset_i),
		.async_signal_i(lfsr_en_i),
		.signal_o(lfsr_en_i_sync)
	);
	wire [23:0] input_data;
	wire [23:0] output_data;
	wire [23:0] input_pixel;
	wire [23:0] input_lfsr_data;
	wire [23:0] output_lfsr_data;
	wire [23:0] lfsr_out_px;
	wire in_data_rdy;
	wire out_data_rdy;
	wire in_px_rdy;
	wire out_px_rdy;
	wire in_lfsr_rdy;
	wire out_lfsr_rdy;
	wire out_config_rdy;
	assign input_lfsr_data = (LFSR_enable_i_sync ? input_data : 0);
	assign input_pixel = (LFSR_enable_i_sync ? lfsr_out_px : input_data);
	assign in_lfsr_rdy = (LFSR_enable_i_sync ? in_data_rdy : 0);
	assign in_px_rdy = (LFSR_enable_i_sync ? out_lfsr_rdy : in_data_rdy);
	assign output_data = (LFSR_enable_i_sync ? output_lfsr_data : output_px);
	assign out_data_rdy = (LFSR_enable_i_sync ? out_config_rdy : out_px_rdy);
	spi_control spi0(
		.clk_i(clk),
		.nreset_i(nreset_i),
		.spi_sck_i(spi_sck_i),
		.spi_sdi_i(spi_sdi_i),
		.spi_cs_i(spi_cs_i),
		.spi_sdo_o(spi_sdo_o),
		.px_rdy_o_spi_i(out_data_rdy),
		.px_rdy_i_spi_o(in_data_rdy),
		.input_px_gray_o(input_data),
		.output_px_sobel_i(output_data)
	);
	top_gray_sobel gray_sobel0(
		.clk_i(clk),
		.nreset_i(nreset_i),
		.select_i(select_process_i),
		.start_sobel_i(start_sobel_i),
		.px_rdy_i(in_px_rdy),
		.in_pixel_i(input_pixel),
		.out_pixel_o(output_px),
		.px_rdy_o(out_px_rdy)
	);
	LFSR lfsr0(
		.clk_i(clk),
		.nreset_i(nreset_i),
		.config_i(seed_stop_i_sync),
		.config_rdy_i(in_lfsr_rdy),
		.config_data_i(input_lfsr_data),
		.config_data_o(output_lfsr_data),
		.config_done_o(out_config_rdy),
		.lfsr_en_i(lfsr_en_i_sync),
		.lfsr_out(lfsr_out_px),
		.lfsr_rdy_o(out_lfsr_rdy),
		.lfsr_done(lfsr_done)
	);
endmodule
