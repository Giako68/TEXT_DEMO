/******************************************************************************
*                                                                             *
* FILE: RLE.cpp                                                               *
*                                                                             *
******************************************************************************/

#include "RLE.h"

static unsigned char RLE_Data[] = { 
#include "FPGA_Image_RLE.h"
};

static int RLE_Index;
static int RLE_Counter;
static int RLE_Status;
static unsigned char RLE_Value;

void RLE_Init()
{ RLE_Status = 0;
  RLE_Counter = 0;
  RLE_Value = 0x00;
  RLE_Index = 0;
}

unsigned char RLE_GetNext()
{ unsigned char c;
  switch(RLE_Status)
        { case 0: c = RLE_Data[RLE_Index++];
                  if (c & 0x80)
                     { RLE_Status = 2;
                       RLE_Counter = (c & 0x7F) + 2;
                       RLE_Value = RLE_Data[RLE_Index++];
                       return(RLE_Value);
                     }
                  RLE_Status = 1;
                  RLE_Counter = (c & 0x7F);
          case 1: RLE_Value = RLE_Data[RLE_Index++];
          case 2: if ((--RLE_Counter) == 0) RLE_Status = 0;
                  return(RLE_Value);
        }
  return(0);
}
