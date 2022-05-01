`timescale 1ns/1ns

module conv_pe_tb(

   );


reg clk	;
reg rst	;

reg en;
reg signed [15:0] data1;
reg signed [15:0] data2;
reg signed [15:0] data3;
wire signed [15:0] out;
wire va;
wire signed [15:0] w0 = -1;
wire signed [15:0] w1 = -2;
wire signed [15:0] w2 = -1;
wire signed [15:0] w3 = 0;
wire signed [15:0] w4 = 0;
wire signed [15:0] w5 = 0;
wire signed [15:0] w6 = 1;
wire signed [15:0] w7 = 2;
wire signed [15:0] w8 = 1;

conv_pe u0(
	.pclk(clk),
	.rst(rst),
	.w00(w0),
	.w01(w1),
	.w02(w2),
	.w10(w3),
	.w11(w4),
	.w12(w5),
	.w20(w6),
	.w21(w7),
	.w22(w8),
	.row0_in(data1),
	.row1_in(data2),
	.row2_in(data3),
	.pe_en(en),
	.map_va(va),
	.map_out(out)
);

initial
begin
    clk=0;
    rst=1;
	en=0;
	data1=0;
	data2=0;
	data3=0;
	
    #1000
	data1= $random % 20;
	data2= $random % 20;
	data3= $random % 20;
    rst=0;
	en=1;
	
	
end

always #100 clk = ~clk;

always #200 
begin
	data1= $random() % 20;
	data2= $random() % 20;
	data3= $random() % 20;
end

endmodule
