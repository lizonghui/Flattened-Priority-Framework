`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/10/20 22:01:23
// Design Name: 
// Module Name: frame_priority_arrivals
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


module frame_priority_arrivals#(
parameter ID = 0,
parameter WIDTH = 32,
parameter PORT = 8,
parameter PRIORITY = 4,
parameter FRAME_BYTES = 64,
//0:uniform, 1:bernoulli, 2:markov
parameter SEL_DSTRI = 0,
// 10 :100%, 1 : 10%
parameter BANDWIDTH = 10,
// 10 :100%, 1 : 10%
parameter FREE = 5,
// 10 : 10 ns 100Mb 1 : 1 ns 1Gb
parameter SPEED = 10
)(
input clk,
output reg o_wr,
output reg [PORT - 1 : 0] o_wr_port,
output reg [PRIORITY - 1 : 0] o_wr_pri,
output reg [WIDTH - 1 : 0] o_time
);

integer seed;
initial begin
seed = ID;
end

reg frame_arrival =  0;
reg frame_arrival_next = 0;
reg [63 :0] counter = 0;
reg [3 : 0] p_on = 0;
reg [3:  0] p_off = 0;
reg state = 0;

localparam ONLOAD = 1'b0;
localparam OFFLOAD = 1'b1;

generate
case (SEL_DSTRI)
2'b01:begin
    //bernoulli arrival
    always begin
         #(((FRAME_BYTES + 4 + 4) * 8 + 96) * SPEED);
//         p_on = {$random($time + counter + ID * 100000000)} % 10;
         p_on = {$random(seed)} % 10;
         if(p_on < BANDWIDTH) begin
             frame_arrival = ~ frame_arrival;
             counter = counter + (((FRAME_BYTES + 4 + 4) * 8 + 96) * SPEED);
         end
         else begin
             frame_arrival = frame_arrival;
         end
     end
end
2'b10: begin
     //two-state Markov-modulated arrival process
     always begin
           #(((FRAME_BYTES + 4 + 4) * 8 + 96) * SPEED);
           case(state)
                ONLOAD:begin
                    frame_arrival = ~ frame_arrival;
//                    p_on = {$random($time + counter + ID * 100000000)} % 10;
                    p_on = {$random(seed)} % 10;
                    if(p_on < BANDWIDTH) begin
                         state = ONLOAD;
                    end
                    else begin
                        state = OFFLOAD;
                    end
                    counter = counter + (((FRAME_BYTES + 4 + 4) * 8 + 96) * SPEED);
                end
                OFFLOAD:begin
//                    p_off = {$random($time + counter + ID * 100000000)} % 10;
                    p_off = {$random(seed)} % 10;
                    if(p_off < FREE) begin
                         state = OFFLOAD;
                    end
                    else begin
                        state = ONLOAD;
                    end
                    frame_arrival = frame_arrival;
                end
                default:begin
                    state = ONLOAD;
                    frame_arrival = 0;
                    counter = 0;
                end
           endcase
      end
end
default: begin
    //uniform arrival
    always begin
        #(((FRAME_BYTES + 4 + 4) * 8 + 96) * SPEED * 10 / BANDWIDTH);
        frame_arrival = ~ frame_arrival;
    end
end
endcase
endgenerate
always @(posedge clk) begin
    frame_arrival_next <= frame_arrival;
    if (frame_arrival_next != frame_arrival) begin
       o_wr <= 1;
       o_time <= $time;
       //o_wr_port <= 'b1 << ({$random($time + ID * 1000000)} % PORT);
       //o_wr_pri <= 'b1 << ({$random($time + ID * 100000000)} % PRIORITY);
       o_wr_port <= 'b1 << ({$random(seed)} % PORT);
       o_wr_pri <= 'b1 << ({$random(seed)} % PRIORITY);
    end
    else begin
       o_wr <= 0;
       o_time <= 0;
       o_wr_port <= 0;
       o_wr_pri <= 0;
    end
end
endmodule