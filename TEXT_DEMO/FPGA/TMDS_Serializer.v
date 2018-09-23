// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on

module ComponentShift
( input [9:0] Data,
  input PixClk5,
  input Sync,
  output SerOut
);

  reg [9:0] ShiftReg;

  initial
    begin
	   ShiftReg = 10'b0000000000;
	 end
  
  always @(posedge PixClk5)
    begin
	   if (Sync == 1'b1)
		   begin
			  ShiftReg = Data;
			end
		else
		   begin
			  ShiftReg = {2'b00, ShiftReg[9:2]};
			end
    end	 
  
  DDIO ddio(.datain_h(ShiftReg[1]), .datain_l(ShiftReg[0]), .outclock(PixClk5), .dataout(SerOut));
  
endmodule

// ----------------------------------------------------------------------------------

module ClockSync
( input PixClk,
  input PixClk5,
  output reg Sync
);

  reg [2:0] Status;

  initial
    begin
	   Status = 3'h0;
	   Sync = 1'b0;
	 end

  always @(posedge PixClk5)
    begin
	   case(Status)
		  3'h0: begin
		          if (PixClk == 1'b1) Status = 3'h1;
					 else Status = 3'h2;
		        end
		  3'h1: begin
		          if (PixClk == 1'b1) Status = 3'h1;
					 else Status = 3'h3;
              end		  
		  3'h2: begin
		          if (PixClk == 1'b1) Status = 3'h1;
					 else Status = 3'h2;
              end		  
		  3'h3: begin
		          if (PixClk == 1'b1) Status = 3'h0;
					 else Status = 3'h4;
              end		  
		  3'h4: begin
		          Status = 3'h0;
              end		  
		  default: begin
		             Status = 3'h0;
		           end
		endcase
    end	 

  always @(negedge PixClk5)
    begin
	   Sync = (Status == 3'h3) ? 1'b1 : 1'b0;
    end	 
	 
endmodule

// ----------------------------------------------------------------------------------

module TMDS_Serializer 
( input [9:0] RedEncoded, 
  input [9:0] BlueEncoded, 
  input [9:0] GreenEncoded,
  input PixClk, 
  input PixClk5, 
  output [3:0] TMDS /* synthesis ALTERA_ATTRIBUTE = "FAST_OUTPUT_REGISTER=ON"  */
);

  wire Sync;

  ClockSync       CS(.PixClk(PixClk), .PixClk5(PixClk5), .Sync(Sync));
  
  ComponentShift  CSB(.Data(BlueEncoded),    .PixClk5(PixClk5), .Sync(Sync), .SerOut(TMDS[0]));
  ComponentShift  CSG(.Data(GreenEncoded),   .PixClk5(PixClk5), .Sync(Sync), .SerOut(TMDS[1]));
  ComponentShift  CSR(.Data(RedEncoded),     .PixClk5(PixClk5), .Sync(Sync), .SerOut(TMDS[2]));
  ComponentShift  CSC(.Data(10'b0000011111), .PixClk5(PixClk5), .Sync(Sync), .SerOut(TMDS[3]));

endmodule
