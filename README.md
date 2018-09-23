# TEXT_DEMO
Arduino MKR VIDOR 4000 -- HDMI Text Screen demo 

__In this project__
- Loading the FPGA directly into RAM instead of the external Flash.
- DVI OUT 640x360 (all the pixels are identical and square, both on 1280x720 screens and on 1920x1080 screens).
- Text format: 45 lines by 80 columns.
- Character format: 8x8 pixels.
- Each cell of the VideoRAM is made up of 18 bits.
- MCU-FPGA interface via SPI.

__VideoRAM cell format__

- Bits 17..16: Blink Attribute.
  * 00: Normal.
  * 01: Foreground Blink.
  * 10: Background Blink.
  * 11: Foreground & Background Blink.

- Bits 15..12: Foreground Color.
  * Bit 15: Full/Half brightness.
  * Bit 14: Red Component.
  * Bit 13: Green Component.
  * Bit 12: Blue Component.
  
- Bits 11..8: Background Color.
  * Bit 11: Full/Half brightness.
  * Bit 10: Red Component.
  * Bit 9:  Green Component.
  * Bit 8:  Blue Component.
  
- Bits 7..0: Character (used as an index in the CharROM).

__SPI Commands__

- __WriteRAW:__ Writes 18-bit character sequences to VideoRAM.

  First byte: 0x80
  
  Second byte: The 4 most significant bits of the address are loaded into the 4 least significant bits of this byte.
  
  Third byte: The 8 least significant bits of the address.
  
  From the fourth byte: Sequence of characters to be written, each consisting of 3 bytes (Blink, Color, Char).
  
  _Writing ends by setting the CS signal low._
  
- __WriteChar:__ Writes a sequence of characters using the blink and color attributes of the previous writing.

  First byte: 0x81
  
  From the second byte: Sequence of characters, one byte per character.
  
  _Writing ends by setting the CS signal low._
  
- __SetLocation:__ Set the address for the following writes.

  First byte: 0x82
  
  Second byte: The 4 most significant bits of the address are loaded into the 4 least significant bits of this byte.
  
  Third byte: The 8 least significant bits of the address.
  
  _It can be followed by a further command without the need to lower and raise the CS signal._
  
- __SetAttribute:__ Set the Blink, Foreground, and Background attributes for the following writes.

  First byte: 0x83
  
  Second byte: The two least significant bins of this byte are used for the Blink attribute.
  
  Third byte: The most significant 4 bits are the Foreground, while the 4 least significant bits are the Background.
  
  _It can be followed by a further command without the need to lower and raise the CS signal._
  
- __Repeat:__ He writes the same character for _Size_ times.

  First byte: 0x84
  
  Second byte: The 4 most significant bits of the _Size_ parameter.
  
  Third byte: The 8 least significant bits of the _Size_ parameter.
  
  Fourth byte: The character to be repeated.
  
_The TEXT.ino file defines functions that use these SPI commands._

  
  
