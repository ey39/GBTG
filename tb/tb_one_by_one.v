`timescale 1ns/1ns

module tb_one_by_one();

reg     sys_clk;
reg     sys_rst_n;
reg     pi_data_valid;
reg     signed  [15:0]  pi_data;
reg     signed  [15:0]  weight;
reg     signed  [15:0]  bias;

wire    po_data_valid;
wire    signed  [15:0]  po_data;
wire    frame_valid;

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
            weight <= 16'd0;
            bias <= 16'd0;        
        end
    else
        begin
            weight <= 16'd1;
            bias <= 16'd0;  
        end
        
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            pi_data_valid <= 1'b0;
            pi_data <= 16'd0;
        end
    else
        begin
            pi_data_valid <= 1'b1;
            pi_data <= $random % 10;       
        end

one_by_one one_by_one_inst
(
    .sys_clk      (sys_clk      )  ,
    .sys_rst_n    (sys_rst_n    )  ,
    .image_size   (9'd5  )  ,
    .pi_data_valid(pi_data_valid)  ,
    .pi_data      (pi_data      )  ,
    .weight       (weight       )  ,
    .bias         (bias         )  ,
                   
    .po_data_valid(po_data_valid)  ,
    .po_data      (po_data      )  ,
    .frame_valid  (frame_valid  )  
);        
        
endmodule
        
