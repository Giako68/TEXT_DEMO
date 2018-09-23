
module SPI_Sampler
( input PixClk5,
  input SPI_CLK,
  input SPI_MOSI,
  input SPI_CS,
  output R_SPI_CLK,
  output R_SPI_MOSI,
  output R_SPI_CS
);

  reg [2:0] FirstReg;
  reg [2:0] SecondReg;
  
  assign R_SPI_CLK = SecondReg[0];
  assign R_SPI_MOSI = SecondReg[1]; 
  assign R_SPI_CS = SecondReg[2];
  
  initial
    begin
	   FirstReg = 3'b000;
		SecondReg = 3'b000;
	 end
  
  always @(negedge PixClk5)
    begin
	   FirstReg[0] = SPI_CLK;
		FirstReg[1] = SPI_MOSI;
		FirstReg[2] = SPI_CS;
	 end

  always @(negedge PixClk5)
    begin
	   SecondReg = FirstReg;
	 end

endmodule

// ----------------------------------------------------------------------

module SPI_SampReceiver
( input PixClk5,
  input SPI_CLK,
  input SPI_MOSI,
  input SPI_CS,
  output reg [7:0] Data,
  output reg DataFlag
);

  reg [7:0] Shift;
  reg [2:0] SpiStatus;
  reg OldClk;
  
  initial
    begin
	   Shift = 8'h00;
		Data = 8'h00;
		SpiStatus = 3'h0;
		DataFlag = 1'b0;
		OldClk = 1'b0;
	 end

  always @(posedge PixClk5)
    begin
	   if (SPI_CS == 1'b0) SpiStatus = 3'h0;
		else if (SPI_CLK != OldClk)
				  begin
                OldClk = SPI_CLK;
					 if (SPI_CLK == 1'b1)
					    begin
  				         Shift = {Shift[6:0],SPI_MOSI};
				         SpiStatus = SpiStatus + 3'h1;
						 end
					 else if (SpiStatus == 3'h0)
		                  begin
		                    Data = Shift;
		                    DataFlag = !DataFlag;
		                  end
			     end
	 end

endmodule

// ----------------------------------------------------------------------

module Commands
( input PixClk5,
  input DataFlag,
  input [7:0] Data,
  input SPI_CS,
  output reg [11:0] WrAddr,
  output reg [17:0] WrData,
  output reg WrEn
);

  reg [7:0] Status;
  reg [7:0] Command;
  reg DataRead;
  reg [11:0] Size;
  
  initial
    begin
	   Status = 8'h00;
		Command = 8'h00;
		DataRead = 1'b0;
		WrAddr = 12'h000;
		WrData = 18'h00000;
		WrEn = 1'b0;
		Size = 12'h000;
	 end

  always @(negedge PixClk5)
    begin
	   if (SPI_CS == 1'b0) 
		   begin
			  DataRead = DataFlag;
			  WrEn = 1'b0;
			  Status = 8'h00;
			end  
		else case(Status)
		       8'h00: if (DataFlag != DataRead)					// Wait For Command
				           begin
							    DataRead = DataFlag;
								 Command = Data;
								 Status = 8'h01;
							  end
						  else Status = 8'h00;
				 8'h01: case(Command)									// Dispatch Command
				          8'h80: Status = 8'h10;
							 8'h81: Status = 8'h20;
							 8'h82: Status = 8'h30;
							 8'h83: Status = 8'h40;
							 8'h84: Status = 8'h50;
							 default: Status = 8'h02;
	                 endcase
			    8'h02: Status = 8'h02;									// Unknown Command - Wait for CS low
				 8'h10: if (DataFlag != DataRead)					// Write Raw -- Wait for High Nibble Address
				           begin
							    DataRead = DataFlag;
								 WrAddr[11:8] = Data[3:0];
								 Status = 8'h11;
							  end
						  else Status = 8'h10;
				 8'h11: if (DataFlag != DataRead)					// Write Raw -- Wait for Low Byte Address
				           begin
							    DataRead = DataFlag;
								 WrAddr[7:0] = Data[7:0];
								 Status = 8'h12;
							  end
						  else Status = 8'h11;
				 8'h12: if (DataFlag != DataRead)					// Write Raw -- Wait for 2 bits Blink Attribute
				           begin
							    DataRead = DataFlag;
								 WrData[17:16] = Data[1:0];
								 Status = 8'h13;
							  end
						  else Status = 8'h12;
				 8'h13: if (DataFlag != DataRead)					// Write Raw -- Wait for Color Attribute
				           begin
							    DataRead = DataFlag;
								 WrData[15:8] = Data[7:0];
								 Status = 8'h14;
							  end
						  else Status = 8'h13;
				 8'h14: if (DataFlag != DataRead)					// Write Raw -- Wait for Char
				           begin
							    DataRead = DataFlag;
								 WrData[7:0] = Data[7:0];
								 WrEn = 1'b1;
								 Status = 8'h15;
							  end
						  else Status = 8'h14;
				 8'h15: begin
				          WrEn = 1'b0;									// disable writing on VideoRAM
							 WrAddr = WrAddr + 1;						// move cursor to next location
							 Status = 8'h12;								// prepare for next char
  					     end
				 8'h20: if (DataFlag != DataRead)				// Write Char -- Wait for Char
				           begin
							    DataRead = DataFlag;
								 WrData[7:0] = Data[7:0];
								 WrEn = 1'b1;
								 Status = 8'h21;
							  end
						  else Status = 8'h20;
				 8'h21: begin
				          WrEn = 1'b0;									// disable writing on VideoRAM
							 WrAddr = WrAddr + 1;						// move cursor to next location
							 Status = 8'h20;								// prepare for next char
  					     end
				 8'h30: if (DataFlag != DataRead)				// Set Location -- Wait for High Nibble Address
				           begin
							    DataRead = DataFlag;
								 WrAddr[11:8] = Data[3:0];
								 Status = 8'h31;
							  end
						  else Status = 8'h30;
				 8'h31: if (DataFlag != DataRead)				// Set Location -- Wait for Low Byte Address
				           begin
							    DataRead = DataFlag;
								 WrAddr[7:0] = Data[7:0];
								 Status = 8'h00;
							  end
						  else Status = 8'h31;
				 8'h40: if (DataFlag != DataRead)				// Set Attribute -- Wait for 2 bits Blink Attribute
				           begin
							    DataRead = DataFlag;
								 WrData[17:16] = Data[1:0];
								 Status = 8'h41;
							  end
						  else Status = 8'h40;
				 8'h41: if (DataFlag != DataRead)				// Set Attribute -- Wait for Color Attribute
				           begin
							    DataRead = DataFlag;
								 WrData[15:8] = Data[7:0];
								 Status = 8'h00;
							  end
						  else Status = 8'h41;
				 8'h50: if (DataFlag != DataRead)				// Repeat -- Wait for High Nibble Size
				           begin
							    DataRead = DataFlag;
								 Size[11:8] = Data[3:0];
								 Status = 8'h51;
							  end
						  else Status = 8'h50;
				 8'h51: if (DataFlag != DataRead)				// Repeat -- Wait for Low Byte Size
				           begin
							    DataRead = DataFlag;
								 Size[7:0] = Data[7:0];
								 Status = 8'h52;
							  end
						  else Status = 8'h51;
				 8'h52: if (DataFlag != DataRead)				// Repeat -- Wait for Char
				           begin
							    DataRead = DataFlag;
								 WrData[7:0] = Data[7:0];
								 WrEn = 1'b1;
								 Status = 8'h53;
							  end
						  else Status = 8'h52;
				 8'h53: if (Size == 12'h000)						// Repeat -- Loop for Size
				           begin
							    WrEn = 1'b0;
								 Status = 8'h00;
							  end
						  else begin
						         Size = Size - 12'h001;
									WrAddr = WrAddr + 12'h001;
									Status = 8'h53;
					          end	  
		     endcase
    end	 

endmodule

// ----------------------------------------------------------------------

module SPI
( input SPI_CLK,
  input SPI_MOSI,
  input SPI_CS,
  input PixClk5,
  output [11:0] WrAddr,
  output [17:0] WrData,
  output WrEn
);

  wire [7:0] Data;
  wire DataFlag;
  wire R_SPI_CLK;
  wire R_SPI_MOSI;
  wire R_SPI_CS;

  SPI_Sampler  SAMP(.PixClk5(PixClk5), .SPI_CLK(SPI_CLK), .SPI_MOSI(SPI_MOSI), .SPI_CS(SPI_CS), .R_SPI_CLK(R_SPI_CLK), .R_SPI_MOSI(R_SPI_MOSI), .R_SPI_CS(R_SPI_CS));
  
  SPI_SampReceiver RECV(.PixClk5(PixClk5), .SPI_CLK(R_SPI_CLK), .SPI_MOSI(R_SPI_MOSI), .SPI_CS(R_SPI_CS), .Data(Data), .DataFlag(DataFlag));

  Commands     CMD(.PixClk5(PixClk5), .DataFlag(DataFlag), .Data(Data), .SPI_CS(R_SPI_CS), .WrAddr(WrAddr), .WrData(WrData), .WrEn(WrEn));
	 
endmodule
