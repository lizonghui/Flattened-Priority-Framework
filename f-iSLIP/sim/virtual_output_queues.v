`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/10/17 17:20:22
// Design Name: 
// Module Name: virtual_output_queues
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
module virtual_output_queues#(
parameter PORT = 8,
parameter WIDTH = 32,
parameter MAX_DEPTH_BITS = 3
)(
input clk,
input reset,
input i_wr,
input [PORT - 1 : 0] i_wr_port,
input [WIDTH - 1 : 0] i_data,
input i_rd,
input [PORT - 1 : 0] i_rd_port,
output [PORT - 1 : 0] o_req,
output [WIDTH - 1 : 0] o_data
);
wire [WIDTH - 1 : 0] data [PORT - 1 : 0];
wire [PORT - 1 : 0] data_trans [WIDTH - 1 : 0];
wire [PORT - 1 : 0] full;
wire [PORT - 1 : 0] nearly_full;
wire [PORT - 1 : 0] prog_full;
wire [PORT - 1 : 0] empty;
reg [PORT - 1 : 0] select = 0;
generate
   genvar i, j;
   for(i = 0; i < PORT; i = i + 1) begin:voq_group
       small_fifo #(
       .WIDTH (WIDTH),
       .MAX_DEPTH_BITS (MAX_DEPTH_BITS)
       ) u_small_fifo (
      .din (i_data),
      .wr_en (i_wr & i_wr_port[i]),   // Write enable
      .rd_en (i_rd & i_rd_port[i]),   // Read the next word
      .dout (data[i]),    // Data out
      .full (full[i]),
      .nearly_full (nearly_full[i]),
      .prog_full (prog_full[i]),
      .empty (empty[i]),
      .reset (reset),
      .clk (clk));
      assign o_req[i] = ~empty[i];
   end
   for(i = 0; i < WIDTH; i = i + 1) begin:trans_group
      for(j = 0; j < PORT; j = j + 1) begin:sub_trans_group
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