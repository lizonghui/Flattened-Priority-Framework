`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/08/02 18:48:11
// Design Name: 
// Module Name: request_evaluation
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


module request_evaluation #(
parameter N = 24,
parameter P = 8
) (
input     [N * P - 1 : 0]   i_priority,
input     [N * P - 1 : 0]   i_p_r,
output    [N - 1 : 0]   o_request
);
wire [P - 1 : 0] req_p [N - 1 : 0];
generate
   genvar j, i;
      for(j = 0; j < P; j = j + 1) begin:req_p_group
         for(i = 0; i < N; i = i + 1) begin:sub_req_p_group
            assign req_p[i][j] = i_priority[i * P + j] & i_p_r[j * N +i];
         end
      end
      for(i = 0; i < N; i = i + 1) begin:request_group
         assign o_request[i] = | req_p[i];
      end
endgenerate
endmodule
