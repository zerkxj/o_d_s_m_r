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
wire    [7:0]   DataReg [31:0];

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
    u_LpcControl (.PciReset(PciReset),  //PCI Reset
                  .LpcClock(LpcClock),  // 33 MHz Lpc (LPC Clock)
                  .Opcode(Opcode),      // LPC operation (0 - Read, 1 - Write)
                  .State(StateOut),     // Decoding Status
                  .AddrReg(AddrReg),    // Address of the accessed Register
                  .DataRd(DataRd),      // Output Multiplexed Data
                  .LpcBus(LpcBus));     // LPC Address Data

LpcReg
    u_LpcReg (.PciReset(PciReset),          // reset
              .LpcClock(LpcClock),          // 33 MHz Lpc (LPC Clock)
              .Addr(AddrReg),               // register address
              .Wr(Wr),                      // write operation
              .DataWr(DataWr),              // write data
              .Pwr_ok(Pwr_ok),              // Power is ok
              .DataReg(DataReg),            // Register data
              .Active_Bios(Active_Bios));   // Provide access to required BIOS chip

LpcMux
    u_LpcMux (.PciReset(PciReset),  // PCI Reset
              .LpcClock(LpcClock),  // 33 MHz Lpc (LPC Clock)
              .AddrReg(AddrReg),    // Address of the accessed Register
              .DataReg(DataReg),    // Register data
              .DataRd(DataRd));     // Output Multiplexed Data
endmodule
