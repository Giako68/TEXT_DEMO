/******************************************************************************
*                                                                             *
* FILE: jtag.h                                                                *
*                                                                             *
******************************************************************************/

#ifndef _JTAG_H_
#define _JTAG_H_

#define PIN_TCK 27
#define PIN_TMS 28
#define PIN_TDI 26
#define PIN_TDO 29

void JTAG_Init(void);
void JTAG_Reset(void);
int  FPGA_Programming(void);

#endif
