`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/10/20 22:19:32
// Design Name: 
// Module Name: virtual_priority_queues
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
module virtual_priority_queues#(
parameter PORT = 8,
parameter PRIORITY = 4,
parameter WIDTH = 32,
parameter MAX_DEPTH_BITS = 3
)(
input clk,
input reset,
input i_wr,
input [PORT - 1 : 0] i_wr_port,
input [PRIORITY - 1 : 0] i_wr_priority,
input [WIDTH - 1 : 0] i_data,
input i_rd,
input [PORT - 1 : 0] i_rd_port,
input [PRIORITY - 1 : 0] i_rd_priority,
output [PORT * PRIORITY - 1 : 0] o_req,
output [WIDTH - 1 : 0] o_data
);
wire [WIDTH - 1 : 0] data [PRIORITY - 1 : 0];
wire [PRIORITY - 1 : 0] data_trans [WIDTH - 1 : 0];
reg [PRIORITY - 1 : 0] select = 0;
generate
   genvar i, j;
   for(i = 0; i < PRIORITY; i = i + 1) begin:vpq_group
       virtual_output_queues#(
       .PORT (PORT),
       .WIDTH (WIDTH),
       .MAX_DEPTH_BITS (MAX_DEPTH_BITS)
       ) u_virtual_output_queues (
       .clk (clk),
       .reset (reset),
       .i_wr (i_wr & i_wr_priority[i]),
       .i_wr_port (i_wr_port),
       .i_data (i_data),
       .i_rd (i_rd & i_rd_priority[i]),
       .i_rd_port (i_rd_port),
       .o_req (o_req[(i + 1) * PORT - 1 : i * PORT]),
       .o_data (data[i])
       );
   end
   for(i = 0; i < WIDTH; i = i + 1) begin:trans_group
      for(j = 0; j < PRIORITY; j = j + 1) begin:sub_trans_group
         assign data_trans[i][j] = data[j][i] & select[j];
      end
      assign o_data[i] = |data_trans[i];
   end
endgenerate
always @(posedge clk) begin
    if (i_rd)
        select <= i_rd_port;
end
endmodule
