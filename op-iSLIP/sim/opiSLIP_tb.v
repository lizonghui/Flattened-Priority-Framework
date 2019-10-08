`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/10/20 21:31:36
// Design Name: 
// Module Name: fpiSLIP_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module opiSLIP_tb();
localparam PORT = 8;
localparam PRIORITY = 4;
localparam PERIOD = 8;
localparam WIDTH = 32;
localparam MAX_DEPTH_BITS = 3;
localparam ITER = 3;
localparam LOGITER = 2;
localparam FRAME_BYTES = 64;
// 10 :100%, 1 : 10%
localparam FREE = 5;
// //0:uniform, 1:bernoulli, 2:markov
localparam SEL_DSTRI = 2;
// 10 :100%, 1 : 10%
localparam BANDWIDTH = 10;
// 10 : 10 ns 100Mb 1 : 1 ns 1Gb
localparam SPEED = 10;

reg clk;
reg reset;
wire [PORT - 1 : 0] wr;
wire [PORT - 1 : 0] wr_port [PORT - 1 : 0];
wire [PRIORITY - 1 : 0] wr_pri [PORT - 1 : 0];
wire [WIDTH - 1 : 0] arr_time [PORT - 1 : 0];

wire [WIDTH - 1 : 0] data [PORT - 1 : 0];
wire [PORT - 1 : 0] rd;
wire [PORT * PORT - 1 : 0] rd_port;
wire [PORT * PRIORITY - 1 : 0] rd_priority;

wire [PORT - 1 : 0] rd_port_trans [PORT - 1 : 0];
wire [PORT * PORT * PRIORITY - 1 : 0] req;

wire [PORT * PORT - 1 : 0] acc_grant;
wire [PORT * PRIORITY - 1 : 0] acc_priority;
wire [PORT - 1 : 0] in_busy;
wire [PORT - 1 : 0] out_busy;

reg [WIDTH - 1 : 0] counter_in [PORT - 1 : 0];
reg [WIDTH - 1 : 0] counter_out [PORT - 1 : 0];
reg [WIDTH - 1 : 0] max_delay [PORT - 1 : 0];
reg [WIDTH - 1 : 0] min_delay [PORT - 1 : 0];
reg [2 * WIDTH - 1 : 0] total_delay [PORT - 1 : 0];

initial begin
clk = 0;
reset = 1;
#(PERIOD)
reset = 0;
end

always begin
clk = 1'b0;
#(PERIOD / 2);
clk = 1'b1;
#(PERIOD / 2);
end

generate
   genvar i, j;
   for(i = 0; i < PORT; i = i + 1) begin:ports_group
      initial begin
      counter_in[i] = 0;
      counter_out[i] = 0;
      max_delay[i] = 0;
      min_delay[i] = 32'hffff_ffff;
      total_delay[i] = 0;
      end
      frame_priority_arrivals#(
      .ID (i),
      .WIDTH (WIDTH),
      .PORT (PORT),
      .PRIORITY (PRIORITY),
      .FRAME_BYTES (FRAME_BYTES),
      .FREE(FREE),
      .SEL_DSTRI(SEL_DSTRI),
       // 10 :100%, 1 : 10%
      .BANDWIDTH (BANDWIDTH),
       // 10 : 10 ns 100Mb 1 : 1 ns 1Gb
      .SPEED (SPEED)
      ) u_frame_priority_arrivals (
      .clk (clk),
      .o_wr (wr[i]),
      .o_wr_port (wr_port[i]),
      .o_wr_pri (wr_pri[i]),
      .o_time (arr_time[i])
     );
     
     virtual_priority_queues#(
     .PORT (PORT),
     .PRIORITY (PRIORITY),
     .WIDTH (WIDTH),
     .MAX_DEPTH_BITS (MAX_DEPTH_BITS)
     ) u_virtual_priority_queues (
     .clk (clk),
     .reset (reset),
     .i_wr (wr[i]),
     .i_wr_port(wr_port[i]),
     .i_wr_priority(wr_pri[i]),
     .i_data(arr_time[i]),
     .i_rd (rd[i]),
     .i_rd_port (rd_port[(i + 1) * PORT - 1 : i * PORT]),
     .i_rd_priority (rd_priority[(i + 1) * PRIORITY - 1 : i * PRIORITY]),
     .o_req (req[(i + 1) * PRIORITY * PORT - 1 : i * PRIORITY * PORT]),
     .o_data (data[i])
   );
   
   frame_priority_delivers#(
     .PERIOD (PERIOD),
     .PORT (PORT),
     .PRIORITY (PRIORITY),
     .WIDTH (WIDTH),
     .FRAME_BYTES (FRAME_BYTES),
   // 10 :100%, 1 : 10%
     .BANDWIDTH (BANDWIDTH),
   // 10 : 10 ns 100Mb 1 : 1 ns 1Gb
     .SPEED (SPEED)
   ) u_frame_priority_delivers (
    .clk (clk),
    .i_acc_grant (acc_grant[(i + 1) * PORT - 1 : i * PORT]),
    .i_acc_pri (acc_priority[(i + 1) * PRIORITY - 1 : i * PRIORITY]),
    .o_rd (rd[i]),
    .o_rd_pri (rd_priority[(i + 1) * PRIORITY - 1 : i * PRIORITY]),
    .o_in_busy (in_busy[i]),
    .o_out_busy (rd_port[(i + 1) * PORT - 1 : i * PORT])
   );
  
   for(j = 0; j < PORT; j = j + 1) begin:sub_port_group
       assign rd_port_trans[j][i] = rd_port[i * PORT + j];
   end
   assign out_busy[i] = | rd_port_trans[i];
   always @(posedge clk) begin
      if (rd[i]) begin
         counter_out[i] <= counter_out[i] + 1;
         total_delay[i] <= total_delay[i] + ($time - data[i]);
         if (min_delay[i] > ($time - data[i])) begin
             min_delay[i] <= ($time - data[i]);
         end
         if (max_delay[i] < ($time - data[i])) begin
             max_delay[i] <= ($time - data[i]);
         end
//         $display("out_%d:%d",i,counter_out[i]);
//         $display("total_%d:%d",i,total_delay[i]);
//         $display("min_%d:%d",i,min_delay[i]);
//         $display("max_%d:%d",i,max_delay[i]);
      end
      if (wr[i]) begin
         counter_in[i] <= counter_in[i] + 1;
//         $display("in_%d:%d",i,counter_in[i]);
      end
   end
   end
endgenerate
opiSLIP #(
.N (PORT),
.P (PRIORITY),
.ITER (ITER),
.LOGITER (LOGITER)
) u_opiSLIP (
.clk (clk),
.reset (reset),
.i_priority (req),
.i_input_idle (~in_busy),
.i_output_idle (~out_busy),
.o_acc_grant (acc_grant),
.o_acc_priority (acc_priority)
);
endmodule