module TEXT
( input PixClk,
  input [10:0] Row,
  input [10:0] Col,
  output reg [23:0] Pixel,
  input PixClk5,
  input SPI_CLK,
  input SPI_MOSI,
  input SPI_CS
);

  reg Blink;
  reg [23:0] BlinkCounter;

  wire [17:0] RamData;
  wire [11:0] RamAddr;
  wire [11:0] BaseAddr;
  wire [10:0] RomAddr;
  wire [7:0]  CharByte;
  wire        BitInChar;
  wire [23:0] Foreground;
  wire [23:0] Background;
  wire [11:0] WrAddr;
  wire [17:0] WrData;
  wire        WrEn;
  
  // BaseAddr = (Row / 8) * 80
  assign BaseAddr = ((Row[3] == 1'b1) ? 12'h050 : 12'h000) +
                    ((Row[4] == 1'b1) ? 12'h0A0 : 12'h000) +
						  ((Row[5] == 1'b1) ? 12'h140 : 12'h000) +
						  ((Row[6] == 1'b1) ? 12'h280 : 12'h000) +
						  ((Row[7] == 1'b1) ? 12'h500 : 12'h000) +
						  ((Row[8] == 1'b1) ? 12'hA00 : 12'h000);

  assign RamAddr = BaseAddr + {4'h0,Col[10:3]};

  assign RomAddr = {RamData[7:0], Row[2:0]};
  
  assign BitInChar = CharByte[Col[2:0]];
  
  assign Foreground = {(RamData[14] == 1'b1) ? {RamData[15],7'h7F} : 8'h00, 
                       (RamData[13] == 1'b1) ? {RamData[15],7'h7F} : 8'h00,
							  (RamData[12] == 1'b1) ? {RamData[15],7'h7F} : 8'h00};
							  
  assign Background = {(RamData[10] == 1'b1) ? {RamData[11],7'h7F} : 8'h00,
                       (RamData[9] == 1'b1)  ? {RamData[11],7'h7F} : 8'h00,
							  (RamData[8] == 1'b1)  ? {RamData[11],7'h7F} : 8'h00};							  
  
  
  
  initial
    begin
	   Pixel = 24'h000000;
		BlinkCounter = 24'h000000;
		Blink = 1'b0;
	 end

  always @(posedge PixClk)
    begin
	   BlinkCounter = BlinkCounter + 1;
		if (BlinkCounter >= 12600000)
		   begin
			  BlinkCounter = 24'h000000;
			  Blink = !Blink;
			end
    end	 
	 
  always @(negedge PixClk)
    begin
	   case({Blink,BitInChar,RamData[17:16]})
		  4'b0000: Pixel = Background;
		  4'b0001: Pixel = Background;
		  4'b0010: Pixel = Background;
		  4'b0011: Pixel = Background;
		  4'b0100: Pixel = Foreground;
		  4'b0101: Pixel = Foreground;
		  4'b0110: Pixel = Foreground;
		  4'b0111: Pixel = Foreground;
		  4'b1000: Pixel = Background;
		  4'b1001: Pixel = Background;
		  4'b1010: Pixel = Foreground;
		  4'b1011: Pixel = Foreground;
		  4'b1100: Pixel = Foreground;
		  4'b1101: Pixel = Background;
		  4'b1110: Pixel = Foreground;
		  4'b1111: Pixel = Background;
		  default: Pixel = Background;
		endcase
	 end

  VideoRAM VRAM(.clock(PixClk5), .data(WrData), .rdaddress(RamAddr), .wraddress(WrAddr), .wren(WrEn), .q(RamData));
  
  CharROM  CROM(.address(RomAddr), .clock(PixClk5), .q(CharByte));
  
  SPI      TSPI(.SPI_CLK(SPI_CLK), .SPI_MOSI(SPI_MOSI), .SPI_CS(SPI_CS), .PixClk5(PixClk5), .WrAddr(WrAddr), .WrData(WrData), .WrEn(WrEn));
	 
endmodule
