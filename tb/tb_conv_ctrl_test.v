`timescale 1ns/1ns

module tb_conv_ctrl_test();

reg         sys_clk      ;
reg         sys_rst_n    ;
//reg [8:0]   image_size   ;
//reg         padding      ;
//reg         stride       ;
reg [15:0]  pi_data      ;
reg         pi_data_valid;
reg [15:0]  weight1      ;
reg [15:0]  weight2      ;
reg [15:0]  weight3      ;
reg [15:0]  weight4      ;
reg [15:0]  weight5      ;
reg [15:0]  weight6      ;
reg [15:0]  weight7      ;
reg [15:0]  weight8      ;
reg [15:0]  weight9      ;
reg [15:0]  bias         ;
//reg [15:0]  average      ;
//reg [15:0]  std          ;
                         
wire [15:0]  po_data     ;
wire         po_data_valid;
wire         frame_valid;


initial
    begin
        sys_clk = 1'b1;
        sys_rst_n <= 1'b0;
        #20
        sys_rst_n <= 1'b1; 
    end
    
always #20 sys_clk = ~sys_clk;



always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            weight1 <= 16'd0;
            weight2 <= 16'd0;
            weight3 <= 16'd0;
            weight4 <= 16'd0;
            weight5 <= 16'd0;
            weight6 <= 16'd0;
            weight7 <= 16'd0;
            weight8 <= 16'd0;
            weight9 <= 16'd0;
            bias <= 16'd0;
        end
    else
        begin
            //weight1 <= {$random} % 1;
            //weight2 <= {$random} % 1;
            //weight3 <= {$random} % 1;
            //weight4 <= {$random} % 1;
            //weight5 <= {$random} % 1;
            //weight6 <= {$random} % 1;
            //weight7 <= {$random} % 1;
            //weight8 <= {$random} % 1;
            //weight9 <= {$random} % 1;
            weight1 <= 16'd1; 
            weight2 <= 16'd1;
            weight3 <= 16'd1;
            weight4 <= 16'd1;
            weight5 <= 16'd1;
            weight6 <= 16'd1;
            weight7 <= 16'd1;
            weight8 <= 16'd1;
            weight9 <= 16'd1;
            bias <= 16'd0;         
        end



always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            pi_data <= 16'd0;
            pi_data_valid <= 1'b0;
        end
    else
        begin
            //pi_data <= -16'd3;
            pi_data <= $random % 10;
            //pi_data_valid <={$random} % 2;
             pi_data_valid <= 1'b1;
        end

/*always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            average <= 16'd0;
            std <= 16'd0;
        end
    else
        begin
            average <= 16'd1;
            std <= 16'd2;
        end*/

conv_ctrl_test conv_ctrl_test_inst
(
    .sys_clk      (sys_clk      ),
    .sys_rst_n    (sys_rst_n    ),
    .image_size   (9'd5       ),
    //.padding      (1'b0         ),
    //.stride       (1'b1         ),
    .pi_data      (pi_data      ),
    .pi_data_valid(pi_data_valid),
    .weight1      (weight1      ),
    .weight2      (weight2      ),
    .weight3      (weight3      ),
    .weight4      (weight4      ),
    .weight5      (weight5      ),
    .weight6      (weight6      ),
    .weight7      (weight7      ),
    .weight8      (weight8      ),
    .weight9      (weight9      ),
    .bias         (bias         ),
    //.average      (average      ),
    //.std          (std          ),

    .po_data      (po_data      ),
    .po_data_valid(po_data_valid),
    .frame_valid  (frame_valid  )
);

endmodule