`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/09/05 12:33:06
// Design Name: 
// Module Name: simple_priority_encoder
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
module simple_priority_encoder #(
parameter N = 25
) (
input  [N - 1 : 0] in_request,
output [N - 1 : 0] out_grant
);
wire [N - 1 : 0] mask_request;
generate
   genvar i;
   for(i = 0; i < N; i = i + 1) begin:spe_mask
      assign mask_request[i] = | in_request[i : 0];
   end
   assign out_grant[0] = in_request[0];
   for(i = 1; i < N; i = i + 1) begin:spe_grant
      assign out_grant[i] = (~mask_request[i - 1]) &  mask_request[i];
   end
endgenerate
endmodule
