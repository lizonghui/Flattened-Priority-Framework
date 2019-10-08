`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/08/01 16:19:51
// Design Name: 
// Module Name: priority_selection
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


module priority_selection #(
parameter N = 24,
parameter P = 8
) (
input     [N * P - 1 : 0]   i_empty,
input     [N * P - 1 : 0]   i_priority,
input                       i_input_idle,
input     [N - 1 : 0]       i_output_idle,
output    [P * N - 1 : 0]   o_p_o
);
wire [P - 1 : 0] e;
wire [N - 1 : 0] sub_e [P - 1 : 0];
wire [P - 1 : 0] e_mask;
generate
   genvar i, j;
   for(i = 0; i < P; i = i + 1) begin:e_group
       for(j = 0; j < N; j = j + 1)begin:sub_e_group
         assign sub_e[i][j] = (i_empty[ j * P + i] | (~i_output_idle[j]));
       end
       assign e[i] = & sub_e[i];
   end
   assign e_mask[P - 1] = 1'b1;
   for(i = 0; i < P - 1; i = i + 1) begin:e_mask_group
      assign e_mask[i] = & e[P - 1 : i + 1];
   end
   for(i = 0; i < P; i = i + 1) begin:p_o_group
       for(j = 0; j < N; j = j + 1) begin:sub_p_o_group
          assign o_p_o[i * N + j] = i_input_idle & i_output_idle[j] & i_priority[j * P + i] & e_mask[i];
       end
   end
endgenerate
endmodule
