module LFSR (
	clk_i,
	nreset_i,
	config_i,
	config_rdy_i,
	config_data_i,
	config_done_o,
	config_data_o,
	lfsr_en_i,
	lfsr_out,
	lfsr_rdy_o,
	lfsr_done
);
	reg _sv2v_0;
	input wire clk_i;
	input wire nreset_i;
	input wire config_i;
	input wire config_rdy_i;
	localparam MAX_PIXEL_BITS = 24;
	input wire [23:0] config_data_i;
	output reg config_done_o;
	output wire [23:0] config_data_o;
	input wire lfsr_en_i;
	output reg [23:0] lfsr_out;
	output reg lfsr_rdy_o;
	output wire lfsr_done;
	reg [23:0] seed_reg;
	reg [23:0] stop_reg;
	assign config_data_o = (config_i ? stop_reg : seed_reg);
	always @(posedge clk_i or negedge nreset_i)
		if (!nreset_i) begin
			seed_reg <= 1'sb0;
			stop_reg <= 1'sb0;
			config_done_o <= 1'sb0;
		end
		else begin
			config_done_o <= config_rdy_i;
			case ({config_i, config_rdy_i})
				2'b01: seed_reg <= config_data_i;
				2'b11: stop_reg <= config_data_i;
				default: begin
					seed_reg <= seed_reg;
					stop_reg <= stop_reg;
				end
			endcase
		end
	reg r_xnor;
	wire stop_done;
	always @(posedge clk_i or negedge nreset_i)
		if (!nreset_i) begin
			lfsr_out <= 1'sb0;
			lfsr_rdy_o <= 1'sb0;
		end
		else if (lfsr_en_i & ~stop_done) begin
			lfsr_out <= {lfsr_out[22:0], r_xnor};
			lfsr_rdy_o <= 1'b1;
		end
		else if (stop_done) begin
			lfsr_out <= lfsr_out;
			lfsr_rdy_o <= 1'sb0;
		end
		else begin
			lfsr_out <= seed_reg;
			lfsr_rdy_o <= 1'sb0;
		end
	always @(*) begin
		if (_sv2v_0)
			;
		r_xnor = lfsr_out[12] ~^ lfsr_out[3];
	end
	assign stop_done = (lfsr_out[23:0] == stop_reg ? 1'b1 : 1'b0);
	assign lfsr_done = stop_done;
	initial _sv2v_0 = 0;
endmodule
