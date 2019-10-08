`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/09/06 08:41:43
// Design Name: 
// Module Name: thermometer_peer
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


module thermometer_peer#(
parameter N = 32
)(
input  [N - 1 : 0] in_point,
output [N - 1 : 0] out_code
);
assign out_code[N - 1] = 1'b0;
generate
   genvar i;
   for(i = 0; i < N - 1; i = i + 1) begin:spe_mask
      assign out_code[i] = | in_point[N - 1 : i + 1];
   end
endgenerate
endmodule
