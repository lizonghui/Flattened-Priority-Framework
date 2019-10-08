`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/08/02 15:43:09
// Design Name: 
// Module Name: mask_computation
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


module mask_computation #(
parameter N = 24,
parameter P = 8
) (
input     [N * N * P - 1 : 0]   i_p_o,
output    [N * P - 1 : 0]       o_p_r
);
wire [N - 1 : 0] p_o [N * P - 1 : 0];
wire [P - 1 : 0] p_a [N - 1 : 0];
wire [N - 1 : 0] p_mask [P - 1 : 0];
generate
   genvar n, j, i;
   for(n = 0; n < N; n = n + 1) begin:p_o_group
       for(j = 0; j < P; j = j + 1) begin:sub_p_o_group
           for(i = 0; i < N; i = i + 1)begin:sub_sub_p_o_group
               assign p_o[j * N + i][n] = i_p_o[n * P * N + j * N + i];
           end
       end
   end
   for(j = 0; j < P; j = j + 1) begin:p_a_group
      for(i = 0; i < N; i = i + 1) begin:sub_p_a_group
          assign p_a[i][j] = & p_o[j * N + i];
      end
   end
   for(i = 0; i < N; i = i + 1)begin:p_mask_p_group
      assign p_mask[P - 1][i] = 1'b1; 
   end
   for(j = 0; j < P - 1; j = j + 1) begin:p_mask_group
       for(i = 0; i < N; i = i + 1) begin:sub_p_mask_group
          assign p_mask[j][i] = ~(| p_a[i][P - 1 : j + 1]);
       end
   end
   for(j = 0; j < P; j = j + 1) begin:p_r_group
       for(i = 0; i < N; i = i + 1) begin:sub_p_r_group
          assign o_p_r[j * N + i] = p_a[i][j] & p_mask[j][i];
       end
   end
endgenerate
endmodule
