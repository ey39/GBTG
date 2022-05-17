module  image_reshape
(
    input   wire                    sys_clk         ,
    input   wire                    sys_rst_n       ,
    input   wire                    pi_data_valid   ,
    input   wire    signed  [15:0]  pi_data         ,
    
    output  reg                     po_data_valid   ,
    output  reg     signed  [15:0]  po_data             
);

parameter   COL_MAX = 10'd1023;
parameter   ROW_MAX = 10'd767;

reg     [9:0]       cnt_col;
reg     [9:0]       cnt_row;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_col <= 10'd0;
    else    if(pi_data_valid == 1'b1 && cnt_col == COL_MAX)
        cnt_col <= 10'd0;
    else    if(pi_data_valid == 1'b1)
        cnt_col <= cnt_col + 1'b1;
    else
        cnt_col <= cnt_col;
        
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_row <= 10'd0;
    else    if(pi_data_valid == 1'b1 && cnt_col == COL_MAX && cnt_row == ROW_MAX)
        cnt_row <= 10'd0;
    else    if(pi_data_valid == 1'b1 && cnt_col == COL_MAX)
        cnt_row <= cnt_row + 1'b1;
    else
        cnt_row <= cnt_row;
        
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        po_data_valid <= 1'b0;
    else    if((cnt_col >= 10'd304 && cnt_col <= 10'd719) && (cnt_row >= 176 && cnt_row <= 10'd592))
        po_data_valid <= 1'b1;
    else
        po_data_valid <= 1'b0;
        
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        po_data <= 16'd0;
    else    if(po_data_valid == 1'b1)
        po_data <= pi_data;
    else
        po_data <= po_data;

endmodule
        
