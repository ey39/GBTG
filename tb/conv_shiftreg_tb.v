`timescale 1ns/1ns

module conv_shiftreg_tb(

   );

reg clk	;
reg rst	;
reg [15:0] data;
reg [2:0] en;
reg [15:0] cnt;
reg [31:0] vcnt;

wire [15:0] ra;
wire [15:0] rb;
wire [15:0] rc;

localparam H = 418;

conv_shiftreg u0(
	.pclk(clk),
	.rst(rst),
	.wr_en(en[0]),
	.wr_data(data),
	.rd_en(en[1]),
	.rd_hs(en[2]),
	.row1_out(ra),
	.row2_out(rb),
	.row3_out(rc)
);

initial
begin
    clk=0;
	en=3'b000;
	cnt=0;
	vcnt=0;
	data=0;
    rst=1;
	
    #1000
	clk=0;
    rst=0;
	en=3'b001;
	cnt=0;
	vcnt=0;
	data=0;
	
end

always #100 clk = ~clk;

always #200
begin
	if(cnt == H-1)
		begin
			cnt   =0;
			en[2] =1;
			data  =1;
			vcnt  =vcnt+1;
		end
	else
		begin
			data  = data+1;
			cnt   = cnt+1;
			en[2] =0;
			if(vcnt>=2) en[1]<=1;
			else		en[1]<=0;
		end
end

endmodule
