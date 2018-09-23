// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module TMDS_encoder
( input [7:0] inRed,
  input [7:0] inGreen,
  input [7:0] inBlue,
  input Hsync,
  input Vsync,
  input PixClk,
  input Video,
  output [9:0] outRed,
  output [9:0] outGreen,
  output [9:0] outBlue
);

  Component_encoder CE_Blue(.Data(inBlue),
                            .C0(Hsync),
									 .C1(Vsync),
                            .DE(Video),
                            .PixClk(PixClk),
									 .OutEncoded(outBlue));
									 
  Component_encoder CE_Red(.Data(inRed),
                            .C0(Hsync),
									 .C1(Vsync),
                            .DE(Video),
                            .PixClk(PixClk),
									 .OutEncoded(outRed));
									 
  Component_encoder CE_Green(.Data(inGreen),
                            .C0(Hsync),
									 .C1(Vsync),
                            .DE(Video),
                            .PixClk(PixClk),
									 .OutEncoded(outGreen));
									 
endmodule
