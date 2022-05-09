`timescale 1ns/1ns

module tb_conv_top();

reg             sys_clk         ;
reg             sys_rst_n       ;
//reg  [8:0]    image_size      ;
reg             pi_weight_valid ;
reg    [15:0]   pi_weight       ;
reg             pi_data_valid   ;
reg    [15:0]   pi_data         ;
//reg    [15:0]   average         ;
//reg    [15:0]   std            ;
                                
wire   [15:0]   map_out         ; 
wire            map_out_valid   ;

initial
    begin
        sys_clk = 1'b1;
        sys_rst_n <= 1'b0;
        pi_weight_valid <= 1'b0;
        pi_data_valid <= 1'b0;       
        #20
        sys_rst_n <= 1'b1;
        //pi_weight_valid <= 1'b1;
        //pi_data_valid <= 1'b1;
    end

always #20 sys_clk = ~sys_clk;

initial
    begin
        pi_weight_valid <= 1'b1;
        #1000
        pi_weight_valid <= 1'b0;
        #500
        pi_data_valid <= 1'b1;
        #2000
        pi_data_valid <= 1'b0;
        #500
        pi_weight_valid <= 1'b1;
        #500
        pi_weight_valid <= 1'b0;
        #2000
        pi_data_valid <= 1'b1;
        #500
        pi_weight_valid <= 1'b0;
    end

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            pi_weight <= 16'd0;
            pi_data <= 16'd0;
        end
    else
        begin
            pi_weight <= 16'd1;
            pi_data <= $random % 10;       
        end


conv_top conv_top_inst
(
   .sys_clk         (sys_clk        ),
   .sys_rst_n       (sys_rst_n      ),
   .image_size      (9'd5           ),
   .pi_weight_valid (pi_weight_valid),
   .pi_weight       (pi_weight      ),
   .pi_data_valid   (pi_data_valid  ),
   .pi_data         (pi_data        ),
   //.frame_num       (10'd5          ),
   .average        (16'd1           ),
   .std            (16'd2           ),

   .map_out         (map_out        ), 
   .map_out_valid   (map_out_valid  )
);

endmodule