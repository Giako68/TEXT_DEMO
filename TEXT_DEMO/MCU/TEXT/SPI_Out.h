/******************************************************************************
*                                                                             *
* FILE: SPI_Out.h                                                             *
*                                                                             *
******************************************************************************/

#ifndef _SPI_OUT_H_
#define _SPI_OUT_H_

#include <Arduino.h>

class SPI_Out
{ private: 
  int SPI_MOSI, SPI_CLK, SPI_CS;

  public: 
  SPI_Out(int MOSI, int CLK, int CS)
         { SPI_MOSI = MOSI;
           SPI_CLK = CLK;
           SPI_CS = CS;
           pinMode(SPI_MOSI, OUTPUT);
           pinMode(SPI_CLK, OUTPUT);
           pinMode(SPI_CS, OUTPUT);
           digitalWrite(SPI_MOSI, LOW);
           digitalWrite(SPI_CLK, LOW);
           digitalWrite(SPI_CS, LOW);
         }

  void StartTransfert()
       { digitalWrite(SPI_CS, HIGH);
       }                

  void StopTransfert()
       { digitalWrite(SPI_CS, LOW);
       }                

  void Send(unsigned char Data)
       { for(int i=0; i<8; i++)
            { digitalWrite(SPI_MOSI, ((Data & 0x80) == 0x80) ? HIGH : LOW);
              digitalWrite(SPI_CLK, HIGH);
              digitalWrite(SPI_CLK, LOW);
              Data = Data << 1;
            }
       }

};

#endif
