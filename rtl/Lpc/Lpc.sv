//******************************************************************************
// File name        : Lpc.v
// Module name      : Lpc
// Description      : This module is LPC top module
// Hierarchy Up     : ODS_MR
// Hierarchy Down   : LpcDecoder, LpcControl, LpcRegs, LpcMux,
//******************************************************************************

//------------------------------------------------------------------------------
// Macro define or include file
//------------------------------------------------------------------------------
`include "../Verilog/Includes/DefineODSTextMacro.v"

//------------------------------------------------------------------------------
// Module declaration
//------------------------------------------------------------------------------
module Lpc (
    PciReset,       // In, PCI Reset
    LpcClock,       // In, 33 MHz Lpc (LPC Clock)
    LpcFrame,       // In, LPC Interface: Frame
    LpcBus,         // In, LPC Interface: Data Bus
    BiosStatus,     // In, BIOS status

    Wr,             // Out, LPC register wtite
    AddrReg,        // Out, register address
    DataWr,         // Out, register write data
    SystemOK,       // Out, System OK flag(software control)
    x7SegSel,       // Out, 7 Segment LED select
    x7SegVal,       // Out, 7 Segment LED value
    WriteBiosWD,    // Out, BIOS watch dog register write
    BiosRegister,   // Out, BIOS watch dog register
    BiosPostData,   // Out, 80 port data
    FanLedCtrl,     // Out, Fan LED control register
    PSUFan_St       // Out, PSU Fan state register
);

//------------------------------------------------------------------------------
// Parameter declaration
//------------------------------------------------------------------------------
//--------------------------------------------------------------------------
// User defined parameter
//--------------------------------------------------------------------------
// None

//--------------------------------------------------------------------------
// Standard parameter
//--------------------------------------------------------------------------
// None

//--------------------------------------------------------------------------
// Local parameter
//--------------------------------------------------------------------------
// time delay, flip-flop output assignment delay for simulation waveform trace
localparam TD = 1;

//------------------------------------------------------------------------------
// Variable declaration
//------------------------------------------------------------------------------
// None

//------------------------------------------------------------------------------
// Input/Output declaration
//------------------------------------------------------------------------------
//--------------------------------------------------------------------------
// Input declaration
//--------------------------------------------------------------------------
input           PciReset;
input           LpcClock;
input           LpcFrame;
inout   [3:0]   LpcBus;
input   [2:0]   BiosStatus;

//--------------------------------------------------------------------------
// Output declaration
//--------------------------------------------------------------------------
output          Wr;
output  [7:0]   AddrReg;
output  [7:0]   DataWr;
output          SystemOK;
output  [4:0]   x7SegSel;
output  [7:0]   x7SegVal;
output          WriteBiosWD;
output  [7:0]   BiosRegister;
output  [7:0]   BiosPostData;
output  [3:0]   FanLedCtrl;
output  [7:0]   PSUFan_St;

//------------------------------------------------------------------------------
// Signal declaration
//------------------------------------------------------------------------------
//--------------------------------------------------------------------------
// Wire declaration
//--------------------------------------------------------------------------
//----------------------------------------------------------------------
// Combinational, module connection
//----------------------------------------------------------------------
wire            Opcode;
wire            Rd;
wire    [10:6]  StateOut;
wire    [7:0]   DataRd;
wire    [7:0]   DataReg [31:0];

//--------------------------------------------------------------------------
// Reg declaration
//--------------------------------------------------------------------------
//----------------------------------------------------------------------
// Combinational
//----------------------------------------------------------------------
//------------------------------------------------------------------
// Output
//------------------------------------------------------------------
// None

//------------------------------------------------------------------
// Internal signal
//------------------------------------------------------------------
// None

//------------------------------------------------------------------
// FSM
//------------------------------------------------------------------
// None

//----------------------------------------------------------------------
// Sequential
//----------------------------------------------------------------------
//------------------------------------------------------------------
// Output
//------------------------------------------------------------------
// None

//------------------------------------------------------------------
// Internal signal
//------------------------------------------------------------------
// None

//------------------------------------------------------------------
// FSM
//------------------------------------------------------------------
// None

//------------------------------------------------------------------------------
// Task/Function description and included task/function description
//------------------------------------------------------------------------------
// None

//------------------------------------------------------------------------------
// Main code
//------------------------------------------------------------------------------
//--------------------------------------------------------------------------
// Combinational circuit
//--------------------------------------------------------------------------
//----------------------------------------------------------------------
// Output
//----------------------------------------------------------------------
assign WriteBiosWD = Wr & (AddrReg == 8'h01);

//----------------------------------------------------------------------
// Internal signal
//----------------------------------------------------------------------
// None

//----------------------------------------------------------------------
// FSM
//----------------------------------------------------------------------
// None

//--------------------------------------------------------------------------
// Sequential circuit
//--------------------------------------------------------------------------
//----------------------------------------------------------------------
// Output
//----------------------------------------------------------------------
// None

//----------------------------------------------------------------------
// Internal signal
//----------------------------------------------------------------------
// None

//----------------------------------------------------------------------
// FSM
//----------------------------------------------------------------------
// None

//--------------------------------------------------------------------------
// Module instantiation
//--------------------------------------------------------------------------
LpcDecoder
    u_LpcDecoder (.PciReset(PciReset),      // In, PCI Reset
                  .LpcClock(LpcClock),      // In, 33 MHz Lpc (LPC Clock)
                  .LpcFrame(LpcFrame),      // In, LPC Interface: Frame
                  .LpcBus(LpcBus),          // In/Out, LPC Interface: Data Bus
                  .Opcode(Opcode),          // Out, LPC operation (0 - Read, 1 - Write)
                  .Wr(Wr),                  // Out, Write Access to CPLD registers
                  .Rd(Rd),                  // Out, Read  Access to CPLD registers
                  .AddrReg(AddrReg),        // Out, Address of the accessed Register
                  .DataWr(DataWr),          // Out, Data to be written to register
                  .StateOut(StateOut),      // Out, Decoding Status
                  .Data80(BiosPostData));   // Out, port 80 data

LpcControl
    u_LpcControl (.PciReset(PciReset),  // In, PCI Reset
                  .LpcClock(LpcClock),  // In, 33 MHz Lpc (LPC Clock)
                  .Opcode(Opcode),      // In, LPC operation (0 - Read, 1 - Write)
                  .State(StateOut),     // In, Decoding Status
                  .AddrReg(AddrReg),    // In, Address of the accessed Register
                  .DataRd(DataRd),      // In, Multiplexed Data
                  .LpcBus(LpcBus));     // Out, LPC Address Data

LpcReg
    u_LpcReg (.PciReset(PciReset),          // In, reset
              .LpcClock(LpcClock),          // In, 33 MHz Lpc (LPC Clock)
              .Addr(AddrReg),               // In, register address
              .Wr(Wr),                      // In, write operation
              .DataWr(DataWr),              // In, write data
              .BiosStatus(BiosStatus),      // In, BIOS status setup value
              .DataReg(DataReg),            // Out, Register data
              .SystemOK(SystemOK),          // Out, System OK flag(software control)
              .x7SegSel(x7SegSel),          // Out, 7 segment LED select
              .x7SegVal(x7SegVal),          // Out, 7 segment LED value
              .BiosRegister(BiosRegister),  // Out, BIOS watch dog register
              .FanLedCtrl(FanLedCtrl),      // Out, Fan LED control register
              .PSUFan_St(PSUFan_St));       // Out, PSU Fan state register

LpcMux
    u_LpcMux (.PciReset(PciReset),      // In, PCI Reset
              .LpcClock(LpcClock),      // In, 33 MHz Lpc (LPC Clock)
              .AddrReg(AddrReg),        // In, Address of the accessed Register
              .DataReg(DataReg),        // In, Register data
              .BiosStatus(BiosStatus),  // In, BIOS status
              .DataRd(DataRd));         // Out, Multiplexed Data

endmodule
