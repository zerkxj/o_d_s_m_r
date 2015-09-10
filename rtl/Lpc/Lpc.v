///////////////////////////////////////////////////////////////////
// File name        : Lpc.v
// Module name      : Lpc
// Description      : This module is LPC top module
// Hierarchy Up     : ODS_MR
// Hierarchy Down   : LpcDecoder, LpcControl, LpcRegs, LpcMux,
///////////////////////////////////////////////////////////////////
`include "../Verilog/Includes/DefineODSTextMacro.v"
///////////////////////////////////////////////////////////////////
module Lpc (
    PciReset,   // PCI Reset
    LpcClock,   // 33 MHz Lpc (LPC Clock)
    LpcFrame,   // LPC Interface: Frame
    LpcBus,     // LPC Interface: Data Bus
    DataRd,     // register read data
    AddrReg,    // register address
    Wr,         // register write
    Rd,         // register read
    Pwr_ok,// Carlos
    Active_Bios, // Carlos
    DataWr      // register write data
);
///////////////////////////////////////////////////////////////////
input           PciReset;
input           LpcClock;
input           LpcFrame;
inout   [3:0]   LpcBus;
input   [7:0]   DataRd;
output  [7:0]   AddrReg;
output          Wr;
output          Rd;
input           Pwr_ok;// Carlos
output          Active_Bios; // Carlos
output  [7:0]   DataWr;
///////////////////////////////////////////////////////////////////
wire            Opcode;
wire            wr;
wire            rd;
wire    [7:0]   AddrReg;
wire    [7:0]   DataWr;
wire    [10:6]  StateOut;
wire    [7:0]   DataRd;
wire    [7:0]   reg_00;
wire    [7:0]   reg_01;
wire    [7:0]   reg_02;
wire    [7:0]   reg_03;
wire    [7:0]   reg_04;
wire    [7:0]   reg_05;
wire    [7:0]   reg_06;
wire    [7:0]   reg_07;
wire    [7:0]   reg_08;
wire    [7:0]   reg_09;
wire    [7:0]   reg_0a;
wire    [7:0]   reg_0b;
wire    [7:0]   reg_0c;
wire    [7:0]   reg_0d;
wire    [7:0]   reg_0e;
wire    [7:0]   reg_0f;
wire    [7:0]   reg_10;
wire    [7:0]   reg_11;
wire    [7:0]   reg_12;
wire    [7:0]   reg_13;
wire    [7:0]   reg_14;
wire    [7:0]   reg_15;
wire    [7:0]   reg_16;
wire    [7:0]   reg_17;
wire    [7:0]   reg_18;
wire    [7:0]   reg_19;
wire    [7:0]   reg_1a;
wire    [7:0]   reg_1b;
wire    [7:0]   reg_1c;
wire    [7:0]   reg_1d;
wire    [7:0]   reg_1e;
wire    [7:0]   reg_1f;


///////////////////////////////////////////////////////////////////
LpcDecoder
    u_LpcDecoder (.PciReset(PciReset),  // PCI Reset
                  .LpcClock(LpcClock),  // 33 MHz Lpc (LPC Clock)
                  .LpcFrame(LpcFrame),  // LPC Interface: Frame
                  .LpcBus(LpcBus),      // LPC Interface: Data Bus
                  .Opcode(Opcode),      // LPC operation (0 - Read, 1 - Write)
                  .Wr(Wr),              // Write Access to CPLD registers
                  .Rd(Rd),              // Read  Access to CPLD registers
                  .AddrReg(AddrReg),    // Address of the accessed Register
                  .DataWr(DataWr),      // Data to be written to register
                  .StateOut(StateOut)); // Decoding Status

LpcControl
    u_LpcControl (.LpcClock(LpcClock),  // 33 MHz Lpc (LPC Clock)
                  .Opcode(Opcode),      // LPC operation (0 - Read, 1 - Write)
                  .State(StateOut),     // Decoding Status
                  .DataRd(DataRd),            // Output Multiplexed Data
                  .LpcBus(LpcBus));     // LPC Address Data

LpcReg
    u_LpcReg (.PciReset(PciReset),       // reset
              .LpcClock(LpcClock),       // 33 MHz Lpc (LPC Clock)
              .Addr(AddrReg),           // register address
              .Wr(Wr),             // write operation
              .DataWr(DataWr),         // write data
              .Pwr_ok(Pwr_ok),         // Power is ok
              .reg_00(reg_00),
              .reg_01(reg_01),
              .reg_02(reg_02),
              .reg_03(reg_03),
              .reg_04(reg_04),
              .reg_05(reg_05),
              .reg_06(reg_06),
              .reg_07(reg_07),
              .reg_08(reg_08),
              .reg_09(reg_09),
              .reg_0a(reg_0a),
              .reg_0b(reg_0b),
              .reg_0c(reg_0c),
              .reg_0d(reg_0d),
              .reg_0e(reg_0e),
              .reg_0f(reg_0f),
              .reg_10(reg_10),
              .reg_11(reg_11),
              .reg_12(reg_12),
              .reg_13(reg_13),
              .reg_14(reg_14),
              .reg_15(reg_15),
              .reg_16(reg_16),
              .reg_17(reg_17),
              .reg_18(reg_18),
              .reg_19(reg_19),
              .reg_1a(reg_1a),
              .reg_1b(reg_1b),
              .reg_1c(reg_1c),
              .reg_1d(reg_1d),
              .reg_1e(reg_1e),
              .reg_1f(reg_1f),
              .Active_Bios(Active_Bios));     // Provide access to required BIOS chip

LpcMux
    u_LpcMux (.PciReset(PciReset),       // PCI Reset
              .LpcClock(LpcClock),       // 33 MHz Lpc (LPC Clock)
              .AddrReg(AddrReg),        // Address of the accessed Register
              .reg_00(reg_00),
              .reg_01(reg_01),
              .reg_02(reg_02),
              .reg_03(reg_03),
              .reg_04(reg_04),
              .reg_05(reg_05),
              .reg_06(reg_06),
              .reg_07(reg_07),
              .reg_08(reg_08),
              .reg_09(reg_09),
              .reg_0a(reg_0a),
              .reg_0b(reg_0b),
              .reg_0c(reg_0c),
              .reg_0d(reg_0d),
              .reg_0e(reg_0e),
              .reg_0f(reg_0f),
              .reg_10(reg_10),
              .reg_11(reg_11),
              .reg_12(reg_12),
              .reg_13(reg_13),
              .reg_14(reg_14),
              .reg_15(reg_15),
              .reg_16(reg_16),
              .reg_17(reg_17),
              .reg_18(reg_18),
              .reg_19(reg_19),
              .reg_1a(reg_1a),
              .reg_1b(reg_1b),
              .reg_1c(reg_1c),
              .reg_1d(reg_1d),
              .reg_1e(reg_1e),
              .reg_1f(reg_1f),
//              .RegisterData(),   // Internal registers file
              .DataRd(DataRd));          // Output Multiplexed Data
endmodule
