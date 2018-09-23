#include "jtag.h"
#include "SPI_Out.h"

extern void enableFpgaClock(void);

SPI_Out SPI(8, 9, 7);

void TEXT_SetLocation(int Row, int Col)
{ unsigned short Addr = Row * 80 + Col;
  SPI.StartTransfert();
  SPI.Send(0x82);
  SPI.Send((Addr >> 8) & 0xFF);
  SPI.Send(Addr & 0xFF);
  SPI.StopTransfert();
}

void TEXT_SetAttribute(int Blink, int Foreground, int Background)
{ SPI.StartTransfert();
  SPI.Send(0x83);
  SPI.Send(Blink & 0x03);
  SPI.Send(((Foreground << 4) & 0xF0) | (Background & 0x0F)); 
  SPI.StopTransfert();
}

void TEXT_Print(char *Str)
{ SPI.StartTransfert();
  SPI.Send(0x81);
  for(int i=0; Str[i] != 0; i++)
     SPI.Send(Str[i]);
  delay(5);   
  SPI.StopTransfert();
}

void TEXT_PrintAt(int Row, int Col, char *Str)
{ unsigned short Addr = Row * 80 + Col;
  SPI.StartTransfert();
  SPI.Send(0x82);
  SPI.Send((Addr >> 8) & 0xFF);
  SPI.Send(Addr & 0xFF);
  SPI.Send(0x81);
  for(int i=0; Str[i] != 0; i++)
     SPI.Send(Str[i]);
  delay(5);   
  SPI.StopTransfert();
}

void TEXT_Repeat(char Ch, int Num)
{ SPI.StartTransfert();
  SPI.Send(0x84);
  SPI.Send((Num >> 8) & 0x0F);
  SPI.Send(Num & 0xFF);
  SPI.Send(Ch);
  delay(5);   
  SPI.StopTransfert();
}

void TEXT_ClearScreen(int Color)
{ SPI.StartTransfert();
  SPI.Send(0x82);                 // Set Location (0,0)
  SPI.Send(0x00);
  SPI.Send(0x00);
  SPI.Send(0x83);                 // Set Background = Color
  SPI.Send(0x00);
  SPI.Send(Color & 0x0F);
  SPI.Send(0x84);                 // Write 3600 spaces
  SPI.Send(0x0E);
  SPI.Send(0x0F);
  SPI.Send(' ');
  delay(5);   
  SPI.StopTransfert();
}

void TEXT_PrintCharAt(int Row, int Col, char Ch)
{ unsigned short Addr = Row * 80 + Col;
  SPI.StartTransfert();
  SPI.Send(0x82);
  SPI.Send((Addr >> 8) & 0xFF);
  SPI.Send(Addr & 0xFF);
  SPI.Send(0x81);
  SPI.Send(Ch);
  delay(5);   
  SPI.StopTransfert();
}

void setup() 
{ JTAG_Init();
  JTAG_Reset();
  FPGA_Programming();
  enableFpgaClock();
  delay(1000);
  TEXT_ClearScreen(0);
  for(int y=0; y<16; y++)
     for(int x=0; x<16; x++)
        { TEXT_SetAttribute(0, 15, 7);
          TEXT_PrintCharAt(y+3, x+3, y*16+x);
        }
  for(int y=0; y<16; y++)
     for(int x=0; x<16; x++)
        { TEXT_SetAttribute(1, x, y);
          TEXT_PrintCharAt(y+3, x+22, y*16+x);
        }
  for(int y=0; y<16; y++)
     for(int x=0; x<16; x++)
        { TEXT_SetAttribute(2, x, y);
          TEXT_PrintCharAt(y+3, x+42, y*16+x);
        }
  for(int y=0; y<16; y++)
     for(int x=0; x<16; x++)
        { TEXT_SetAttribute(3, x, y);
          TEXT_PrintCharAt(y+3, x+61, y*16+x);
        }
  TEXT_SetAttribute(0, 9, 0);
  TEXT_PrintCharAt(0, 0, 0x1B);
  TEXT_Repeat(0x00, 77);
  TEXT_PrintCharAt(0, 79, 0x1C);
  for(int y=1; y<44; y++)
     { TEXT_PrintCharAt(y, 0, 0x0C);
       TEXT_PrintCharAt(y, 79, 0x10);
     }
  TEXT_PrintCharAt(21, 0, 0x19);
  TEXT_Repeat(0x04, 77);
  TEXT_PrintCharAt(21, 79, 0x1F);
  TEXT_PrintCharAt(44, 0, 0x19);
  TEXT_Repeat(0x04, 77);
  TEXT_PrintCharAt(44, 79, 0x1F);
  TEXT_SetAttribute(0, 10, 0);
  TEXT_PrintAt(24, 22, "#     # ### ######  ####### ###### ");
  TEXT_PrintAt(25, 22, "#     #  #  #     # #     # #     #");
  TEXT_PrintAt(26, 22, "#     #  #  #     # #     # #     #");
  TEXT_PrintAt(27, 22, "#     #  #  #     # #     # ###### ");
  TEXT_PrintAt(28, 22, " #   #   #  #     # #     # #   #  ");
  TEXT_PrintAt(29, 22, "  # #    #  #     # #     # #    # ");
  TEXT_PrintAt(30, 22, "   #    ### ######  ####### #     #");
  TEXT_SetAttribute(0, 12, 0);
  TEXT_PrintAt(32, 22, "  #         ###     ###     ###  ");
  TEXT_PrintAt(33, 22, "  #    #   #   #   #   #   #   # ");
  TEXT_PrintAt(34, 22, "  #    #  #     # #     # #     #");
  TEXT_PrintAt(35, 22, "  #    #  #     # #     # #     #");
  TEXT_PrintAt(36, 22, "  ####### #     # #     # #     #");
  TEXT_PrintAt(37, 22, "       #   #   #   #   #   #   # ");
  TEXT_PrintAt(38, 22, "       #    ###     ###     ###  ");
}

void loop() 
{ delay(500);
}

