module conv_weights(
	input 				pclk,
	input 				rst_n,
	//输入为10个数据
	input  [15:0] 		wr_data,
	input 				wr_en,
	
	output [15:0] 	weights_1_1,
	output [15:0] 	weights_1_2,
	output [15:0] 	weights_1_3,
	output [15:0] 	weights_2_1,
	output [15:0] 	weights_2_2,
	output [15:0] 	weights_2_3,
	output [15:0] 	weights_3_1,
	output [15:0] 	weights_3_2,
	output [15:0] 	weights_3_3,
	output [15:0] 	bias,
	
	output 	reg 	weights_ready
);

reg 		wr_en_d0;
reg [15:0] 	weights [9:0];
reg	[3:0]	ptr;

assign weights_1_1 = weights_ready ? weights[0] : 16'b0;
assign weights_1_2 = weights_ready ? weights[1] : 16'b0;
assign weights_1_3 = weights_ready ? weights[2] : 16'b0;
assign weights_2_1 = weights_ready ? weights[3] : 16'b0;
assign weights_2_2 = weights_ready ? weights[4] : 16'b0;
assign weights_2_3 = weights_ready ? weights[5] : 16'b0;
assign weights_3_1 = weights_ready ? weights[6] : 16'b0;
assign weights_3_2 = weights_ready ? weights[7] : 16'b0;
assign weights_3_3 = weights_ready ? weights[8] : 16'b0;
assign bias 	   = weights_ready ? weights[9] : 16'b0;

always@(posedge pclk or negedge rst_n)
begin
	if(!rst_n)
		begin
			weights[0] <= 16'b0;
			weights[1] <= 16'b0;
			weights[2] <= 16'b0;
			weights[3] <= 16'b0;
			weights[4] <= 16'b0;
			weights[5] <= 16'b0;
			weights[6] <= 16'b0;
			weights[7] <= 16'b0;
			weights[8] <= 16'b0;
			weights[9] <= 16'b0;
		end
	else
		if(wr_en)
			begin
				if(ptr<=4'd9)
                begin
					weights[0] <= weights[1];
					weights[1] <= weights[2];
					weights[2] <= weights[3];
					weights[3] <= weights[4];
					weights[4] <= weights[5];
					weights[5] <= weights[6];
					weights[6] <= weights[7];
					weights[7] <= weights[8];
					weights[8] <= weights[9];
					weights[9] <= wr_data;
                end
				else 
                begin
					weights[0] <= weights[0];
					weights[1] <= weights[1];
					weights[2] <= weights[2];
					weights[3] <= weights[3];
					weights[4] <= weights[4];
					weights[5] <= weights[5];
					weights[6] <= weights[6];
					weights[7] <= weights[7];
					weights[8] <= weights[8];
					weights[9] <= weights[9];
                end
			end
		else
			begin
				weights[0] <= weights[0];
				weights[1] <= weights[1];
				weights[2] <= weights[2];
				weights[3] <= weights[3];
				weights[4] <= weights[4];
				weights[5] <= weights[5];
				weights[6] <= weights[6];
				weights[7] <= weights[7];
				weights[8] <= weights[8];
				weights[9] <= weights[9];
			end
end

always@(posedge pclk or negedge rst_n)
begin
	if(!rst_n)
		wr_en_d0 <= 1'b0;
	else
		wr_en_d0 <= wr_en;
end

always@(posedge pclk or negedge rst_n)
begin
	if(!rst_n)
		ptr <= 4'b0;
	else
		if(wr_en)
			ptr <= ptr + 4'b1;
		else 
			ptr <= 4'b0;
			
end

always@(posedge pclk or negedge rst_n)
begin
	if(!rst_n)
		weights_ready <= 1'b0;
	else
		if(wr_en && (!wr_en_d0))
			weights_ready <= 1'b0;
		else if(ptr == 9)
			weights_ready <= 1'b1;
		else
			weights_ready <= weights_ready;
end

endmodule