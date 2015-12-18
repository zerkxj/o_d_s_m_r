//******************************************************************************
// File name      : BiosWatchDog.v
// Module name    : BiosWatchDog
// Company        : Radware
// Project name   : ODS-LS
// Card name      : Yarkon
// Designer       : Fedor Haikin
// Creation Date  : 08.02.2011
// Status         : Under design
// Last modified  : 08.02.2011
// Version        : 1.0
// Description    : This module controls BIOS Watch Dog
// Hierarchy Up      : Lpc
// Hierarchy Down : ---
// Card Release      : 1.0
//******************************************************************************

//------------------------------------------------------------------------------
// Macro define or include file
//------------------------------------------------------------------------------
`include "../Verilog/Includes/DefineODSTextMacro.v"


//------------------------------------------------------------------------------
// Module declaration
//------------------------------------------------------------------------------
module BiosWatchDog (
    Reset,          // In, Generated PowerUp Reset
    SlowClock,      // In, Oscillator Clock 32,768 Hz
    LpcClock,       // In, 33 MHz Lpc (Altera Clock)
    MainReset,      // In, Power or Controller ICH10R Reset
    PS_ONn,         // In,
    DPx,            // Out,
    Strobe125msec,  // In, Single LpcClock  Pulse @ 125 ms
    BiosRegister,   // In, Bios Watch Dog Control Register
    BiosFinished,   // Out, Bios Has been finished
    BiosPowerOff,   // Out, BiosWD Occurred, Force Power Off
    ForceSwap       // Out, BiosWD Occurred, Force BIOS Swap while power restart
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
input           Reset;
input           SlowClock;
input           LpcClock;
input           MainReset;
input           Strobe125msec;
input           PS_ONn;
input   [7:0]   BiosRegister;

//--------------------------------------------------------------------------
// Output declaration
//--------------------------------------------------------------------------
output  [1:0]   DPx;
output          BiosFinished;
output          BiosPowerOff;
output          ForceSwap;

//------------------------------------------------------------------------------
// Signal declaration
//------------------------------------------------------------------------------
//--------------------------------------------------------------------------
// Wire declaration
//--------------------------------------------------------------------------
//----------------------------------------------------------------------
// Combinational, module connection
//----------------------------------------------------------------------
// None

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
reg             BiosFinished;
reg             BiosPowerOff;
reg             ForceSwap;

//------------------------------------------------------------------
// Internal signal
//------------------------------------------------------------------
reg     [9:0]   BiosTimer;
reg     [5:0]   BiosTimer4sec;
reg             BiosWatchDogReset;
reg             Edge;
reg             DisableBiosWD;
reg             DisableTimer;
reg             Freeze;

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
// None

//----------------------------------------------------------------------
// Internal signal
//----------------------------------------------------------------------

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
always @ (posedge LpcClock or negedge MainReset) begin
    if (!MainReset)
        if (!PS_ONn) begin
            BiosFinished <= #TD 1'b0;
            ForceSwap <= #TD 1'b0;
        end else begin
            BiosFinished <= #TD BiosFinished;
            ForceSwap <= #TD ForceSwap;
        end
    else begin
        ForceSwap <= #TD BiosWatchDogReset & !Edge;
        BiosFinished <= #TD (BiosRegister == 8'hFF) | BiosFinished;
    end
end

always @ (posedge SlowClock or negedge Reset) begin
    if (!Reset)
        BiosPowerOff <= #TD 1'b0;
    else
        BiosPowerOff <= #TD BiosWatchDogReset;
end

//----------------------------------------------------------------------
// Internal signal
//----------------------------------------------------------------------
always @ (posedge LpcClock or negedge MainReset) begin
    if (!MainReset)
        if (!PS_ONn) begin
            BiosTimer <= #TD 10'd0;
            BiosTimer4sec <= #TD 6'd0;
            BiosWatchDogReset <= #TD 1'b0;
            Edge <= #TD 1'b0;
            DisableBiosWD <= #TD 1'b0;
            DisableTimer <= #TD 1'b0;
            Freeze <= #TD 1'b0;
        end else begin
            BiosTimer <= #TD BiosTimer;
            BiosTimer4sec <= #TD BiosTimer4sec;
            BiosWatchDogReset <= #TD BiosWatchDogReset;
            Edge <= #TD Edge;
            DisableBiosWD <= #TD DisableBiosWD;
            DisableTimer <= #TD DisableTimer;
            Freeze <= #TD Freeze;
        end
    else begin
        BiosTimer <= #TD DisableTimer ? BiosTimer :
                                        Strobe125msec ? (BiosTimer + 10'd1) : BiosTimer;
        BiosTimer4sec <= #TD Freeze ? BiosTimer4sec :
                                      ((BiosRegister == 8'hAA)| DisableBiosWD) ? 6'h0 :
                                                                                 Strobe125msec ? (BiosTimer4sec + 6'd1) : BiosTimer4sec;
        BiosWatchDogReset <= #TD BiosTimer[9] | BiosTimer4sec[5];
        Edge <= #TD BiosWatchDogReset;
        DisableBiosWD <= #TD ((BiosRegister == 8'h55) | (BiosRegister == 8'h29)) & (!BiosFinished);
        DisableTimer <= #TD (BiosRegister == 8'h29) | BiosFinished | BiosWatchDogReset;
        Freeze <= #TD BiosFinished | BiosWatchDogReset;
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
