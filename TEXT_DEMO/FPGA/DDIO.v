module DDIO
( input datain_h, 
  input datain_l, 
  input outclock, 
  output dataout
);

  reg DataL;
  reg DataH;
  reg DataT;
  
  assign dataout = (outclock == 1'b1) ? DataT : DataL;
  
  always @(negedge outclock)
    begin
	   DataT = DataH;
	 end

  always @(posedge outclock)
    begin
	   DataL = datain_l;
		DataH = datain_h;
	 end
	 
endmodule
