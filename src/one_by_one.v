module  one_by_one
(
    input   wire                      sys_clk         ,
    input   wire                      sys_rst_n       ,
    input   wire              [8:0]   image_size      ,
    input   wire                      pi_data_valid   ,
    input   wire    signed    [15:0]  pi_data         ,
    input   wire    signed    [15:0]  weight          ,
    input   wire    signed    [15:0]  bias            ,
    
    output  reg                       po_data_valid   ,
    output  reg     signed    [15:0]  po_data         ,
    output  reg                       frame_valid     
);


reg                        [8:0]   cnt_col     ;
reg                        [8:0]   cnt_row     ;
wire    signed             [32:0]  buffer1     ;
reg     signed             [15:0]  buffer11    ;
reg     signed             [16:0]  buffer2     ;
reg     signed             [15:0]  buffer22    ;
reg                                add1_flag   ;
reg                                add2_flag   ;
reg                                add3_flag   ;
reg                                add4_flag   ;


//图像列计数
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_col <= 9'd0;
    else    if((cnt_col == (image_size - 1'b1)) && pi_data_valid == 1'b1)
        cnt_col <= 9'd0;
    else    if(pi_data_valid == 1'b1)
        cnt_col <= cnt_col + 1'b1;
    else
        cnt_col <= cnt_col;


//图像行计数 
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_row <= 9'd0;
    else    if((cnt_col == (image_size - 1'b1)) && (pi_data_valid == 1'b1) && (cnt_row == (image_size - 1'b1)))
        cnt_row <= 9'd0;
    else    if((cnt_col == (image_size - 1'b1)) && pi_data_valid == 1'b1)
        cnt_row <= cnt_row + 1'b1;
    else
        cnt_row <= cnt_row;  
        
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        add1_flag <= 1'b0;
    else    if(pi_data_valid == 1'b1)
        add1_flag <= 1'b1;
    else
        add1_flag <= 1'b0;
        
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        add2_flag <= 1'b0;
    else    if(add1_flag == 1'b1)
        add2_flag <= 1'b1;
    else
        add2_flag <= 1'b0;
        
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        add3_flag <= 1'b0;
    else    if(add2_flag == 1'b1)
        add3_flag <= 1'b1;
    else
        add3_flag <= 1'b0;
        
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        add4_flag <= 1'b0;
    else    if(add3_flag == 1'b1)
        add4_flag <= 1'b1;
    else
        add4_flag <= 1'b0;
        
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        buffer11 <= 16'd0;
    else    if(add1_flag == 1'b1)
        buffer11 <= {buffer1[32],buffer1[14:0]};
    else
        buffer11 <= buffer11;
        
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        buffer2 <= 17'd0;
    else    if(add2_flag == 1'b1)
        buffer2 <= buffer11 + bias;
    else
        buffer2 <= buffer2;
        
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        buffer22 <= 16'd0;
    else    if(add3_flag == 1'b1)
        buffer22 <= {buffer2[16],buffer2[14:0]};
    else
        buffer22 <= buffer22;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        po_data_valid <= 1'b0;
    else    if(add4_flag == 1'b1)
        po_data_valid <= 1'b1;
    else
        po_data_valid <= 1'b0;
        
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        po_data <= 16'd0;
    else    if(add4_flag == 1'd1)
        po_data <= buffer22;
    else
        po_data <= po_data;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        frame_valid <= 1'b0;
    else    if((cnt_row == image_size - 1'b1) && (cnt_col == image_size - 1'b1))
        frame_valid <= 1'b1;
    else
        frame_valid <= 1'b0;
        
multiply_adder multiply_adder_inst1
(
  .a0(pi_data),            // input [15:0]
  .a1(16'd0),            // input [15:0]
  .b0(weight),       // input [15:0]
  .b1(16'd0),       // input [15:0]
  .clk(sys_clk),      // input
  .rst(~sys_rst_n),   // input
  .ce(pi_data_valid),      // input
  .addsub(1'b0),      // input
  .p(buffer1)       // output [32:0]
);

endmodule