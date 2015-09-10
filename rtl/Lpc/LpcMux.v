///////////////////////////////////////////////////////////////////
// File name        : LpcMux.v
// Module name      : LpcMux
// Description      : This module is Data Multiplexer to LPC Read
// Hierarchy Up     : Lpc
// Hierarchy Down   : ---
///////////////////////////////////////////////////////////////////
////////////    LPC Bus CPLD Internal Memory Map    ///////////////
///////////////////////////////////////////////////////////////////
// Offset(H/B)        Name                                  Access
///////////////////////////////////////////////////////////////////
//   0    0x00    CPLD hardware version                RO
//   1    0x01    BIOS Watch Dog Control Register                R/W
//   2    0x02
//   3    0x03
//   4    0x04
//   5    0x05
//   6    0x06
//   7    0x07
//   8    0x08
//   9    0x09
//  10    0x0A
//  11    0x0B
//  12    0x0C
//  13    0x0D
//  14    0x0E    Seven Segment Digit Select Register            R/W
//  15    0x0F    Seven Segment Display Data Register            R/W
//  16    0x10
//  17    0x11
//  18    0x12
//  19    0x13
//  20    0x14
//  21    0x15
//  22    0x16
//  23    0x17
//  24    0x18
//  25    0x19
//  26    0x1A
//  27    0x1B
//  28    0x1C
//  29    0x1D
//  30    0x1E
//  31    0X1f    Not used
///////////////////////////////////////////////////////////////////
module LpcMux (
    PciReset,       // PCI Reset
    LpcClock,       // 33 MHz Lpc (LPC Clock)
    AddrReg,        // Address of the accessed Register
    reg_00,
    reg_01,
    reg_02,
    reg_03,
    reg_04,
    reg_05,
    reg_06,
    reg_07,
    reg_08,
    reg_09,
    reg_0a,
    reg_0b,
    reg_0c,
    reg_0d,
    reg_0e,
    reg_0f,
    reg_10,
    reg_11,
    reg_12,
    reg_13,
    reg_14,
    reg_15,
    reg_16,
    reg_17,
    reg_18,
    reg_19,
    reg_1a,
    reg_1b,
    reg_1c,
    reg_1d,
    reg_1e,
    reg_1f,
//    RegisterData,   // Internal registers file
    DataRd          // Output Multiplexed Data
);
///////////////////////////////////////////////////////////////////
input           PciReset;
input           LpcClock;
input   [7:0]   AddrReg;
//input   [7:0]   RegisterData[1:8];
input   [7:0]   reg_00;
input   [7:0]   reg_01;
input   [7:0]   reg_02;
input   [7:0]   reg_03;
input   [7:0]   reg_04;
input   [7:0]   reg_05;
input   [7:0]   reg_06;
input   [7:0]   reg_07;
input   [7:0]   reg_08;
input   [7:0]   reg_09;
input   [7:0]   reg_0a;
input   [7:0]   reg_0b;
input   [7:0]   reg_0c;
input   [7:0]   reg_0d;
input   [7:0]   reg_0e;
input   [7:0]   reg_0f;
input   [7:0]   reg_10;
input   [7:0]   reg_11;
input   [7:0]   reg_12;
input   [7:0]   reg_13;
input   [7:0]   reg_14;
input   [7:0]   reg_15;
input   [7:0]   reg_16;
input   [7:0]   reg_17;
input   [7:0]   reg_18;
input   [7:0]   reg_19;
input   [7:0]   reg_1a;
input   [7:0]   reg_1b;
input   [7:0]   reg_1c;
input   [7:0]   reg_1d;
input   [7:0]   reg_1e;
input   [7:0]   reg_1f;
output  [7:0]   DataRd;
///////////////////////////////////////////////////////////////////
reg     [7:0]   Mux;
reg     [7:0]   DataRd;
///////////////////////////////////////////////////////////////////
always @ (AddrReg or
          reg_00 or reg_01 or reg_02 or reg_03 or reg_04 or reg_05 or reg_06 or
          reg_07 or reg_08 or reg_09 or reg_0a or reg_0b or reg_0c or reg_0d or
          reg_0e or reg_0f or reg_10 or reg_11 or reg_12 or reg_13 or reg_14 or
          reg_15 or reg_16 or reg_17 or reg_18 or reg_19 or reg_1a or reg_1b or
          reg_1c or reg_1d or reg_1e or reg_1f) begin
    case(AddrReg)
        8'h00: Mux <= reg_00;
        8'h01: Mux <= reg_01;
        8'h02: Mux <= reg_02;
        8'h03: Mux <= reg_03;
        8'h04: Mux <= reg_04;
        8'h05: Mux <= reg_05;
        8'h06: Mux <= reg_06;
        8'h07: Mux <= reg_07;
        8'h08: Mux <= reg_08;
        8'h09: Mux <= reg_09;
        8'h0A: Mux <= reg_0a;
        8'h0B: Mux <= reg_0b;
        8'h0C: Mux <= reg_0c;
        8'h0D: Mux <= reg_0d;
        8'h0E: Mux <= reg_0e;
        8'h0F: Mux <= reg_0f;
        8'h10: Mux <= reg_10;
        8'h11: Mux <= reg_11;
        8'h12: Mux <= reg_12;
        8'h13: Mux <= reg_13;
        8'h14: Mux <= reg_14;
        8'h15: Mux <= reg_15;
        8'h16: Mux <= reg_16;
        8'h17: Mux <= reg_17;
        8'h18: Mux <= reg_18;
        8'h19: Mux <= reg_19;
        8'h1A: Mux <= reg_1a;
        8'h1B: Mux <= reg_1b;
        8'h1C: Mux <= reg_1c;
        8'h1D: Mux <= reg_1d;
        8'h1E: Mux <= reg_1e;
        8'h1F: Mux <= reg_1f;
        default: Mux <= 8'h00;
    endcase
end

always @ (posedge LpcClock or negedge PciReset) begin
    if (!PciReset)
        DataRd <= 8'h00;
    else
        DataRd <= Mux;
end

endmodule
