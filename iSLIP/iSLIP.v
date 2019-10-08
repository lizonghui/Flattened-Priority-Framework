`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/09/13 20:21:45
// Design Name: 
// Module Name: piSLIP
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


module iSLIP #(
parameter N = 12,
parameter P = 1,
parameter ITER = 3,
parameter LOGITER = 2
)(
input     clk,
input     reset,
input     [N * N * P - 1 : 0]   i_priority,
input     [N - 1 : 0]           i_input_idle,
input     [N - 1 : 0]           i_output_idle,
output reg  [N * N - 1 : 0]     o_acc_grant,
output reg  [N * P - 1 : 0]     o_acc_priority
);
wire [N * P - 1 : 0] pri_req [N - 1 : 0];
wire [N * P - 1 : 0] port_req [N - 1 : 0];
wire [N - 1 : 0] port_grant [N - 1 : 0];
wire [N - 1 : 0] trans_port_grant [N - 1 : 0];
wire [N * P - 1 : 0] grant_priority;

wire [N - 1 : 0]  busy_input;
wire [N - 1 : 0]  busy_output;
wire [N * N * P - 1 : 0] req;
reg [N * N * P - 1 : 0 ] req_next = 0;
wire [N * N * P - 1 : 0] req_filtered;

wire [N * N - 1 : 0] acc_grant;
reg [N * N - 1 : 0] pre_acc_grant = 0;
wire [N * P - 1 : 0] acc_priority;
reg [N * P - 1 : 0] pre_acc_pri = 0;
wire [N - 1 : 0] accept [N - 1 : 0];
wire [N - 1 : 0] trans_accept [N - 1 : 0];

reg [LOGITER - 1 : 0] iterator = 0;
reg [1 : 0] state = 0;
localparam IDLE = 2'b00;
localparam SCHEDULE = 2'b01;
localparam RESULT = 2'b10;
localparam DELAY = 2'b11;

generate
   genvar i,j,k;
   for(i = 0; i < N; i = i + 1)begin:pri_req_gp
   select_request#(
   .N (N),
   .P (P)
   ) select_request_u (
   .i_request (req_next[(i + 1) * N * P - 1 : i * N * P]),
   .o_request (pri_req[i])
   );
   select_grant# (
   .N (N),
   .P (P)
   ) select_grant_u (
   .clk (clk),
   .reset (reset),
   .i_busy (busy_output[i]),
   .i_random_robin (iterator == 0),
   .i_port_req (port_req[i]),
   .o_port_grant (port_grant[i]),
   .o_grant_priority (grant_priority[(i + 1) * P - 1 : i * P])
   );
   select_accept#(
   .N (N),
   .P (P)
   ) select_accept_u (
   .clk (clk),
   .reset (reset),
   .i_busy (busy_input[i]),
   .i_priority (grant_priority),
   .i_port_grant (trans_port_grant[i]),
   .o_accept (acc_grant[(i + 1) * N - 1 : i * N]),
   .o_priority (acc_priority[(i + 1) * P - 1 : i * P])
   );
   end
   for(i = 0; i < N; i = i + 1) begin:trans_req_gp
      for(j = 0; j < N; j = j + 1) begin:sub_trans_req_gp
         for(k = 0; k < P; k = k + 1) begin:sub_sub_trans_req_gp
            assign port_req[i][k * N + j] = pri_req[j][k * N + i];
            assign req[j * N * P + k * N + i] = i_priority[j * N * P + k * N + i] & (i_input_idle[j]) & (i_output_idle[i]);
            assign req_filtered[j * N * P + k * N + i] = req_next[j * N * P + k * N + i] & (~busy_input[j]) & (~busy_output[i]);
         end
         assign trans_port_grant[i][j] = port_grant[j][i];
         assign accept[i][j] = acc_grant[i * N + j];
         assign trans_accept[j][i] = acc_grant[i * N + j];
      end
      assign busy_input[i] = | accept[i];
      assign busy_output[i] = | trans_accept[i];
   end
endgenerate

always @(posedge clk) begin
    case (state)
    IDLE: begin
       state <= SCHEDULE;
       req_next <= req;
       pre_acc_grant <= 0;
       pre_acc_pri <= 0;
       o_acc_grant <= 0;
       o_acc_priority <= 0;
       iterator <= 0;
    end
    SCHEDULE: begin
       if(iterator == ITER) begin
           state <= RESULT;
       end
       else begin
           state <= SCHEDULE;
       end
       req_next <= req_filtered;
       pre_acc_grant <= acc_grant | pre_acc_grant;
       pre_acc_pri   <= acc_priority | pre_acc_pri;
       o_acc_grant <= 0;
       o_acc_priority <= 0;
       iterator <= iterator + 1;
    end
    RESULT: begin
        state <= DELAY;
        req_next <= 0;
        pre_acc_grant <= 0;
        pre_acc_pri <= 0;
        o_acc_grant <= pre_acc_grant;
        o_acc_priority <= pre_acc_pri;
        iterator <= 0;
    end
    DELAY: begin
        state <= IDLE;
        req_next <= 0;
        pre_acc_grant <= 0;
        pre_acc_pri <= 0;
        o_acc_grant <= 0;
        o_acc_priority <= 0;
        iterator <= 0;
    end
    default:begin
        state <= IDLE;
        req_next <= 0;
        pre_acc_grant <= 0;
        pre_acc_pri <= 0;
        o_acc_grant <= 0;
        o_acc_priority <= 0;
        iterator <= 0;
    end
    endcase
end
endmodule
