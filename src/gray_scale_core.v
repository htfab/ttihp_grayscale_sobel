module gray_scale_core (
	clk_i,
	nreset_i,
	px_rdy_i,
	in_px_rgb_i,
	out_px_gray_o,
	px_rdy_o
);
	input wire clk_i;
	input wire nreset_i;
	input wire px_rdy_i;
	localparam MAX_PIXEL_BITS = 24;
	input wire [23:0] in_px_rgb_i;
	localparam PIXEL_WIDTH_OUT = 8;
	output reg [7:0] out_px_gray_o;
	output reg px_rdy_o;
	wire [7:0] red;
	wire [7:0] green;
	wire [7:0] blue;
	always @(posedge clk_i or negedge nreset_i)
		if (!nreset_i) begin
			out_px_gray_o <= 'b0;
			px_rdy_o <= 'b0;
		end
		else begin
			px_rdy_o <= px_rdy_i;
			out_px_gray_o <= (((((red >> 2) + (red >> 5)) + (green >> 1)) + (green >> 4)) + (blue >> 4)) + (blue >> 5);
		end
	assign red = in_px_rgb_i[23:16];
	assign green = in_px_rgb_i[15:8];
	assign blue = in_px_rgb_i[7:0];
endmodule
