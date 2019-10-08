`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/09/13 20:34:17
// Design Name: 
// Module Name: select_request
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

module select_request#(
parameter N = 25,
parameter P = 8
)(
input  [P * N - 1 : 0] i_request,
output [P * N - 1 : 0] o_request
);
wire [P - 1 : 0] request [N - 1 : 0];
wire [P - 1 : 0] gnt_smpl [N - 1 : 0];
generate
   genvar i,j;
   for(i = 0; i < N; i = i + 1) begin:trans_req
      for(j = 0; j < P; j = j + 1) begin:sub_trans_req
         assign request[i][P - 1 - j] = i_request[j * N + i];
         assign o_request[j * N + i] = gnt_smpl[i][P - 1 - j];
      end
   end
   for(i = 0; i < N; i = i + 1) begin:sel_pri
      simple_priority_encoder #(
      .N (P)
      ) spe_u (
      .in_request (request[i]),
      .out_grant (gnt_smpl[i])
      );
   end
endgenerate
endmodule
