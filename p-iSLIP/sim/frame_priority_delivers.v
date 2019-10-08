`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/10/21 10:36:09
// Design Name: 
// Module Name: frame_priority_delivers
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


module frame_priority_delivers#(
parameter PERIOD = 8,
parameter PORT = 8,
parameter PRIORITY = 4,
parameter WIDTH = 32,
parameter FRAME_BYTES = 64,
// 10 :100%, 1 : 10%
parameter BANDWIDTH = 10,
// 10 : 10 ns 100Mb 1 : 1 ns 1Gb
parameter SPEED = 10
)(
input clk,
input [PORT - 1 : 0] i_acc_grant,
input [PRIORITY - 1 : 0] i_acc_pri,
output reg o_rd,
output reg [PRIORITY - 1 : 0] o_rd_pri, 
output reg o_in_busy,
output reg [PORT - 1 : 0] o_out_busy
);

localparam IDLE = 2'b00;
localparam GRANT = 2'b01;
localparam WAITING = 2'b10;
localparam CLEAR = 2'b11;

reg [PORT - 1 : 0] out_busy = 0;
reg [WIDTH - 1 : 0] sending_time = 0;
reg [1 : 0] state = 0;
always @(posedge clk) begin
    case (state)
        GRANT: begin
            o_out_busy <= i_acc_grant;
            o_in_busy <= | i_acc_grant;
            o_rd <= | i_acc_grant;
            o_rd_pri <= i_acc_pri;
            if (|i_acc_grant) begin
               state <= WAITING;
               sending_time <= (((FRAME_BYTES + 4 + 4) * 8 + 96) * SPEED * 10 / (BANDWIDTH * PERIOD));
            end 
            else begin
               state <= GRANT;
               sending_time <= 0;
            end
       end
       WAITING:begin
           o_rd <= 0;
           sending_time <= sending_time - (|sending_time);
           if(sending_time == 0) begin
              state <= GRANT;
           end
           else begin
              state <= WAITING;
           end
       end
       default: begin
          o_rd <= 0;
          o_out_busy <= 0;
          o_in_busy <= 0;
          o_rd_pri <= 0;
          sending_time <= 0;
          state <= GRANT;
       end
    endcase
end
endmodule