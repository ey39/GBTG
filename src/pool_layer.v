module pool_layer(
	input 			pclk,
	input			rst,
	input  [8:0]   	image_size,
	input 			map_iva,
	input  [15:0] 	map_in ,
	output [15:0]	map_out,
	output 			map_ova,
	output			xclk
);

reg  pclk_d;
reg 		[ 4:0] map_iva_d0;
reg 		[ 4:0] cmp_en_d0;
reg 		[ 4:0] rd_en_d0;
reg  signed [15:0] max;
reg  signed [15:0] row0_d0;
reg  signed [15:0] row1_d0;
reg  signed [15:0] row1_d1;
reg  signed [15:0] row1_d2;
reg         [ 8:0] cnt_col;
reg         [ 8:0] cnt_row;
reg  signed [15:0] cmp;
wire signed [15:0] row0;
wire signed [15:0] row1;
wire signed [15:0] cmpp;
wire signed [15:0] cmp0;
wire signed [15:0] cmp1;
wire rd_en;
wire rd_en1;
wire rd_en2;
wire wr_en1;
wire shift_en;

assign cmp0 = (row0_d0 > row0) ? row0_d0 : row0;
assign cmp1 = (row1_d0 > row1_d1) ? row1_d0 : row1_d1;
assign cmpp  = (cmp0 > cmp1) ? cmp0 : cmp1;
assign map_out = max;
assign rd_en = (cnt_row == 0) ? 1'b0 : 1'b1; 
assign rd_en1 = rd_en || rd_en_d0[1]; 
assign rd_en2 = map_iva_d0[0] || map_iva_d0[1];
assign shift_en = rd_en2;
assign cmp_en = cnt_row % 2;
assign map_ova = cmp_en_d0[4];
assign xclk = pclk_d;
assign wr_en1 = map_iva || map_iva_d0[1];

always@(posedge pclk or posedge rst)
begin
	if(rst)
		map_iva_d0 <= 5'b0;
	else
		map_iva_d0 <= {map_iva_d0[3:0],map_iva};
end

always@(posedge pclk or posedge rst)
begin
	if(rst)
		cmp_en_d0 <= 5'b0;
	else
		cmp_en_d0 <= {cmp_en_d0[3:0],cmp_en};
end

always@(posedge pclk or posedge rst)
begin
	if(rst)
		rd_en_d0 <= 5'b0;
	else
		rd_en_d0 <= {rd_en_d0[3:0],rd_en};
end

//图像列计数
always@(posedge pclk or posedge rst)
    if(rst == 1'b1)
        cnt_col <= 9'd0;
    else    if(cnt_col == (image_size - 1'b1) || (map_iva == 1'b0))
        cnt_col <= 9'd0;
    else    if(map_iva == 1'b1)
        cnt_col <= cnt_col + 1'b1;
    else
        cnt_col <= cnt_col;

//图像行计数 
always@(posedge pclk or posedge rst)
    if(rst == 1'b1)
        cnt_row <= 9'd0;
	else    if(map_iva == 1'b0)
		cnt_row <= 9'd0;
    else    if((cnt_col == (image_size - 1'b1)) && (cnt_row == (image_size - 1'b1)))
        cnt_row <= 9'd0;
    else    if((cnt_col == (image_size - 1'b1)) && map_iva == 1'b1)
        cnt_row <= cnt_row + 1'b1;
    else
        cnt_row <= cnt_row;       


always@(posedge pclk or posedge rst)
begin
	if(rst)
		begin
			row0_d0 <= 16'd0; 		
			row1_d0 <= 16'd0; 	
			row1_d1 <= 16'd0;
			row1_d2 <= 16'd0;	
		end
	else
		if(shift_en)
			begin
				row0_d0 <= row0; 		
				row1_d0 <= row1;
				row1_d1 <= row1_d0;
				row1_d2 <= row1_d1;				
			end
		else	
			begin
				row0_d0 <= row0_d0; 	
				row1_d0 <= row1_d0;	
				row1_d1 <= row1_d1;
				row1_d2 <= row1_d2;			
			end
end

always@(posedge pclk_d or posedge rst)
begin
	if(rst)
		max <= 16'd0;
	else
		if(cmp_en_d0[4])
			max <= cmp;
		else
			max <= max;
end

always@(posedge pclk or posedge rst)
begin
	if(rst)
		cmp <= 16'd0;
	else
		if(cmp_en_d0[3])
			cmp <= cmpp;
		else
			cmp <= cmp;
end

//pclk二分频
always@(posedge pclk or posedge rst)
begin
	if(rst)
		pclk_d <= 1'b0;
	else
		pclk_d <= ~pclk_d;
end



fifo r0 (
  .clk(pclk),                      // input
  .rst(rst),                      // input
  .wr_en(wr_en1),                  // input
  .wr_data(row1),              // input [15:0]
  .wr_full(),              // output
  .almost_full(),      // output
  .rd_en(rd_en1),                  // input
  .rd_data(row0),              // output [15:0]
  .rd_empty(),            // output
  .almost_empty()     // output
);

fifo r1 (
  .clk(pclk),                      // input
  .rst(rst),                      // input
  .wr_en(map_iva),                  // input
  .wr_data(map_in),              // input [15:0]
  .wr_full(),              // output
  .almost_full(),      // output
  .rd_en(rd_en2),                  // input
  .rd_data(row1),              // output [15:0]
  .rd_empty(),            // output
  .almost_empty()     // output
);

endmodule