///////////////////////////////////////////////////////////////////////////////
// $Id: small_fifo.v 4761 2008-12-27 01:11:00Z jnaous $
//
// Module: small_fifo.v
// Project: UNET
// Description: small fifo with no fallthrough i.e. data valid after rd is high
//
// Change history:
//   7/20/07 -- Set nearly full to 2^MAX_DEPTH_BITS - 1 by default so that it
//              goes high a clock cycle early.
//   11/2/09 -- Modified to have both prog threshold and almost full
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps

  module small_fifo
    #(parameter WIDTH = 32,
      parameter MAX_DEPTH_BITS = 3,
      parameter PROG_FULL_THRESHOLD = 2**MAX_DEPTH_BITS - 1
      )
    (

     input [WIDTH-1:0] din,     // Data in
     input          wr_en,   // Write enable

     input          rd_en,   // Read the next word

     output reg [WIDTH-1:0]  dout,    // Data out
     output         full,
     output         nearly_full,
     output         prog_full,
     output         empty,

     input          reset,
     input          clk
     );


parameter MAX_DEPTH        = 2 ** MAX_DEPTH_BITS;

reg [WIDTH-1:0] queue [MAX_DEPTH - 1 : 0];
reg [MAX_DEPTH_BITS - 1 : 0] rd_ptr;
reg [MAX_DEPTH_BITS - 1 : 0] wr_ptr;
reg [MAX_DEPTH_BITS : 0] depth;

// Sample the data
always @(posedge clk)
begin
   if (reset) begin
       dout <= 0;
   end
   else begin
      if (wr_en && (depth != MAX_DEPTH))
         queue[wr_ptr] <= din;
      if (rd_en && (depth != 'h0))
         dout <=
	      // synthesis translate_off
	      #1
	      // synthesis translate_on
	      queue[rd_ptr];
   end
end

always @(posedge clk)
begin
   if (reset) begin
      rd_ptr <= 'h0;
      wr_ptr <= 'h0;
      depth  <= 'h0;
   end
   else begin
      if (wr_en && (depth != MAX_DEPTH)) wr_ptr <= wr_ptr + 1'h1;
      if (rd_en && (depth != 'h0)) rd_ptr <= rd_ptr + 1'h1;
      if (wr_en & ~rd_en)begin
            if(depth == MAX_DEPTH)begin
                depth <= 
                   #1
                   depth;
            end
            else begin
                 depth <=
				   // synthesis translate_off
				   #1
				   // synthesis translate_on
				   depth + 1'h1;
			end
	   end
      else if (~wr_en & rd_en)begin
            if(depth == 'h0)begin
                depth <= 
                    #1
                    'h0;
            end
            else begin
  
                 depth <=
				   // synthesis translate_off
				   #1
				   // synthesis translate_on
				   depth - 1'h1;
		    end
	 end
   end
end

//assign dout = queue[rd_ptr];
assign full = depth == MAX_DEPTH;
assign prog_full = (depth >= PROG_FULL_THRESHOLD);
assign nearly_full = depth >= MAX_DEPTH-1;
assign empty = depth == 'h0;

// synthesis translate_off
always @(posedge clk)
begin
   if (wr_en && depth == MAX_DEPTH && !rd_en)
      $display($time, " ERROR: Attempt to write to full FIFO: %m");
   if (rd_en && depth == 'h0)
      $display($time, " ERROR: Attempt to read an empty FIFO: %m");
end
// synthesis translate_on

endmodule // small_fifo


/* vim:set shiftwidth=3 softtabstop=3 expandtab: */
