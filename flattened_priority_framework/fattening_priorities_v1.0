`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/08/02 20:00:57
// Design Name: 
// Module Name: flattening_priorities
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
module flattening_priorities#(
parameter N = 25,
parameter P = 8
) (
//input     [N * N * P - 1 : 0]   i_empty,
input     [N * N * P - 1 : 0]   i_priority,
input     [N - 1 : 0]           i_input_idle,
input     [N - 1 : 0]           i_output_idle,
output    [N * N - 1 : 0]       o_request
);
wire [N * P * N - 1 : 0] p_o;
wire [N * P - 1 : 0]     p_r;
wire [N * N * P - 1 : 0]   i_empty;
assign i_empty = ~i_priority;
generate
   genvar i;
   for(i = 0; i < N; i = i + 1) begin:port_group
       priority_selection #(
       .N                   (N),
       .P                   (P)
       ) u_priority_selection(
       .i_empty             (i_empty[(i + 1) * N * P - 1 : i * N * P]),
       .i_priority          (i_priority[(i + 1) * N * P - 1 : i * N * P]),
       .i_input_idle        (i_input_idle[i]),
       .i_output_idle       (i_output_idle),
       .o_p_o               (p_o[(i + 1) * P * N - 1 : i * P * N])
      );
      request_evaluation #(
      .N                  (N),
      .P                  (P)
      ) u_request_evaluation(
      .i_priority         (i_priority[(i + 1) * N * P - 1 : i * N * P]),
      .i_p_r              (p_r),
      .o_request          (o_request[(i + 1) * N - 1 : i * N])
     );
   end
   mask_computation #(
   .N                 (N),
   .P                 (P)
   ) u_mask_computation (
   .i_p_o             (p_o),
   .o_p_r             (p_r)
   );
endgenerate
endmodule