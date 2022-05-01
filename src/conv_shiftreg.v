module conv_shiftreg(
	input 			pclk,
	input			rst,
	input 			wr_en,
	input  [15:0] 	wr_data,
	input 			rd_en,
	input			rd_hs,
	output [15:0]	row1_out,
	output [15:0]	row2_out,
	output [15:0]	row3_out
);
wire [15:0]	row1 ;
wire [15:0]	row2 ;
wire [15:0]	row3 ;

wire rd_en1 ;
wire rd_en2 ;
wire rd_en3 ;

assign rd_en1 = rd_en;
assign rd_en2 = rd_en || en;
assign rd_en3 = 1'b1;

assign row1_out = row1;
assign row2_out = row2_d0;
assign row3_out = row3_d2;

reg en;

reg [15:0] row3_d0,row3_d1,row3_d2;
reg [15:0] row2_d0;

always@(posedge pclk or posedge rst)
begin
	if(rst)
		row3_d0 <= 16'b0;
	else
		if(rd_en3)
			row3_d0 <= row3;
		else
			row3_d0 <= 16'b0;
end

always@(posedge pclk or posedge rst)
begin
	if(rst)
		row2_d0 <= 16'b0;
	else
		if(rd_en2)
			row2_d0 <= row2;
		else
			row2_d0 <= 16'b0;
end

always@(posedge pclk or posedge rst)
begin
	if(rst)
		begin
			
			row3_d1 <= 16'b0;
			row3_d2 <= 16'b0;
		end
	else
		begin
			row3_d1 <= row3_d0 ;
			row3_d2 <= row3_d1 ;
		end
end

always@(posedge pclk or posedge rst)
begin
	if(rst)
		en <= 1'b1;
	else
		if(rd_hs)
			en <= ~en;
		else
			en <= en;
end

//3¸öfifo
ififo_16i_16o_512 line1 (
  .clk(pclk),                      // input
  .rst(rst),                      // input
  .wr_en(wr_en),                  // input
  .wr_data(row2),              // input [15:0]
  //.wr_full(wr_full),              // output
  //.almost_full(almost_full),      // output
  .rd_en(rd_en1),                  // input
  .rd_data(row1)              // output [15:0]
  //.rd_empty(rd_empty),            // output
  //.almost_empty(almost_empty)     // output
);

ififo_16i_16o_512 line2 (
  .clk(pclk),                      // input
  .rst(rst),                      // input
  .wr_en(wr_en),                  // input
  .wr_data(row3),              // input [15:0]
  //.wr_full(wr_full),              // output
  //.almost_full(almost_full),      // output
  .rd_en(rd_en2),                  // input
  .rd_data(row2)              // output [15:0]
  //.rd_empty(rd_empty),            // output
  //.almost_empty(almost_empty)     // output
);

ififo_16i_16o_512 line3 (
  .clk(pclk),                      // input
  .rst(rst),                      // input
  .wr_en(wr_en),                  // input
  .wr_data(wr_data),              // input [15:0]
  //.wr_full(wr_full),              // output
  //.almost_full(almost_full),      // output
  .rd_en(rd_en3),                  // input
  .rd_data(row3)             // output [15:0]
  //.rd_empty(rd_empty),            // output
  //.almost_empty(almost_empty)     // output
);

endmodule
