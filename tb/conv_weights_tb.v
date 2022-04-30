`timescale 1ns/1ns

module conv_weights_tb(

   );

reg clk	;
reg rst	;
reg [15:0] data;
reg en;

wire [15:0] w1_1;
wire [15:0] w1_2;
wire [15:0] w1_3;
wire [15:0] w2_1;
wire [15:0] w2_2;
wire [15:0] w2_3;
wire [15:0] w3_1;
wire [15:0] w3_2;
wire [15:0] w3_3;
wire [15:0] bias;
wire ready;

conv_weights u0(
	.pclk(clk),
	.rst_n(!rst),
	.wr_data(data),
	.wr_en(en),
	.weights_1_1(w1_1),
	.weights_1_2(w1_2),
	.weights_1_3(w1_3),
	.weights_2_1(w2_1),
	.weights_2_2(w2_2),
	.weights_2_3(w2_3),
	.weights_3_1(w3_1),
	.weights_3_2(w3_2),
	.weights_3_3(w3_3),
	.bias(bias)  ,  
    .weights_ready (ready)
);

initial
begin
    clk=0;
    rst=1;
	data=0;
	en=0;
	
    #1000
    rst=0;
	en=1;
	
end

always #100 clk = ~clk;

always #3000 en = ~en;

always #200 
begin
	if(en)
		data <= (data-64);
	else
		data <= 1;
end

endmodule
