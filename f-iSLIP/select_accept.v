`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/09/14 16:57:32
// Design Name: 
// Module Name: select_accept
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
module select_accept#(
parameter N = 25,
parameter P = 8
)(
input clk,
input reset,
input i_busy,
input [N * P - 1 : 0] i_priority,
input [N - 1 : 0] i_port_grant,
output [N - 1 : 0] o_accept,
output [P - 1 : 0] o_priority
);
wire [N - 1 : 0] trans_priority [P - 1 : 0];
wire [P - 1 : 0] port_priority [N - 1 : 0];
wire [P - 1 : 0] filtered_priority;
wire [P - 1 : 0] acc_pri;
wire [N - 1 : 0] filtered_port;
//reg  [N * P - 1 : 0] priority_reg;
//reg  [N - 1 : 0] port_grant_reg;
reg  [N - 1 : 0] p_enc [P - 1 : 0];
wire [P - 1 : 0] trans_p_enc [N - 1 : 0];
wire [N - 1 : 0] filtered_enc;
wire [N - 1 : 0] accept;
//reg busy_next;
generate
   genvar i,j;
   for(j = 0; j < P; j = j + 1) begin:pri_pr_gp
      for(i = 0; i < N; i = i + 1) begin:sub_pri_pr_gp
         //assign trans_priority[j][i] = priority_reg[i * P + j] & port_grant_reg[i];
         assign trans_priority[j][i] = i_priority[i * P + j] & i_port_grant[i];
         //assign port_priority[i][j] = priority_reg[i * P + j] & i_port_grant_reg[i];
         assign port_priority[i][j] = i_priority[i * P + j] & i_port_grant[i];
         assign trans_p_enc[i][j] = p_enc[j][i] & acc_pri[P - 1 - j];
      end
      assign filtered_priority[P - 1 - j] = | trans_priority[j];
      //assign o_priority[j] = i_busy ?  0 : acc_pri[P - 1 - j];
      assign o_priority[j] = acc_pri[P - 1 - j];
   end
   for(i = 0; i < N; i = i + 1)begin:filtered_port_gp
      //assign filtered_port[i] = (port_grant_reg[i]) && (o_priority == port_priority[i]);
      assign filtered_port[i] = (i_port_grant[i]) && (o_priority == port_priority[i]);
      assign filtered_enc[i] = | trans_p_enc[i];
   end
   for(i = 0;i < P; i = i + 1) begin:rd_rb_gp
      always @(posedge clk) begin
          if (reset) begin
              p_enc[i] <= 0;
          end
          else begin
              //if ((~busy_next) & i_busy & acc_pri[P - 1 - i]) begin
              if (i_busy & acc_pri[P - 1 - i]) begin
                  p_enc[i] <= {accept[N - 2 : 0], 1'b0};
              end
          end
      end
   end
endgenerate
simple_priority_encoder #(
.N (P)
) spe_u (
.in_request (filtered_priority),
.out_grant (acc_pri)
);
program_priority_encoder_v1_0#(
.N (N)
) ppe_v1_0 (
.in_p_enc (filtered_enc),
.in_req (filtered_port),
.out_grant (accept)
);
//always @(posedge clk) begin
//   //busy_next <= i_busy;
//   priority_reg <= i_priority;
//   port_grant_reg <= i_port_grant;
//end
//assign o_accept = i_busy ?  0 : accept;
assign o_accept = accept;
endmodule
