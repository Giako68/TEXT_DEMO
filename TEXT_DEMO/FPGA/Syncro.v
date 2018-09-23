// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module Syncro
( input PixClk,
  output reg HSync,
  output reg VSync,
  output reg Video,
  output reg [10:0] Row,
  output reg [10:0] Col
);

  // -----------------------------------
  // 640x360@60Hz  -- PixClk = 25.200MHz
  // -----------------------------------
  parameter integer H_sync_start = 656;     
  parameter integer H_sync_stop = 751;
  parameter integer H_img_start = 0;
  parameter integer H_img_stop = 639;
  parameter integer H_screen_stop = 799;
  parameter integer H_polarity = 1'b0;
  parameter integer V_sync_start = 361;
  parameter integer V_sync_stop = 364;
  parameter integer V_img_start = 0;
  parameter integer V_img_stop = 359;
  parameter integer V_screen_stop = 449;
  parameter integer V_polarity = 1'b0;
			
  
  initial
    begin
	   Row = 11'h000;
		Col = 11'h000;
      HSync = 1'b0;
		VSync = 1'b0;
		Video = 1'b0;
	 end

  always @(negedge PixClk)
    begin
		HSync = ((Col < H_sync_start) || (Col > H_sync_stop)) ? !H_polarity : H_polarity;
      VSync = ((Row < V_sync_start) || (Row > V_sync_stop)) ? !V_polarity : V_polarity;
		Video = ((Col < H_img_start) || (Row < V_img_start) || (Col > H_img_stop) || (Row > V_img_stop)) ? 1'b0 : 1'b1;
		Col = Col + 1;
		if (Col > H_screen_stop)
		  begin
			 Col = 0;
			 Row = Row + 1;
			 if (Row > V_screen_stop)
				begin
				  Row = 0;
				end
		  end
    end	 

endmodule
