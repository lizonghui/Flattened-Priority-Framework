`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/09/06 09:00:23
// Design Name: 
// Module Name: program_priority_encoder_v1_0
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
module program_priority_encoder_v1_0#(
parameter N = 32
)(
input  [N - 1 : 0] in_p_enc,
input  [N - 1 : 0] in_req,
output [N - 1 : 0] out_grant
);
wire [N - 1 : 0] p_therm;
wire [N - 1 : 0] new_req;
wire anygnt_thermo;
wire [N - 1 : 0] gnt_thermo;
wire [N - 1 : 0] gnt_smpl;
thermometer_peer#(
.N (N)
) tp_u (
 .in_point (in_p_enc),
 .out_code (p_therm)
);
assign new_req = (~p_therm) & in_req;
assign anygnt_thermo = | new_req;
simple_priority_encoder #(
.N (N)
) spe_thermo (
.in_request (new_req),
.out_grant (gnt_thermo)
);
simple_priority_encoder #(
.N (N)
) spe_u (
.in_request (in_req),
.out_grant (gnt_smpl)
);
generate
   genvar i;
   for(i = 0; i < N; i = i + 1) begin:mux_req
       assign out_grant[i] = gnt_thermo[i] | ((~anygnt_thermo) & gnt_smpl[i]);
   end
endgenerate
endmodule
