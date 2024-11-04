module top_gray_sobel (
	clk_i,
	nreset_i,
	select_i,
	start_sobel_i,
	px_rdy_i,
	in_pixel_i,
	out_pixel_o,
	px_rdy_o
);
	reg _sv2v_0;
	input wire clk_i;
	input wire nreset_i;
	input wire [1:0] select_i;
	input wire start_sobel_i;
	input wire px_rdy_i;
	localparam MAX_PIXEL_BITS = 24;
	input wire [23:0] in_pixel_i;
	output reg [23:0] out_pixel_o;
	output reg px_rdy_o;
	reg px_rdy_i_sobel;
	wire select_sobel_mux;
	localparam PIXEL_WIDTH_OUT = 8;
	wire [7:0] in_px_sobel;
	wire [7:0] out_px_gray;
	wire [7:0] out_px_sobel;
	wire px_rdy_o_gray;
	wire px_rdy_o_sobel;
	gray_scale_core gray_scale0(
		.clk_i(clk_i),
		.nreset_i(nreset_i),
		.px_rdy_i(px_rdy_i),
		.in_px_rgb_i(in_pixel_i),
		.out_px_gray_o(out_px_gray),
		.px_rdy_o(px_rdy_o_gray)
	);
	sobel_control sobel0(
		.clk_i(clk_i),
		.nreset_i(nreset_i),
		.start_sobel_i(start_sobel_i),
		.px_rdy_i(px_rdy_i_sobel),
		.in_px_sobel_i(in_px_sobel),
		.out_px_sobel_o(out_px_sobel),
		.px_rdy_o(px_rdy_o_sobel)
	);
	assign select_sobel_mux = select_i[0];
	assign in_px_sobel = (select_sobel_mux ? in_pixel_i[7:0] : out_px_gray);
	localparam ZERO_PAD_WIDTH = 16;
	always @(*) begin
		if (_sv2v_0)
			;
		case (select_i)
			2'b00: begin
				out_pixel_o = {{ZERO_PAD_WIDTH {1'b0}}, out_px_sobel};
				px_rdy_i_sobel = px_rdy_o_gray;
				px_rdy_o = px_rdy_o_sobel;
			end
			2'b01: begin
				out_pixel_o = {{ZERO_PAD_WIDTH {1'b0}}, out_px_sobel};
				px_rdy_i_sobel = px_rdy_i;
				px_rdy_o = px_rdy_o_sobel;
			end
			2'b10: begin
				out_pixel_o = {{ZERO_PAD_WIDTH {1'b0}}, out_px_gray};
				px_rdy_i_sobel = 'b0;
				px_rdy_o = px_rdy_o_gray;
			end
			2'b11: begin
				out_pixel_o = in_pixel_i;
				px_rdy_i_sobel = 'b0;
				px_rdy_o = px_rdy_i;
			end
			default: begin
				out_pixel_o = {{ZERO_PAD_WIDTH {1'b0}}, out_px_sobel};
				px_rdy_i_sobel = px_rdy_i;
				px_rdy_o = px_rdy_o_sobel;
			end
		endcase
	end
	initial _sv2v_0 = 0;
endmodule
