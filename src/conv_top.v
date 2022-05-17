module conv_top
(
    input   wire                        sys_clk         ,
    input   wire                        sys_rst_n       ,
    input   wire              [8:0]     image_size      ,
    input   wire                        pi_weight_valid ,
    input   wire    signed    [15:0]    pi_weight       ,
    input   wire                        pi_data_valid   ,
    input   wire    signed    [15:0]    pi_data         ,
    input   wire    signed    [15:0]    average         ,   //均值
    input   wire    signed    [15:0]    std             ,   //标准差
    
    output  wire    signed    [15:0]    map_out         , 
    output  reg                         map_out_valid   
);


wire    weights_ready;
wire    frame_valid;
wire    signed  [15:0]  po_data;
wire                    po_data_valid;
wire    signed  [32:0]  map_out1;

reg             [2:0]       state;
reg                         conv_start;
reg                         conv_end;
reg     signed  [15:0]      pi_data_reg;
reg     signed  [15:0]      po_data_reg;
reg     signed  [15:0]      po_data_reg1;
reg                         po_data_valid1; 
reg                         po_data_valid2;   


wire    signed [15:0] 	weights_1_1;
wire    signed [15:0] 	weights_1_2;
wire    signed [15:0] 	weights_1_3;
wire    signed [15:0] 	weights_2_1;
wire    signed [15:0] 	weights_2_2;
wire    signed [15:0] 	weights_2_3;
wire    signed [15:0] 	weights_3_1;
wire    signed [15:0] 	weights_3_2;
wire    signed [15:0] 	weights_3_3;
wire    signed [15:0] 	bias       ;       




parameter   IDLE        = 3'd0,
            LOAD_WEIGHT = 3'd1,
            WAIT        = 3'd2,
            //LOAD_IMAGE  = 3'd3,
            CONV        = 3'd3,
            STOP        = 3'd4;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        pi_data_reg <= 16'd0;
    else    
        pi_data_reg <= pi_data;

//卷积开始标志
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        conv_start <= 1'b0;
    else    if(state == WAIT && pi_data_valid == 1'b1 && weights_ready == 1'b1)
        conv_start <= 1'b1;
    else    if(state == CONV && pi_data_valid == 1'b0)
        conv_start <= 1'b0;
    else
        conv_start <= conv_start;

//卷积结束标志
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        conv_end <= 1'b0;   
    else    if(state == CONV && pi_data_valid == 1'b0)
        conv_end <= 1'b1;
    else
        conv_end <= 1'b0;
 
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        state <= IDLE;
    else
        begin
            case(state)
                IDLE:begin
                        if(pi_weight_valid == 1'b1)         
                            state <= LOAD_WEIGHT;
                        else
                            state <= IDLE;                
                     end
                
                LOAD_WEIGHT:begin
                                if(weights_ready == 1'b1 && pi_weight_valid == 1'b0) 
                                    state <= WAIT;
                                else
                                    state <= LOAD_WEIGHT;
                            end
                
                WAIT:begin
                        if(conv_start == 1'b1)
                            state <= CONV;
                        else    
                            state <= WAIT;
                     end
                
                /*LOAD_IMAGE:begin
                              if(pi_data_valid == 1'b1)
                                 state <= CONV;                  
                              else
                                 state <= LOAD_IMAGE;                             
                           end*/
                
                CONV:begin
                        if(conv_end == 1'b1)  
                            state <= STOP;
                        else
                            state <= CONV;                    
                     end
                
                STOP:begin                    
                        state <= IDLE;
                     end 
                default:state <= IDLE;     
            endcase
        end

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        po_data_reg <= 16'd0;
    else    if(po_data_valid == 1'b1)
        po_data_reg <= po_data - average;
    else
        po_data_reg <= po_data_reg;

        
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        po_data_valid1 <= 1'b0;
    else    if(po_data_valid == 1'b1)
        po_data_valid1 <= 1'b1;
    else
        po_data_valid1 <= 1'b0;

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        po_data_reg1 <= 16'd0;
    else    if(po_data_reg[15] == 1'b0 && po_data[15] == 1'b1 && po_data_valid1 == 1'b1)
        po_data_reg1 <= -16'd32768;
    else    if(po_data_reg[15] == 1'b1 && po_data[15] == 1'b0 && po_data_valid1 == 1'b1)
        po_data_reg1 <= 16'd32767;
    else
        po_data_reg1 <= po_data_reg;
    

always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        po_data_valid2 <= 1'b0;
    else    if(po_data_valid1 == 1'b1)
        po_data_valid2 <= 1'b1;
    else
        po_data_valid2 <= 1'b0;
        

        
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        map_out_valid <= 1'b0;
    else    if(po_data_valid2 == 1'b1)
        map_out_valid <= 1'b1;
    else
        map_out_valid <= 1'b0;

assign map_out = {map_out1[32],map_out1[22:8]};




multiply_adder multiply_adder_inst
(
  .a0(po_data_reg1),            // input [15:0]
  .a1(16'd0),            // input [15:0]
  .b0(std),       // input [15:0]
  .b1(16'd0),       // input [15:0]
  .clk(sys_clk),      // input
  .rst(~sys_rst_n),   // input
  .ce(po_data_valid2),      // input
  .addsub(1'b0),      // input
  .p(map_out1)       // output [32:0]
); 

 
            
conv_weights conv_weights_inst
(
	.pclk       (sys_clk),
	.rst_n      (sys_rst_n),

	.wr_data    (pi_weight),
	.wr_en      (pi_weight_valid),

	.weights_1_1(weights_1_1),
	.weights_1_2(weights_1_2),
	.weights_1_3(weights_1_3),
	.weights_2_1(weights_2_1),
	.weights_2_2(weights_2_2),
	.weights_2_3(weights_2_3),
	.weights_3_1(weights_3_1),
	.weights_3_2(weights_3_2),
	.weights_3_3(weights_3_3),
	.bias       (bias       ),
	
	.weights_ready(weights_ready)
);            


conv_ctrl_test conv_ctrl_test_inst
(
    .sys_clk      (sys_clk),
    .sys_rst_n    (sys_rst_n),
    .image_size   (image_size),
    .pi_data      (pi_data_reg),
    .pi_data_valid(conv_start),
    .weight1      (weights_1_1),
    .weight2      (weights_1_2),
    .weight3      (weights_1_3),
    .weight4      (weights_2_1),
    .weight5      (weights_2_2),
    .weight6      (weights_2_3),
    .weight7      (weights_3_1),
    .weight8      (weights_3_2),
    .weight9      (weights_3_3),
    .bias         (bias       ),

    .po_data      (po_data),
    .po_data_valid(po_data_valid),
    .frame_valid  (frame_valid)
);




endmodule
