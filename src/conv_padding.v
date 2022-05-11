module conv_padding(
	input 						p_clk,
	input 						rst,
	input 	signed [15:0]		i_data,
	input 						i_valid,
	input 	[10:0]				image_size,
	output 	signed [15:0]		o_data,
	output						o_valid
);

reg [10:0] vcnt;
reg [10:0] hcnt;
reg [10:0] size_latch;
reg i_valid_d0;
reg valid_d0;
reg signed [15:0] od;

wire start;
wire valid;
wire pad;
wire rd_en;
wire signed [15:0] rd_data;

assign start = i_valid && (!i_valid_d0);
assign valid = (size_latch!=11'b0) && (vcnt < size_latch);
assign pad = (hcnt == 11'b0) || (hcnt == size_latch - 1'b1) || (vcnt == 11'b0) || (vcnt == size_latch - 1'b1);
assign rd_en = valid && (vcnt > 11'b0) && (vcnt < (size_latch - 1'b1)) && (hcnt <= (size_latch - 3));
assign o_valid = valid_d0;
assign o_data = o_valid ? od : 16'b0;
assign prst = !(o_valid || i_valid);

//delay
always@(posedge p_clk or posedge rst)
begin
	if(rst)
		i_valid_d0 <= 1'b0;
	else
		i_valid_d0 <= i_valid;
end

always@(posedge p_clk or posedge rst)
begin
	if(rst)
		valid_d0 <= 1'b0;
	else
		valid_d0 <= valid;
end

//size
always@(posedge p_clk or posedge rst)
begin
	if(rst)
		size_latch <= 11'b0;
	else if(start)
		size_latch <= image_size + 11'd2;
	else if(!valid)
		size_latch <= 11'b0;
	else
		size_latch <= size_latch;
end

//hcnt
always@(posedge p_clk or posedge rst)
begin
	if(rst)
		hcnt <= 11'b0;
	else if(hcnt == (size_latch - 11'b1) || (!valid))
		hcnt <= 11'b0;
	else
		hcnt <= hcnt + 1'b1;
end

//vcnt
always@(posedge p_clk or posedge rst)
begin
	if(rst)
		vcnt <= 11'b0;
	else if(hcnt == (size_latch - 11'b1) && valid)
		vcnt <= vcnt + 1'b1;
	else if(start)
		vcnt <= 11'b0;
	else
		vcnt <= vcnt;
end


always@(posedge p_clk or posedge rst)
begin
	if(rst)
		od <= 16'd0;
	else if(pad)
		od <= 16'd21;
	else
		od <= rd_data;
end


padf fu (
  .clk(p_clk),                      // input
  .rst(rst || prst),                      // input
  .wr_en(i_valid),                  // input
  .wr_data(i_data),              // input [15:0]
  .wr_full(),              // output
  .almost_full(),      // output
  .rd_en(rd_en),                  // input
  .rd_data(rd_data),              // output [15:0]
  .rd_empty(),            // output
  .almost_empty()     // output
);


endmodule