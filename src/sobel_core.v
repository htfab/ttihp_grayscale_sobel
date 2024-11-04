module sobel_core (
	pix0_0,
	pix0_1,
	pix0_2,
	pix1_0,
	pix1_1,
	pix1_2,
	pix2_0,
	pix2_1,
	pix2_2,
	out_sobel_core_o
);
	localparam PIXEL_WIDTH_OUT = 8;
	input signed [7:0] pix0_0;
	input signed [7:0] pix0_1;
	input signed [7:0] pix0_2;
	input signed [7:0] pix1_0;
	input signed [7:0] pix1_1;
	input signed [7:0] pix1_2;
	input signed [7:0] pix2_0;
	input signed [7:0] pix2_1;
	input signed [7:0] pix2_2;
	output wire [7:0] out_sobel_core_o;
	localparam MAX_PIXEL_BITS = 24;
	localparam SOBEL_COUNTER_MAX_BITS = 3;
	localparam MAX_GRADIENT_WIDTH = 10;
	localparam MAX_PIXEL_VAL = 256;
	localparam MAX_GRADIENT_SUM_WIDTH = 11;
	localparam MAX_RESOLUTION_BITS = 24;
	localparam ZERO_PAD_WIDTH = 16;
	wire signed [MAX_GRADIENT_WIDTH:0] x_grad;
	wire signed [MAX_GRADIENT_WIDTH:0] y_grad;
	wire signed [MAX_GRADIENT_WIDTH:0] abs_x_grad;
	wire signed [MAX_GRADIENT_WIDTH:0] abs_y_grad;
	wire [MAX_GRADIENT_SUM_WIDTH:0] sum_xy_grad;
	assign x_grad = ((pix0_2 - pix0_0) + ((pix1_2 - pix1_0) << 1)) + (pix2_2 - pix2_0);
	assign y_grad = ((pix2_0 - pix0_0) + ((pix2_1 - pix0_1) << 1)) + (pix2_2 - pix0_2);
	assign abs_x_grad = (x_grad[MAX_GRADIENT_WIDTH] ? ~x_grad + 1 : x_grad);
	assign abs_y_grad = (y_grad[MAX_GRADIENT_WIDTH] ? ~y_grad + 1 : y_grad);
	assign sum_xy_grad = abs_x_grad + abs_y_grad;
	assign out_sobel_core_o = (|sum_xy_grad[MAX_GRADIENT_SUM_WIDTH:PIXEL_WIDTH_OUT] ? 255 : sum_xy_grad[7:0]);
endmodule
