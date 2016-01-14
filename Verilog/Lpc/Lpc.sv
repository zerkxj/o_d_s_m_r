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
    PciReset,           // In, PCI Reset
    LpcClock,           // In, 33 MHz Lpc (LPC Clock)
    LpcFrame,           // In, LPC Interface: Frame
    LpcBus,             // In, LPC Interface: Data Bus
    BiosStatus,         // In, BIOS status
    IntReg,             // In, Interrupt register
    FAN_PRSNT_N,        // In, FAN present status
    BIOS_SEL,           // In, force select BIOS
    DME_PRSNT,          // In, DME present
    JP4,                // In, jumper 4, for future use
    PSU_status,         // In, power supply status
    Dual_Supply,        // In, Dual Supply status, save in SPI FLASH
    WatchDogOccurred,   // In, occurr watch dog reset
    WatchDogIREQ,       // In, watch dog interrupt request

    BiosWDRegSW,    // Out, BIOS watch dog register from SW configuration
    SystemOK,       // Out, System OK flag(software control)
    x7SegSel,       // Out, 7 Segment LED select
    x7SegVal,       // Out, 7 Segment LED value
    WriteBiosWD,    // Out, BIOS watch dog register write
    WrBiosStsReg,   // Out, Write BIOS status register
    BiosWDReg,      // Out, BIOS watch dog register
    LBCF,           // Out, Lock BIOS Chip Flag
    NextBiosSW,     // Out, Next BIOS SW configuration
    ActiveBiosSW,   // Out, Active BIOS SW confguration
    WrIntReg,       // Out, Write interrupt status and control register
    ClrIntSW,       // Out, Clear interrupr from SW
    IntRegister,    // Out, Interrupt register
    WatchDogReg,    // Out, Watch Dog register
    BiosPostData,   // Out, 80 port data
    FanLedCtrl,     // Out, Fan LED control register
    PSUFan_St,      // Out, PSU Fan state register
    SpecialCmdReg,  // Out, SW controled power shutdown register
    Shutdown,       // Out, SW shutdown command
    SwapBios,       // Out, Swap BIOS by SW shutdown command
    LoadWDTimer     // Out, Load watch dog timer
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
input   [6:4]   IntReg;
input   [2:0]   FAN_PRSNT_N;
input           BIOS_SEL;
input           DME_PRSNT;
input           JP4;
input   [5:4]   PSU_status;
input           Dual_Supply;
input           WatchDogOccurred;
input           WatchDogIREQ;

//--------------------------------------------------------------------------
// Output declaration
//--------------------------------------------------------------------------
output  [7:0]   BiosWDRegSW;
output          SystemOK;
output  [4:0]   x7SegSel;
output  [7:0]   x7SegVal;
output          WriteBiosWD;
output          WrBiosStsReg;
output  [7:0]   BiosWDReg;
output          LBCF;
output          NextBiosSW;
output          ActiveBiosSW;
output          WrIntReg;
output  [2:0]   ClrIntSW;
output  [7:0]   IntRegister;
output  [7:0]   WatchDogReg;
output  [7:0]   BiosPostData;
output  [3:0]   FanLedCtrl;
output  [7:0]   PSUFan_St;
output  [7:0]   SpecialCmdReg;
output          Shutdown;
output          SwapBios;
output          LoadWDTimer;

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
wire            Wr;
wire            Rd;
wire    [7:0]   AddrReg;
wire    [7:0]   DataWr;
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
reg             Shutdown;
reg             SwapBios;

//------------------------------------------------------------------
// Internal signal
//------------------------------------------------------------------
reg             Shutdown_d; // Shutdown delay 1T

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
assign WrBiosStsReg = Wr & (AddrReg == 8'h04);
assign NextBiosSW = DataWr[1];
assign ActiveBiosSW = DataWr[0];
assign WrIntReg = Wr & (AddrReg == 8'h09);
assign ClrIntSW = DataWr[6:4] & {3{WrIntReg}};
assign LoadWDTimer = Wr & (AddrReg == 8'h0B);

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
always @ (posedge LpcClock or negedge PciReset) begin
    if (!PciReset)
        Shutdown <= #TD 1'b0;
    else
        Shutdown <= #TD (SpecialCmdReg == 8'h53);
end
always @ (posedge LpcClock or negedge PciReset) begin
    if (!PciReset)
        SwapBios <= #TD 1'b0;
    else
        SwapBios <= #TD ({Shutdown_d, Shutdown} == 2'b01);
end

//----------------------------------------------------------------------
// Internal signal
//----------------------------------------------------------------------
always @ (posedge LpcClock or negedge PciReset) begin
    if (!PciReset)
        Shutdown_d <= #TD 1'b0;
    else
        Shutdown_d <= #TD Shutdown;
end

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
    u_LpcReg (.PciReset(PciReset),                  // In, reset
              .LpcClock(LpcClock),                  // In, 33 MHz Lpc (LPC Clock)
              .Addr(AddrReg),                       // In, register address
              .Wr(Wr),                              // In, write operation
              .Rd(Rd),                              // In, read operation
              .DataWrSW(DataWr),                    // In, write data
              .BiosStatus(BiosStatus),              // In, BIOS status setup value
              .IntReg(IntReg),                      // In, Interrupt register setup value
              .FAN_PRSNT_N(FAN_PRSNT_N),            // In, FAN present status
              .BIOS_SEL(BIOS_SEL),                  // In, force select BIOS
              .DME_PRSNT(DME_PRSNT),                // In, DME present
              .JP4(JP4),                            // In, jumper 4, for future use
              .PSU_status(PSU_status),              // In, power supply status
              .Dual_Supply(Dual_Supply),            // In, Dual Supply status, save in SPI FLASH
              .WatchDogOccurred(WatchDogOccurred),  // In, occurr watch dog reset
              .WatchDogIREQ(WatchDogIREQ),          // In, watch dog interrupt request

              .BiosWDReg(BiosWDReg),            // Out, BIOS watch dog register
              .LBCF(LBCF),                      // Out, Lock BIOS Chip Flag
              .SystemOK(SystemOK),              // Out, System OK flag(software control)
              .IntRegister(IntRegister),        // Out, Interrupt register
              .PSUFan_St(PSUFan_St),            // Out, PSU Fan state register
              .WatchDogReg(WatchDogReg),        // Out, Watch Dog register
              .x7SegSel(x7SegSel),              // Out, 7 segment LED select
              .x7SegVal(x7SegVal),              // Out, 7 segment LED value
              .SpecialCmdReg(SpecialCmdReg),    // Out, SW controled power shutdown register
              .FanLedCtrl(FanLedCtrl),          // Out, Fan LED control register
              .DataReg(DataReg));               // Out, Register data

LpcMux
    u_LpcMux (.PciReset(PciReset),      // In, PCI Reset
              .LpcClock(LpcClock),      // In, 33 MHz Lpc (LPC Clock)
              .AddrReg(AddrReg),        // In, Address of the accessed Register
              .DataReg(DataReg),        // In, Register data
              .BiosStatus(BiosStatus),  // In, BIOS status

              .DataRd(DataRd));         // Out, Multiplexed Data

endmodule
