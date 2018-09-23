// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module TEXT_Demo
( input Clk_48MHz,
  output [3:0] tmds_out_p,
  output [3:0] tmds_out_n,
  input SPI_CLK,
  input SPI_MOSI,
  input SPI_CS
);

  wire PixClk;
  wire PixClk5;
  wire HSync;
  wire VSync;
  wire Video;
  wire [9:0] encRed;
  wire [9:0] encGreen;
  wire [9:0] encBlue;
  wire [3:0] tmds_out;
  wire [23:0] Pixel;
  wire [10:0] Row;
  wire [10:0] Col;

  PLL             ClockGen(.inclk0(Clk_48MHz), .c0(PixClk), .c1(PixClk5));

  Syncro          SYN(.PixClk(PixClk), .HSync(HSync), .VSync(VSync), .Video(Video), .Row(Row), .Col(Col));
  
  TEXT            TXT(.PixClk(PixClk), .Row(Row), .Col(Col), .Pixel(Pixel), .PixClk5(PixClk5), .SPI_CLK(SPI_CLK), .SPI_MOSI(SPI_MOSI), .SPI_CS(SPI_CS));
  
  TMDS_encoder    ENC(.inRed(Pixel[23:16]), .inGreen(Pixel[15:8]), .inBlue(Pixel[7:0]), .Hsync(HSync), .Vsync(VSync), .PixClk(PixClk), .Video(Video), .outRed(encRed), .outGreen(encGreen), .outBlue(encBlue));
							 
  TMDS_Serializer SER(.RedEncoded(encRed), .BlueEncoded(encBlue), .GreenEncoded(encGreen), .PixClk(PixClk), .PixClk5(PixClk5), .TMDS(tmds_out));
							 
  DiffBuf         B_DB(.datain(tmds_out[0]), .dataout(tmds_out_p[0]), .dataout_b(tmds_out_n[0]));							 
  DiffBuf         G_DB(.datain(tmds_out[1]), .dataout(tmds_out_p[1]), .dataout_b(tmds_out_n[1]));							 
  DiffBuf         R_DB(.datain(tmds_out[2]), .dataout(tmds_out_p[2]), .dataout_b(tmds_out_n[2]));							 
  DiffBuf         C_DB(.datain(tmds_out[3]), .dataout(tmds_out_p[3]), .dataout_b(tmds_out_n[3]));							 
    
endmodule
