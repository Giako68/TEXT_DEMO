// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module Component_encoder
( input [7:0] Data,
  input C0,
  input C1,
  input DE,
  input PixClk,
  output [9:0] OutEncoded
);

  integer Cnt;
  integer NewCnt;
  reg [8:0] q_m;
  integer N1_Data;
  integer N1_qm;
  integer N0_qm;
  reg [9:0] Encoded;

  initial
    begin
      Cnt = 0;
		NewCnt = 0;
    end

  assign OutEncoded = Encoded;
  
  always @(posedge PixClk)
    begin
      N1_Data = Data[0] + Data[1] + Data[2] + Data[3] + Data[4] + Data[5] + Data[6] + Data[7];
	   if ((N1_Data > 4) || ((N1_Data == 4) && (Data[0] == 0)))
		   begin
			  q_m[0] = Data[0];
			  q_m[1] = ~(q_m[0] ^ Data[1]);
			  q_m[2] = ~(q_m[1] ^ Data[2]);
			  q_m[3] = ~(q_m[2] ^ Data[3]);
			  q_m[4] = ~(q_m[3] ^ Data[4]);
			  q_m[5] = ~(q_m[4] ^ Data[5]);
			  q_m[6] = ~(q_m[5] ^ Data[6]);
			  q_m[7] = ~(q_m[6] ^ Data[7]);
			  q_m[8] = 0;
			end
		else
		   begin
			  q_m[0] = Data[0];
			  q_m[1] = q_m[0] ^ Data[1];
			  q_m[2] = q_m[1] ^ Data[2];
			  q_m[3] = q_m[2] ^ Data[3];
			  q_m[4] = q_m[3] ^ Data[4];
			  q_m[5] = q_m[4] ^ Data[5];
			  q_m[6] = q_m[5] ^ Data[6];
			  q_m[7] = q_m[6] ^ Data[7];
			  q_m[8] = 1;
			end
      N1_qm = q_m[0] + q_m[1] + q_m[2] + q_m[3] + q_m[4] + q_m[5] + q_m[6] + q_m[7]; 
		N0_qm = 8 - N1_qm;
		if (DE == 1)
		   begin
			  if ((Cnt == 0) || (N1_qm == 4))
			     begin
					 if (q_m[8] == 0)
					    begin
  				         Encoded[9] = 1;
					      Encoded[8] = 0;
					      Encoded[7:0] = ~q_m[7:0];
					      NewCnt = Cnt + N0_qm - N1_qm;
						 end
					 else
					    begin
  				         Encoded[9] = 0;
					      Encoded[8] = 1;
					      Encoded[7:0] = q_m[7:0];
					      NewCnt = Cnt + N1_qm - N0_qm;
						 end
				  end
			  else
			     begin
				    if (((Cnt > 0) && (N1_qm > 4)) || ((Cnt < 0) && (N1_qm < 4)))
					    begin
					      if (q_m[8] == 0)
  				            begin
								  Encoded[9] = 1;
					           Encoded[8] = 0;
					           Encoded[7:0] = ~q_m[7:0];
					           NewCnt = Cnt + N0_qm - N1_qm;
								end
					      else
							   begin
  				              Encoded[9] = 1;
					           Encoded[8] = 1;
					           Encoded[7:0] = ~q_m[7:0];
					           NewCnt = Cnt + N0_qm - N1_qm + 2;
								end
						 end
					 else
                   begin
					      if (q_m[8] == 0)
  				            begin
								  Encoded[9] = 0;
					           Encoded[8] = 0;
					           Encoded[7:0] = q_m[7:0];
					           NewCnt = Cnt + N1_qm - N0_qm - 2;
								end
					      else
							   begin
  				              Encoded[9] = 0;
					           Encoded[8] = 1;
					           Encoded[7:0] = q_m[7:0];
					           NewCnt = Cnt + N1_qm - N0_qm;
								end
                   end						 
				  end
			end
      else
         begin
			  NewCnt = 0;
			  case({C0,C1})
			    2'b10:   Encoded = 10'b0010101011;
			    2'b01:   Encoded = 10'b0101010100;
			    2'b11:   Encoded = 10'b1010101011;
			    default: Encoded = 10'b1101010100;
			  endcase	 
         end			
	 end
  
  always @(negedge PixClk)
    begin
      Cnt = NewCnt;
    end  

endmodule
