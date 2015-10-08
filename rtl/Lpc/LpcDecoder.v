//******************************************************************************
// File name        : LpcDecoder.v
// Module name      : LpcDecoder
// Description      : This module is LPC Address Decoder
// Hierarchy Up     : Lpc
// Hierarchy Down   : ---
//******************************************************************************

//------------------------------------------------------------------------------
// Macro define or include file
//------------------------------------------------------------------------------
`include "../Verilog/Includes/DefineODSTextMacro.v"

//------------------------------------------------------------------------------
// Module declaration
//------------------------------------------------------------------------------
module LpcDecoder (
    PciReset,   // In, PCI Reset
    LpcClock,   // In, 33 MHz Lpc (LPC Clock)
    LpcFrame,   // In, LPC Interface: Frame
    LpcBus,     // In/Out, LPC Interface: DataWr Bus
    Opcode,     // Out, LPC operation (0 - Read, 1 - Write)
    Wr,         // Out, Write Access to CPLD registers
    Rd,         // Out, Read  Access to CPLD registers
    AddrReg,    // Out, Address of the accessed Register
    DataWr,     // Out, DataWr to be written to register
    StateOut,   // Out, Decoding Status
    Data80      // Out, port 80 data
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
input   [3:0]   LpcBus;

//--------------------------------------------------------------------------
// Output declaration
//--------------------------------------------------------------------------
output          Opcode;
output          Wr;
output          Rd;
output  [7:0]   AddrReg;
output  [7:0]   DataWr;
output  [10:6]  StateOut;
output  [7:0]   Data80;

//------------------------------------------------------------------------------
// Signal declaration
//------------------------------------------------------------------------------
//--------------------------------------------------------------------------
// Wire declaration
//--------------------------------------------------------------------------
//----------------------------------------------------------------------
// Combinational, module connection
//----------------------------------------------------------------------
wire    [15:0]  LpcBar; // 32 Ports BAR
wire    [15:0]  Bar80; // Single Ports BAR
wire            P80En;
wire            StartFlag;
wire            OpcodeValid;
wire    [3:1]   Fetch;
wire    [4:1]   Fetch80;

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
reg             Opcode;
reg             Wr;
reg     [7:0]   AddrReg;
reg     [7:0]   DataWr;
reg     [7:0]   Data80;

//------------------------------------------------------------------
// Internal signal
//------------------------------------------------------------------
reg     [10:0]  State;
reg             LpcAccess;
reg     [5:2]   StateP;
reg             SelP80;

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
assign Rd = (Opcode == 1'b0);
assign StateOut = State[10:6];

//----------------------------------------------------------------------
// Internal signal
//----------------------------------------------------------------------
assign LpcBar = `BAR;
assign Bar80 = `BAR80;
assign P80En = `Port80;
assign StartFlag = (LpcBus == 4'h0) & (~LpcFrame);
assign OpcodeValid = (LpcBus[3:2] == 2'b00); // IO Read/Wr (0/2)
assign Fetch[1] = (LpcBus == LpcBar[15:12]) & LpcFrame;
assign Fetch[2] = (LpcBus == LpcBar[11:8]) & LpcFrame;
assign Fetch[3] = (LpcBus[3:1] == LpcBar[7:5]) & LpcFrame;
assign Fetch80[1] = (LpcBus == Bar80[15:12]) & LpcFrame & P80En;
assign Fetch80[2] = (LpcBus == Bar80[11:8]) & LpcFrame & P80En;
assign Fetch80[3] = (LpcBus == Bar80[7:4]) & LpcFrame & P80En;
assign Fetch80[4] = (LpcBus == Bar80[3:0]) & LpcFrame & P80En;

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
    if(!PciReset) begin
        Opcode <= #TD 1'b0;
        Wr <= #TD 1'b0;
        AddrReg <= #TD 8'd0;
        DataWr <= #TD 8'd0;
        Data80 <= #TD 8'd0;
    end else begin
        Opcode <= #TD State[0] ? LpcBus[1] : Opcode;
        Wr <= #TD LpcAccess &  Opcode & State[6];
        AddrReg[7:4] <= #TD State[3] ? LpcBus : AddrReg[7:4];
        AddrReg[3:0] <= #TD State[4] ? LpcBus : AddrReg[3:0];
        DataWr[7:4] <= #TD State[6] ? LpcBus : DataWr[7:4];
        DataWr[3:0] <= #TD (State[5] | StateP[5]) ? LpcBus : DataWr[3:0];
        Data80 <= #TD (SelP80 & State[8]) ? DataWr : Data80;
     end
end

//----------------------------------------------------------------------
// Internal signal
//----------------------------------------------------------------------
always @ (posedge LpcClock or negedge PciReset) begin
    if(!PciReset) begin
        State <= #TD 11'd0;
        LpcAccess <= #TD 1'b0;
        StateP <= #TD 4'd0;
        SelP80 <= #TD 1'b0;
    end else begin
        State[0] <= #TD StartFlag;
        State[1] <= #TD State[0] & OpcodeValid;
        State[2] <= #TD State[1] & Fetch[1];
        State[3] <= #TD State[2] & Fetch[2];
        State[4] <= #TD State[3] & Fetch[3];
        State[5] <= #TD State[4];
        State[6] <= #TD State[5] | StateP[5];
        State[10:7] <= #TD State[9:6];
        LpcAccess <= #TD State[4] | LpcAccess & (!State[10]);
        StateP[2] <= #TD State[1] & Fetch80[1];
        StateP[3] <= #TD StateP[2] & Fetch80[2];
        StateP[4] <= #TD StateP[3] & Fetch80[3];
        StateP[5] <= #TD StateP[4] & Fetch80[4];
        SelP80 <= #TD (StateP[5] & Opcode) | SelP80 & !State[10];
     end
end


//----------------------------------------------------------------------
// FSM
//----------------------------------------------------------------------
// None

//--------------------------------------------------------------------------
// Module instantiation
//--------------------------------------------------------------------------
// None

endmodule
