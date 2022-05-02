`timescale 1ns/1ns

module pool_layer_tb(

   );


reg clk	;
reg rst	;

reg en;
reg signed [15:0] data;
reg [31:0] cnt;
wire signed [15:0] out;
wire va;
wire c;


pool_layer u0(
	.pclk(clk),
	.rst(rst),
	.image_size(20),
	.map_iva(en),
	.map_in(data) ,
	.map_out(out),
	.map_ova(va),
    .xclk(c)
);

initial
begin
    clk=0;
    rst=1;
	en=0;
	data=0;
	cnt=0;
	
    #1000
	data= $random() % 20;
    rst=0;
	en=1;
	cnt=0;
	
	
end

always #100 clk = ~clk;

always #200 
begin
	data= $random() % 20;
	if(cnt <= (400-1))
    begin
		cnt = cnt+1;
        
    end
	else
		en = 0;
    
    
end

endmodule
