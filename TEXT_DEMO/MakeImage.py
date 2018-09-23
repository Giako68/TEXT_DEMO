#!/usr/bin/env python

import sys, os

os.system("/opt/FPGA/intelFPGA_lite/18.0/quartus/bin/quartus_cpf -c -q 10MHz -g 3.3 -n v ./FPGA/output_files/TEXT_Demo.sof ./TEXT_Demo.svf")
print("Read .svf file...")
F = open("TEXT_Demo.svf", "rt")
D = F.readlines()
F.close()
S = []
s = ""
for d in D:
    if (d[0] != '!'):
       d = d.strip()
       s = s + d
       if (s[-1] == ';'):
          S.append(s)
          s = ""
r = ""
for s in S:
    if (s[0:17] == "SDR 4087056 TDI ("):
       r = s[17:]
       if (r[-2:] == ");"):
          r = r[0:-2]
RAW = []
while(len(r) >= 2):
     n = int(r[-2:], 16)
     r = r[0:-2]
     RAW.append(chr(n))
print("Run Length Encoding...")     
RLE = ""
Equ = ""
Equn = 0
Dif = ""
Temp = ""
idx = 0
while(idx < len(RAW)):
     r = RAW[idx]
     if (Temp != ""):
        if (r == Temp[0]):
           Temp = Temp + r
           if (len(Temp) == 3):
              Equn = 3
              Equ = Temp[0]
              Temp = ""
              if (len(Dif) > 0):
                 RLE = RLE + chr(len(Dif)) + Dif
                 Dif = ""
        else:
           Dif = Dif + Temp
           if (len(Dif) >= 126):
              RLE = RLE + chr(len(Dif)) + Dif
              Dif = ""
           Temp = r
     else:            
        if (Equn > 0):
           if (r == Equ):
              Equn = Equn + 1
              if (Equn == 130):
                 RLE = RLE + chr(0xFF) + Equ
                 Equ = ""
                 Equn = 0
           else:
              RLE = RLE + chr(0x80 | (Equn-3)) + Equ
              Equ = ""
              Equn = 0
              Temp = r
        else:
           Temp = r
     idx = idx + 1
if (Equn > 0):
   RLE = RLE + chr(0x80 | (Equn-3)) + Equ
if (len(Temp) > 0):
   Dif = Dif + Temp
if (len(Dif) > 0):
   RLE = RLE + chr(len(Dif)) + Dif
print("Write txt image file...")   
F = open("./MCU/TEXT/FPGA_Image_RLE.h", "wt")
Col = 0
for i in range(len(RLE)):
    F.write("0x%02X" % (ord(RLE[i])))
    if (i < (len(RLE) - 1)):
       F.write(", ")
    Col = Col + 1
    if (Col == 16):
       Col = 0
       F.write("\n")
F.close()
os.system("rm ./TEXT_Demo.svf")
print("*** Done!\n")
