//******************************************************************************
// File name        : LpcControl.v
// Module name      : LpcControl
// Description      : This module controls output data to LPC bus
// Hierarchy Up     : Lpc
// Hierarchy Down   : ---
//******************************************************************************

//------------------------------------------------------------------------------
// Macro define or include file
//------------------------------------------------------------------------------
// None


//------------------------------------------------------------------------------
// Module declaration
//------------------------------------------------------------------------------
module LpcControl (
    PciReset,   // In, PCI Reset
    LpcClock,   // In, 33 MHz Lpc (LPC Clock)
    Opcode,     // In, LPC operation (0 - Read, 1 - Write)
    AddrReg,    // In, Address of the accessed Register
    State,      // In, Decoding Status
    DataRd,     // In, Multiplexed Data
    LpcBus      // Out, LPC Address Data
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
input           Opcode;
input   [7:0]   AddrReg;
input   [10:6]  State;
input   [7:0]   DataRd;

//--------------------------------------------------------------------------
// Output declaration
//--------------------------------------------------------------------------
output  [3:0]   LpcBus;

//------------------------------------------------------------------------------
// Signal declaration
//------------------------------------------------------------------------------
//--------------------------------------------------------------------------
// Wire declaration
//--------------------------------------------------------------------------
//----------------------------------------------------------------------
// Combinational, module connection
//----------------------------------------------------------------------
wire            TAR;
wire            DataLow;
wire            DataHigh;
wire    [1:0]   OutputCode;

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
reg             OE;
reg     [3:0]   RegData;

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
assign LpcBus = OE ? RegData : 4'hz;

//----------------------------------------------------------------------
// Internal signal
//----------------------------------------------------------------------
assign TAR = State[10];
assign DataLow = (~Opcode) & State[8];
assign DataHigh = (~Opcode) & State[9];
assign OutputCode[0] = DataLow | TAR;
assign OutputCode[1] = DataHigh | TAR;

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
always @ (posedge LpcClock or negedge PciReset) begin
    if (!PciReset)
        OE <= 1'b0;
    else
        OE <= Opcode ? (|State[9:8]) : ((|State[9:6]) & (~(|AddrReg[7:5])));
end

always @ (OutputCode or Opcode or DataRd) begin
    case (OutputCode)
        2'b00: RegData = 4'h0;
        2'b01: RegData = Opcode ? 4'h0 : DataRd[3:0];
        2'b10: RegData = Opcode ? 4'hF : DataRd[7:4];
        2'b11: RegData = 4'hF;
    endcase
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
