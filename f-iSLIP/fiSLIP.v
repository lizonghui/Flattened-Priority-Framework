`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/09/13 20:21:45
// Design Name: 
// Module Name: piSLIP
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


module fiSLIP #(
parameter N = 12,
parameter P = 8
)(
input     clk,
input     reset,
input     [N * N * P - 1 : 0]   i_priority,
input     [N - 1 : 0]           i_input_idle,
input     [N - 1 : 0]           i_output_idle,
output  [N * N - 1 : 0]     o_acc_grant
);
wire [N * N - 1 : 0] requests;

flattening_priorities #(
.N (N),
.P (P)
) flattening_priorities_u (
//input     [N * N * P - 1 : 0]   i_empty,
.i_priority (i_priority),
.i_input_idle (i_input_idle),
.i_output_idle (i_output_idle),
.o_request (requests)
);

iSLIP #(
.N (N),
.P (1),
.ITER (3),
.LOGITER (2)
) iSLIP_u (
.clk (clk),
.reset (re),
.i_priority (requests),
.i_input_idle (i_input_idle),
.i_output_idle (i_output_idle),
.o_acc_grant (o_acc_grant)
);

endmodule
