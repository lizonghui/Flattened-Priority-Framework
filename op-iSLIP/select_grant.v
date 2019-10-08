`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/09/13 21:28:27
// Design Name: 
// Module Name: select_grant
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
module select_grant# (
parameter ODD = 1,
parameter N = 25,
parameter P = 8
)(
input  clk,
input  reset,
input  i_busy,
input  i_random_robin,
input  [P * N - 1 : 0] i_port_req,
output [N - 1 : 0] o_port_grant,
output [P - 1 : 0] o_grant_priority
);
wire [N - 1 : 0] request [P - 1 : 0];
wire [P - 1 : 0] trans_request [N - 1 : 0];
wire [P - 1 : 0] has_priority;
wire [P - 1 : 0] gnt_priority;
wire [N - 1 : 0] filtered_req;
reg  [N - 1 : 0] p_enc [P - 1 : 0];
//reg  busy_next = 0;
//reg  [P * N - 1 : 0] port_req = 0;
wire [P - 1 : 0] trans_p_enc [N - 1 : 0];
wire [N - 1 : 0] filtered_enc;
wire [N - 1 : 0] grant;
generate
   genvar i,j;
   for(i = 0; i < P; i = i + 1) begin:trans_req
      for(j = 0; j < N; j = j + 1) begin:sub_trans_req
         assign request[i][j] = i_port_req[i * N + j];
         assign trans_request[j][i] = i_port_req[i * N + j] & gnt_priority[P - 1 - i];
         assign trans_p_enc[j][i] = p_enc[i][j] & gnt_priority[P - 1 - i];
      end
      assign has_priority[P - 1 - i] = | request[i];
      //assign o_grant_priority[i] = i_busy ?  0 : gnt_priority[P - 1 - i]; 
      assign o_grant_priority[i] =  gnt_priority[P - 1 - i]; 
   end
   for(i = 0; i < N; i = i + 1) begin:filt_req
      assign filtered_req[i] = | trans_request[i];
      assign filtered_enc[i] = | trans_p_enc[i];
   end
   for(i = 0;i < P; i = i + 1) begin:rd_rb_gp
      if (ODD == 1) begin:clockwise
          always @(posedge clk) begin
               if (reset) begin
                   p_enc[i] <= 0;
               end
               else begin
                   //if ((~busy_next) & i_busy & i_random_robin & gnt_priority[P - 1 - i]) begin
                   if (i_busy & i_random_robin & gnt_priority[P - 1 - i]) begin
                        p_enc[i] <= {grant[N - 2 : 0], 1'b0};
                   end
               end
           end
      end
      else begin:anticlockwise
           always @(posedge clk) begin
                if (reset) begin
                     p_enc[i] <= 0;
                end
                else begin
                      //if ((~busy_next) & i_busy & i_random_robin & gnt_priority[P - 1 - i]) begin
                      if (i_busy & i_random_robin & gnt_priority[P - 1 - i]) begin
                          p_enc[i] <= {1'b0, grant[N - 2 : 0]};
                      end
                end
           end
       end
   end
endgenerate
simple_priority_encoder #(
.N (P)
) spe_u (
 .in_request (has_priority),
 .out_grant (gnt_priority)
);
program_priority_encoder_v1_0#(
.N (N)
) ppe_v1_0 (
.in_p_enc (filtered_enc),
.in_req (filtered_req),
.out_grant (grant)
);
//always @(posedge clk) begin
//   //busy_next <= i_busy;
//   //port_req <= i_port_req;
//end
//assign o_port_grant = i_busy ?  0 : grant;
assign o_port_grant =  grant;
endmodule
