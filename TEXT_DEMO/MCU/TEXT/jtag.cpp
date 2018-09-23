/******************************************************************************
*                                                                             *
* FILE: jtag.cpp                                                              *
*                                                                             *
******************************************************************************/

#include <Arduino.h>
#include "jtag.h"
#include "RLE.h"

extern void enableFpgaClock(void);

static int JTAG_Tick(int tms, int tdi)
{ digitalWrite(PIN_TCK, LOW);
  digitalWrite(PIN_TMS, tms);
  digitalWrite(PIN_TDI, tdi);
  digitalWrite(PIN_TCK, HIGH);
  return(digitalRead(PIN_TDO));
}

static void JTAG_TMSPath(int num, int path)
{ for(int i=0; i<num; i++)
     { JTAG_Tick(((path & 0x00000001) ? HIGH : LOW), LOW);
       path = path >> 1;
     }
}

static void JTAG_ShiftIR()
{ JTAG_Reset();
  JTAG_TMSPath(5, 0b00110);
}

static int JTAG_SendIR(int data)
{ int Ret = 0, M = 0x00000001;
  JTAG_ShiftIR();
  for(int i=0; i<9; i++, M<<=1)
     if (JTAG_Tick(LOW, (data & M) ? HIGH : LOW))
        Ret |= M;
  if (JTAG_Tick(HIGH, (data & M) ? HIGH : LOW))
     Ret |= M;
  return(Ret);
}

static unsigned char JTAG_SendDR8(int num, unsigned char data, int tms)
{ unsigned char Ret=0, M=0x01;
  for(int i=0; i<(num-1); i++, M<<=1)
     if (JTAG_Tick(LOW, (data & M) ? HIGH : LOW)) Ret |= M;
  if (JTAG_Tick(tms, (data & M) ? HIGH : LOW)) Ret |= M;
  return(Ret);
}

static void WaitTick(unsigned long Delay, int tms)
{ unsigned long Stop;
  Stop = micros() + Delay;
  while(Stop > micros())
       JTAG_Tick(tms, LOW);
}

// ----------------------------------------------------------------------------

void JTAG_Init()
{ pinMode(PIN_TCK, OUTPUT);
  pinMode(PIN_TMS, OUTPUT);
  pinMode(PIN_TDI, OUTPUT);
  pinMode(PIN_TDO, INPUT);
  digitalWrite(PIN_TCK, LOW);
  digitalWrite(PIN_TMS, LOW);
  digitalWrite(PIN_TDI, LOW);
}

void JTAG_Reset()
{ for(int i=0; i<5; i++)
     JTAG_Tick(HIGH, LOW);
}

int FPGA_Programming()
{ unsigned char Check[135];
  pinMode(32, OUTPUT);
  digitalWrite(32, LOW); // Red LED On
  delay(200);
  digitalWrite(32, HIGH); // Red LED Off
  delay(200);
  digitalWrite(32, LOW); // Red LED On
  delay(200);
  digitalWrite(32, HIGH); // Red LED Off
  delay(200);
  digitalWrite(32, LOW); // Red LED On
  delay(200);
  digitalWrite(32, HIGH); // Red LED Off
  delay(200);
  JTAG_SendIR(0x002);
  JTAG_TMSPath(2, 0b01);  // EXIT1_IR --> IDLE
  WaitTick(1000, LOW);    // Wait 1ms in IDLE
  JTAG_TMSPath(3, 0b001); // IDLE --> SHIFT_DR
  RLE_Init();
  for(int i=0; i<510881; i++) JTAG_SendDR8(8, RLE_GetNext(), LOW);
  JTAG_SendDR8(8, RLE_GetNext(), HIGH);
  JTAG_SendIR(0x004);
  JTAG_TMSPath(2, 0b01);  // EXIT1_IR --> IDLE
  WaitTick(5, LOW);       // Wait 5us in IDLE
  JTAG_TMSPath(3, 0b001); // IDLE --> SHIFT_DR
  for(int i=0; i<134; i++) Check[134-i] = JTAG_SendDR8(8, 0x00, LOW);
  Check[0] = JTAG_SendDR8(8, 0x00, HIGH);
  if ((Check[83] & 0x02) != 0x02) 
     { JTAG_Reset();
       return(-1);
     }
  JTAG_SendIR(0x003);
  JTAG_TMSPath(2, 0b01);  // EXIT1_IR --> IDLE
  WaitTick(4147, LOW);    // Wait 4147us in IDLE
  JTAG_SendIR(0x3FF);
  JTAG_TMSPath(2, 0b01);  // EXIT1_IR --> IDLE
  WaitTick(1000, LOW);    // Wait 1ms in IDLE
  digitalWrite(32, LOW); // Red LED On
  return(0);
}
