`timescale 1ns/1ns

module conv_padding_tb(

   );


reg clk	;
reg rst	;

reg en;
reg signed [15:0] data;
reg [31:0] cnt;
wire signed [15:0] out;
wire va;


conv_padding cp(
	.p_clk		(clk		),
	.rst		(rst		),
	.i_data		(data		),
	.i_valid	(en			),
	.image_size	(20			),
	.o_data		(out		),
	.o_valid    (va    		)
);

initial
begin
    clk=0;
    rst=1;
	en=0;
	data=0;
	cnt=0;
	
    #1000
    rst=0;
	en=1;
	cnt=0;
	data= $random() % 20;
	
end

always #100 clk = ~clk;

always #200 
begin
	if(cnt <= 1600)
    begin
		data= $random() % 20;
		cnt = cnt+1;
		if(rst==0 && cnt <=400) 		en = 1;
		else if(cnt<600) 				en = 0;
		else if(cnt<=1000) 				en = 1;
		else if(cnt<1200) 				en = 0;
		else if(cnt<=1600) 				en = 1;
    end
    else
		en = 0;
    
end

endmodule
