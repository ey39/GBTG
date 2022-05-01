module conv_pe(
	input pclk,
	input rst,
	input signed [15:0]		w00,
	input signed [15:0]		w01,
	input signed [15:0]		w02,
	input signed [15:0]		w10,
	input signed [15:0]		w11,
	input signed [15:0]		w12,
	input signed [15:0]		w20,
	input signed [15:0]		w21,
	input signed [15:0]		w22,
	input signed [15:0]		row0_in,
	input signed [15:0]		row1_in,
	input signed [15:0]		row2_in,
	input 					pe_en,
	output 					map_va,
	output signed [15:0]	map_out
);

reg [4:0] en;
reg signed [15:0] sum;
reg signed [15:0] r0_0;
reg signed [15:0] r0_1;
reg signed [15:0] r0_2;
reg signed [15:0] r1_0;
reg signed [15:0] r1_1;
reg signed [15:0] r1_2;
reg signed [15:0] r2_0;
reg signed [15:0] r2_1;
reg signed [15:0] r2_2;

wire signed [15:0] w0_0;
wire signed [15:0] w0_1;
wire signed [15:0] w0_2;
wire signed [15:0] w1_0;
wire signed [15:0] w1_1;
wire signed [15:0] w1_2;
wire signed [15:0] w2_0;
wire signed [15:0] w2_1;
wire signed [15:0] w2_2;

assign map_out = map_va ? sum : 16'd0;
assign map_va  = en[4];

always@(posedge pclk or posedge rst)
begin
	if(rst)
		en <= 5'd0;
	else
		en <= {en[4:0],pe_en};
end

MUT M00 (
  .a(row0_in),        // input [15:0]
  .b(w00),        // input [15:0]
  .clk(pclk),    // input
  .rst(rst),    // input
  .ce(pe_en),      // input
  .p(w0_0)         // output [31:0]
);

MUT M01 (
  .a(row0_in),        // input [15:0]
  .b(w01),        // input [15:0]
  .clk(pclk),    // input
  .rst(rst),    // input
  .ce(pe_en),      // input
  .p(w0_1)         // output [31:0]
);

MUT M02 (
  .a(row0_in),        // input [15:0]
  .b(w02),        // input [15:0]
  .clk(pclk),    // input
  .rst(rst),    // input
  .ce(pe_en),      // input
  .p(w0_2)         // output [31:0]
);

MUT M10 (
  .a(row1_in),        // input [15:0]
  .b(w10),        // input [15:0]
  .clk(pclk),    // input
  .rst(rst),    // input
  .ce(pe_en),      // input
  .p(w1_0)         // output [31:0]
);

MUT M11 (
  .a(row1_in),        // input [15:0]
  .b(w11),        // input [15:0]
  .clk(pclk),    // input
  .rst(rst),    // input
  .ce(pe_en),      // input
  .p(w1_1)         // output [31:0]
);

MUT M12 (
  .a(row1_in),        // input [15:0]
  .b(w12),        // input [15:0]
  .clk(pclk),    // input
  .rst(rst),    // input
  .ce(pe_en),      // input
  .p(w1_2)         // output [31:0]
);

MUT M20 (
  .a(row2_in),        // input [15:0]
  .b(w20),        // input [15:0]
  .clk(pclk),    // input
  .rst(rst),    // input
  .ce(pe_en),      // input
  .p(w2_0)         // output [31:0]
);

MUT M21 (
  .a(row2_in),        // input [15:0]
  .b(w21),        // input [15:0]
  .clk(pclk),    // input
  .rst(rst),    // input
  .ce(pe_en),      // input
  .p(w2_1)         // output [31:0]
);

MUT M22 (
  .a(row2_in),        // input [15:0]
  .b(w22),        // input [15:0]
  .clk(pclk),    // input
  .rst(rst),    // input
  .ce(pe_en),      // input
  .p(w2_2)         // output [31:0]
);


always@(posedge pclk or posedge rst)
begin
	if(rst)
		begin
			r0_0 <= 16'd0; 		r0_1 <= 16'd0; 			r0_2 <= 16'd0;
			r1_0 <= 16'd0; 		r1_1 <= 16'd0; 			r1_2 <= 16'd0;
			r2_0 <= 16'd0; 		r2_1 <= 16'd0; 			r2_2 <= 16'd0;
			sum  <= 16'd0;
		end
	else
		if(pe_en)
			begin
				r0_0 <= w0_0; 	r0_1 <= w0_1 + r0_0; 	r0_2 <= w0_2 + r0_1;
				r1_0 <= w1_0; 	r1_1 <= w1_1 + r1_0; 	r1_2 <= w1_2 + r1_1;
				r2_0 <= w2_0; 	r2_1 <= w2_1 + r2_0; 	r2_2 <= w2_2 + r2_1;
				sum <= r0_2 + r1_2 + r2_2;
			end
		else
			begin
				r0_0 <= r0_0; 	r0_1 <= r0_1; 			r0_2 <= r0_2;
				r1_0 <= r1_0; 	r1_1 <= r1_1; 			r1_2 <= r1_2;
				r2_0 <= r2_0; 	r2_1 <= r2_1; 			r0_2 <= r2_2;
				sum <= sum;
			end
end


endmodule