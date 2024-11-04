module sobel_control (
	clk_i,
	nreset_i,
	start_sobel_i,
	px_rdy_i,
	in_px_sobel_i,
	out_px_sobel_o,
	px_rdy_o
);
	reg _sv2v_0;
	input wire clk_i;
	input wire nreset_i;
	input wire start_sobel_i;
	input wire px_rdy_i;
	localparam PIXEL_WIDTH_OUT = 8;
	input wire [7:0] in_px_sobel_i;
	output wire [7:0] out_px_sobel_o;
	output reg px_rdy_o;
	localparam MAX_PIXEL_BITS = 24;
	localparam SOBEL_COUNTER_MAX_BITS = 3;
	localparam MAX_GRADIENT_WIDTH = 10;
	localparam MAX_PIXEL_VAL = 256;
	localparam MAX_GRADIENT_SUM_WIDTH = 11;
	localparam MAX_RESOLUTION_BITS = 24;
	localparam ZERO_PAD_WIDTH = 16;
	reg [SOBEL_COUNTER_MAX_BITS:0] counter_sobel;
	reg [23:0] counter_pixels;
	reg px_ready;
	reg [71:0] sobel_pixels;
	wire [7:0] out_sobel_core;
	reg [7:0] out_sobel;
	reg [2:0] fsm_state;
	reg [2:0] next;
	sobel_core sobel(
		.pix0_0($signed(sobel_pixels[71-:8])),
		.pix0_1($signed(sobel_pixels[63-:8])),
		.pix0_2($signed(sobel_pixels[55-:PIXEL_WIDTH_OUT])),
		.pix1_0($signed(sobel_pixels[47-:8])),
		.pix1_1($signed(sobel_pixels[39-:8])),
		.pix1_2($signed(sobel_pixels[31-:PIXEL_WIDTH_OUT])),
		.pix2_0($signed(sobel_pixels[23-:8])),
		.pix2_1($signed(sobel_pixels[15-:8])),
		.pix2_2($signed(sobel_pixels[7-:PIXEL_WIDTH_OUT])),
		.out_sobel_core_o(out_sobel_core)
	);
	always @(posedge clk_i or negedge nreset_i)
		if (!nreset_i)
			fsm_state <= 3'd0;
		else
			fsm_state <= next;
	always @(*) begin
		if (_sv2v_0)
			;
		case (fsm_state)
			3'd0:
				if (start_sobel_i)
					next = 3'd1;
				else
					next = 3'd0;
			3'd1:
				if (counter_pixels == 1)
					next = 3'd2;
				else
					next = 3'd1;
			3'd2:
				if (start_sobel_i == 0)
					next = 3'd1;
				else
					next = 3'd2;
			default: next = 3'd0;
		endcase
	end
	always @(posedge clk_i or negedge nreset_i)
		if (!nreset_i) begin
			counter_sobel <= 'b0;
			counter_pixels <= 'b0;
			px_ready <= 'b0;
			sobel_pixels[71-:24] <= 1'sb0;
			sobel_pixels[47-:24] <= 1'sb0;
			sobel_pixels[23-:24] <= 1'sb0;
		end
		else
			case (next)
				3'd0: begin
					px_ready <= 'b0;
					counter_pixels <= 'b0;
					counter_sobel <= 'b0;
				end
				3'd1: begin
					px_ready <= 'b0;
					if (px_rdy_i) begin
						case (counter_sobel)
							0: sobel_pixels[71-:8] <= in_px_sobel_i;
							1: sobel_pixels[63-:8] <= in_px_sobel_i;
							2: sobel_pixels[55-:PIXEL_WIDTH_OUT] <= in_px_sobel_i;
							3: sobel_pixels[47-:8] <= in_px_sobel_i;
							4: sobel_pixels[39-:8] <= in_px_sobel_i;
							5: sobel_pixels[31-:PIXEL_WIDTH_OUT] <= in_px_sobel_i;
							6: sobel_pixels[23-:8] <= in_px_sobel_i;
							7: sobel_pixels[15-:8] <= in_px_sobel_i;
							8: sobel_pixels[7-:PIXEL_WIDTH_OUT] <= in_px_sobel_i;
						endcase
						counter_sobel <= counter_sobel + 1;
						if (counter_sobel == 8) begin
							counter_pixels <= counter_pixels + 1;
							counter_sobel <= 'b0;
							px_ready <= 'b1;
						end
					end
				end
				3'd2: begin
					px_ready <= 'b0;
					if (px_rdy_i) begin
						case (counter_sobel)
							0: begin
								sobel_pixels[71-:24] <= sobel_pixels[47-:24];
								sobel_pixels[47-:24] <= sobel_pixels[23-:24];
								sobel_pixels[23-:8] <= in_px_sobel_i;
							end
							1: sobel_pixels[15-:8] <= in_px_sobel_i;
							2: sobel_pixels[7-:PIXEL_WIDTH_OUT] <= in_px_sobel_i;
						endcase
						counter_sobel <= counter_sobel + 1;
						if (counter_sobel == 2) begin
							counter_pixels <= counter_pixels + 1;
							counter_sobel <= 'b0;
							px_ready <= 'b1;
						end
					end
				end
				default: begin
					px_ready <= 'b0;
					counter_pixels <= 'b0;
					counter_sobel <= 'b0;
				end
			endcase
	always @(posedge clk_i or negedge nreset_i)
		if (!nreset_i) begin
			out_sobel <= 1'sb0;
			px_rdy_o <= 1'sb0;
		end
		else begin
			px_rdy_o <= 1'sb0;
			if (px_ready) begin
				out_sobel <= out_sobel_core;
				px_rdy_o <= px_ready;
			end
		end
	assign out_px_sobel_o = out_sobel;
	initial _sv2v_0 = 0;
endmodule
