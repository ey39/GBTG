module  conv_ctrl_test_1
(
    input   wire                      sys_clk      ,
    input   wire                      sys_rst_n    ,
    input   wire              [8:0]   image_size   ,
    //input   wire                      padding      ,
    //input   wire                      stride       ,  //1:步长为1，0:步长为2
    input   wire    signed    [15:0]  pi_data      ,
    input   wire                      pi_data_valid,
    input   wire    signed    [15:0]  weight1      ,
    input   wire    signed    [15:0]  weight2      ,
    input   wire    signed    [15:0]  weight3      ,
    input   wire    signed    [15:0]  weight4      ,
    input   wire    signed    [15:0]  weight5      ,
    input   wire    signed    [15:0]  weight6      ,
    input   wire    signed    [15:0]  weight7      ,
    input   wire    signed    [15:0]  weight8      ,
    input   wire    signed    [15:0]  weight9      ,
    input   wire    signed    [15:0]  bias         ,
    
    output  reg     signed    [15:0]  po_data      ,
    output  reg                       po_data_valid
);

//parameter    CNT_COL_MAX = image_size ;
//parameter    CNT_ROW_MAX = image_size ;

wire    signed            [15:0]  dout1;
wire    signed            [15:0]  dout2;
        
reg             [8:0]   cnt_col     ;
reg             [8:0]   cnt_row     ;
reg                     wr_en_1     ;
reg                     wr_en_2     ;
reg             [15:0]  wr_data_1   ;
reg             [15:0]  wr_data_2   ;
reg                     rd_en       ;
reg                     dout_flag   ;
reg             [8:0]   cnt_rd      ;
reg             [8:0]   cnt_rd_reg  ;
reg             [8:0]   cnt_rd_reg1  ;
//reg             [8:0]   cnt_rd_reg2  ;
reg                     rd_en_reg   ;
reg                     rd_en_reg1  ;
//reg                     rd_en_reg2  ;
//reg                     rd_en_reg3  ;
//reg                     rd_en_reg4  ;
reg     signed   [15:0]  dout1_reg   ;
reg     signed   [15:0]  dout2_reg   ;
reg     signed   [15:0]  pi_data_buf ;
reg     signed   [15:0]  pi_data_buf1;
reg     signed   [15:0]  pi_data_reg ;
reg     signed   [15:0]  a1          ;
reg     signed   [15:0]  a2          ;
reg     signed   [15:0]  a3          ;
reg     signed   [15:0]  b1          ;
reg     signed   [15:0]  b2          ;
reg     signed   [15:0]  b3          ;
reg     signed   [15:0]  c1          ;
reg     signed   [15:0]  c2          ;
reg     signed   [15:0]  c3          ;
wire    signed   [32:0]  buffer1_1   ;
wire    signed   [32:0]  buffer1_2   ;
wire    signed   [32:0]  buffer1_3   ;
wire    signed   [32:0]  buffer1_4   ;
wire    signed   [32:0]  buffer1_5   ;
reg   signed   [32:0]  buffer1_1_reg   ;
reg   signed   [32:0]  buffer1_2_reg   ;
reg   signed   [32:0]  buffer1_3_reg   ;
reg   signed   [32:0]  buffer1_4_reg   ;
reg   signed   [32:0]  buffer1_5_reg   ;
reg     signed   [33:0]  buffer2_1   ;
reg     signed   [33:0]  buffer2_2   ;
reg     signed   [33:0]  buffer2_3   ;
reg     signed   [15:0]  buffer2_11  ;
reg     signed   [15:0]  buffer2_22  ;
reg     signed   [15:0]  buffer2_33  ;
reg     signed   [16:0]  buffer3_1   ;
reg     signed   [16:0]  buffer3_2   ;
reg     signed   [15:0]  buffer3_11  ;
reg     signed   [15:0]  buffer3_22  ;
reg     signed   [16:0]  buffer4_1   ;
reg     signed   [15:0]  buffer4_11  ;
reg     signed   [15:0]  buffer4_11_reg  ;
reg                      mul_flag    ;
reg                      mul_flag_reg;
reg                      mul_flag_reg1;
reg                      mul_flag_reg2;
reg                      mul_flag_reg3;
reg                      add1_flag   ;
reg                      add2_flag   ;
reg                      add3_flag   ;
reg                      add4_flag   ;
reg                      add5_flag   ;


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

//fifo1写信号  
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        wr_en_1 <= 1'b0;
    else    if(cnt_row == 9'd0 && pi_data_valid == 1'b1)
        wr_en_1 <= 1'b1;
    else
        wr_en_1 <= dout_flag;  

//fifo2写信号        
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        wr_en_2 <= 1'b0;
    else    if(cnt_row >= 9'd1 && (cnt_row <= (image_size - 1'b1)) && pi_data_valid == 1'b1)
        wr_en_2 <= 1'b1;
    else
        wr_en_2 <= 1'b0; 
       
        
//将数据写入到fifo1中
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        wr_data_1 <= 16'd0;
    else    if(cnt_row == 9'd0 && pi_data_valid == 1'b1)
        wr_data_1 <= pi_data;
    else    if(dout_flag == 1'b1) 
        wr_data_1 <= dout2;  
    else
        wr_data_1 <= wr_data_1;

//将数据写入到fifo2中        
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        wr_data_2 <= 16'd0;
    else    if(cnt_row >= 9'd1 && (cnt_row <= (image_size - 1'b1)) && pi_data_valid == 1'b1)
        wr_data_2 <= pi_data;
    else
        wr_data_2 <= wr_data_2;

//fifo读信号
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_en <= 1'b0;
    else    if(cnt_row >= 9'd2 && (cnt_row <= (image_size - 1'b1)) && pi_data_valid == 1'b1)
        rd_en <= 1'b1;
    else
        rd_en <= 1'b0;


//从fifo读数据标志        
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        dout_flag <= 1'b0;
    else    if(rd_en == 1'b1)
        dout_flag <= 1'b1;
    else
        dout_flag <= 1'b0;

//计数读了多少个数据        
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_rd <= 9'd0;
    else    if((cnt_rd == (image_size - 1'b1)) && (rd_en == 1'b1))
        cnt_rd <= 9'd0;
    else    if(rd_en == 1'b1)
        cnt_rd <= cnt_rd + 1'b1;
    else
        cnt_rd <= cnt_rd;


always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_rd_reg <= 9'd0;
    else
        cnt_rd_reg <= cnt_rd;
        
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_rd_reg1 <= 9'd0;
    else
        cnt_rd_reg1 <= cnt_rd_reg;
        
/*always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_rd_reg2 <= 9'd0;
    else
        cnt_rd_reg2 <= cnt_rd_reg1;*/

//rd_en打一拍        
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_en_reg   <=  1'b0;
    else    if(rd_en == 1'b1)
        rd_en_reg   <=  1'b1;
    else
        rd_en_reg   <=  1'b0;

//rd_en再打一拍 
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_en_reg1   <=  1'b0;
    else    if(rd_en_reg == 1'b1)
        rd_en_reg1   <=  1'b1;
    else
        rd_en_reg1   <=  1'b0;
        
/*always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_en_reg2   <=  1'b0;
    else    if(rd_en_reg1 == 1'b1)
        rd_en_reg2   <=  1'b1;
    else
        rd_en_reg2   <=  1'b0;
        
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        rd_en_reg3   <=  1'b0;
    else    if(rd_en_reg2 == 1'b1)
        rd_en_reg3   <=  1'b1;
    else
        rd_en_reg3   <=  1'b0;*/
        
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        dout1_reg <= 16'd0;
    else    if(rd_en_reg == 1'b1)
        dout1_reg <= dout1;
    else
        dout1_reg <= dout1_reg;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        dout2_reg <= 16'd0;
    else    if(rd_en_reg == 1'b1)
        dout2_reg <= dout2;
    else
        dout2_reg <= dout2_reg;

//跟fifo保持同步
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        pi_data_buf <= 16'd0;
    else
        pi_data_buf <= pi_data;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        pi_data_buf1 <= 16'd0;
    else
        pi_data_buf1 <=  pi_data_buf;
        
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        pi_data_reg <= 16'd0;
    else    if(rd_en_reg == 1'b1)
        pi_data_reg <= pi_data_buf1;
    else
        pi_data_reg <= pi_data_reg;   

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            a1 <= 16'd0;
            a2 <= 16'd0;
            a3 <= 16'd0;
            b1 <= 16'd0;
            b2 <= 16'd0;
            b3 <= 16'd0;
            c1 <= 16'd0;
            c2 <= 16'd0;
            c3 <= 16'd0;
        end
    else
        begin
            a1 <= a2;
            a2 <= a3;
            a3 <= dout1_reg;
            b1 <= b2;
            b2 <= b3;
            b3 <= dout2_reg;
            c1 <= c2;
            c2 <= c3;
            c3 <= pi_data_reg;
        end  
        

//卷积开始乘积的标志
always@(posedge sys_clk or negedge sys_rst_n)
        if(sys_rst_n == 1'b0)
            mul_flag <= 1'b0;
        else    if((rd_en_reg1 == 1'b1) && (((cnt_rd_reg == 9'd0) && (cnt_rd_reg1 != 9'd0)) || (cnt_rd_reg >= 9'd3)))
            mul_flag <= 1'b1;
        else
            mul_flag <= 1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        mul_flag_reg <= 1'b0;
    else    if(mul_flag == 1'b1)
        mul_flag_reg <= 1'b1;
    else
        mul_flag_reg <= 1'b0;
        
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        mul_flag_reg1 <= 1'b0;
    else    if(mul_flag_reg == 1'b1)
        mul_flag_reg1 <= 1'b1;
    else
        mul_flag_reg1 <= 1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        mul_flag_reg2 <= 1'b0;
    else    if(mul_flag_reg1 == 1'b1)
        mul_flag_reg2 <= 1'b1;
    else
        mul_flag_reg2 <= 1'b0;
        

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        mul_flag_reg3 <= 1'b0;
    else    if(mul_flag_reg2 == 1'b1)
        mul_flag_reg3 <= 1'b1;
    else
        mul_flag_reg3 <= 1'b0;


      
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            buffer2_1 <= 34'd0;
            buffer2_2 <= 34'd0;
            buffer2_3 <= 34'd0;
        end
    else    if(mul_flag_reg == 1'b1)
        begin
            buffer2_1 <= buffer1_1 + buffer1_2;
            buffer2_2 <= buffer1_3 + buffer1_4;
            buffer2_3 <= buffer1_5;      
        end
        
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            buffer2_11 <= 16'd0;
            buffer2_22 <= 16'd0;
            buffer2_33 <= 16'b0;
        end
    else    if(mul_flag_reg1 == 1'b1)
        begin
            buffer2_11 <= {buffer2_1[33],buffer2_1[14:0]};
            buffer2_22 <= {buffer2_2[33],buffer2_2[14:0]};
            buffer2_33 <= {buffer2_3[33],buffer2_3[14:0]};
        end
  
        
always@(posedge sys_clk or negedge sys_rst_n)  
    if(sys_rst_n == 1'b0)
        add1_flag <= 1'b0;
    else    if(mul_flag_reg1 == 1'b1)
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
        add5_flag <= 1'b0;
    else    if(add4_flag == 1'b1)
        add5_flag <= 1'b1;
    else
        add5_flag <= 1'b0;     
           
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            buffer3_1 <= 17'd0;
            buffer3_2 <= 17'd0;
        end
    else    if(add1_flag == 1'b1)
        begin
            buffer3_1 <= buffer2_11 + buffer2_22;
            buffer3_2 <= buffer2_33 + bias;
        end
        
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            buffer3_11 <= 16'd0;
            buffer3_22 <= 16'd0;
        end
    else    if(add2_flag == 1'b1)
        begin
            buffer3_11 <= {buffer3_1[16],buffer3_1[14:0]};
            buffer3_22 <= {buffer3_2[16],buffer3_2[14:0]};
        end

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            buffer4_1 <= 17'd0;
        end
    else    if(add3_flag == 1'b1)
        begin
            buffer4_1 <= buffer3_11 + buffer3_22;
        end
        
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            buffer4_11 <= 16'd0;
        end
    else    if(add4_flag == 1'b1)
        begin
            buffer4_11 <= {buffer4_1[16],buffer4_1[14:0]};
        end
        

    
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        po_data_valid <= 1'b0;
    else    if(add5_flag == 1'b1)
        po_data_valid <= 1'b1;
    else
        po_data_valid <= 1'b0;
        
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        po_data <= 16'd0;
    else    if(add5_flag == 1'b1)
        po_data <= buffer4_11;
    else
        po_data <= po_data;

fifo fifo_inst1
(
  .clk          (sys_clk),       // input
  .rst          (~sys_rst_n),    // input
  .wr_en        (wr_en_1),       // input
  .wr_data      (wr_data_1),     // input [15:0]
  .wr_full      (),              // output
  .almost_full  (),              // output
  .rd_en        (rd_en),         // input
  .rd_data      (dout1),         // output [15:0]
  .rd_empty     (),              // output
  .almost_empty ()               // output
);


fifo fifo_inst2
(
  .clk          (sys_clk),        // input
  .rst          (~sys_rst_n),     // input
  .wr_en        (wr_en_2),        // input
  .wr_data      (wr_data_2),      // input [15:0]
  .wr_full      (),               // output
  .almost_full  (),               // output
  .rd_en        (rd_en),          // input
  .rd_data      (dout2),          // output [15:0]
  .rd_empty     (),               // output
  .almost_empty ()                // output
);


multiply_adder multiply_adder_inst1
(
  .a0(a1),            // input [15:0]
  .a1(a2),            // input [15:0]
  .b0(weight1),       // input [15:0]
  .b1(weight2),       // input [15:0]
  .clk(sys_clk),      // input
  .rst(~sys_rst_n),   // input
  .ce(mul_flag),      // input
  .addsub(1'b0),      // input
  .p(buffer1_1)       // output [32:0]
);

multiply_adder multiply_adder_inst2
(
  .a0(a3),            // input [15:0]
  .a1(b1),            // input [15:0]
  .b0(weight3),       // input [15:0]
  .b1(weight4),       // input [15:0]
  .clk(sys_clk),      // input
  .rst(~sys_rst_n),   // input
  .ce(mul_flag),      // input
  .addsub(1'b0),      // input
  .p(buffer1_2)       // output [32:0]
);

multiply_adder multiply_adder_inst3
(
  .a0(b2),            // input [15:0]
  .a1(b3),            // input [15:0]
  .b0(weight5),       // input [15:0]
  .b1(weight6),       // input [15:0]
  .clk(sys_clk),      // input
  .rst(~sys_rst_n),   // input
  .ce(mul_flag),      // input
  .addsub(1'b0),      // input
  .p(buffer1_3)       // output [32:0]
);

multiply_adder multiply_adder_inst4
(
  .a0(c1),            // input [15:0]
  .a1(c2),            // input [15:0]
  .b0(weight7),       // input [15:0]
  .b1(weight8),       // input [15:0]
  .clk(sys_clk),      // input
  .rst(~sys_rst_n),   // input
  .ce(mul_flag),      // input
  .addsub(1'b0),      // input
  .p(buffer1_4)       // output [32:0]
);

multiply_adder multiply_adder_inst5
(
  .a0(c3),            // input [15:0]
  .a1(16'd0),          // input [15:0]
  .b0(weight9),       // input [15:0]
  .b1(16'd0),          // input [15:0]
  .clk(sys_clk),      // input
  .rst(~sys_rst_n),   // input
  .ce(mul_flag),      // input
  .addsub(1'b0),      // input
  .p(buffer1_5)       // output [32:0]
);


endmodule
