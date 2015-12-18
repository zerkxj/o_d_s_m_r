//******************************************************************************
// File name      : WatchDog.v
// Module name    : WatchDog
// Company        : Radware
// Project name   : ODS-LS
// Card name      : Yarkon
// Designer       : Fedor Haikin
// Creation Date  : 08.02.2011
// Status         : Under design
// Last modified  : 08.02.2011
// Version        : 1.0
// Description    : This module controls System Watch Dog
// Hierarchy Up   : Lpc
// Hierarchy Down : ---
// Card Release   : 1.0
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Macro define or include file
//------------------------------------------------------------------------------
// None

//------------------------------------------------------------------------------
// Module declaration
//------------------------------------------------------------------------------
module WatchDog (
    PciReset,           // In, PCI Reset
    LpcClock,           // In, 33 MHz Lpc (Altera Clock)
    Strobe125msec,      // In, Single LpcClock  Pulse @ 125 ms
    LoadWDTimer,        // In, load watch dog timer
    WatchDogRegister,   // In, Watch Dog Control / Status Register
    ClearInterrupt,     // In, Clear Interrups: WatchDog, Reset, Power

    WatchDogOccurred,   // Out, occurr watch dog reset
    WatchDogReset,      // Out, System Watch Dog Reset Request
    WatchDogIREQ        // Out, watch dog inierrupt request
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
input           Strobe125msec;
input           LoadWDTimer;
input   [7:0]   WatchDogRegister;
input   [2:0]   ClearInterrupt;

//--------------------------------------------------------------------------
// Output declaration
//--------------------------------------------------------------------------
output          WatchDogOccurred; // Start after Watch Dog Reset
output          WatchDogReset;
output          WatchDogIREQ;

//------------------------------------------------------------------------------
// Signal declaration
//------------------------------------------------------------------------------
//--------------------------------------------------------------------------
// Wire declaration
//--------------------------------------------------------------------------
//----------------------------------------------------------------------
// Combinational, module connection
//----------------------------------------------------------------------
wire            WatchDogEnable;

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
reg             WatchDogOccurred; // Start after Watch Dog Reset
reg             WatchDogReset;
reg             WatchDogIREQ;

//------------------------------------------------------------------
// Internal signal
//------------------------------------------------------------------
reg             StopIREQ;
reg             CountEnable;
reg             SelfLoad;
reg     [1:0]   Edge;
reg     [6:0]   Timer; // 4 bits seconds, 3 bits - 125ms counting

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
assign WatchDogEnable = WatchDogRegister[4];

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
        WatchDogOccurred <= #TD 1'b0;
    else
        WatchDogOccurred <= #TD WatchDogReset | WatchDogOccurred;
end

always @ (posedge LpcClock or negedge PciReset) begin
    if (!PciReset)
        WatchDogReset <= #TD 1'b0;
    else
        WatchDogReset <= #TD (Edge == 2'h1) & WatchDogIREQ & WatchDogEnable | WatchDogReset;
end

always @ (posedge LpcClock or negedge PciReset) begin
    if (!PciReset)
        WatchDogIREQ <= #TD 1'b0;
    else
        WatchDogIREQ <= #TD (Edge == 2'h1) | WatchDogIREQ & !StopIREQ;
end

//----------------------------------------------------------------------
// Internal signal
//----------------------------------------------------------------------
always @ (posedge LpcClock or negedge PciReset) begin
    if (!PciReset)
        StopIREQ <= #TD 1'b0;
    else
        StopIREQ <= #TD WatchDogReset | LoadWDTimer | ClearInterrupt[2];
end

always @ (posedge LpcClock or negedge PciReset) begin
    if (!PciReset)
        CountEnable <= #TD 1'b0;
    else
        CountEnable <= #TD Strobe125msec & |Timer;
end

always @ (posedge LpcClock or negedge PciReset) begin
    if (!PciReset)
        SelfLoad <= #TD 1'b0;
    else
        SelfLoad <= #TD Strobe125msec & WatchDogIREQ & Edge[0];
end

always @ (posedge LpcClock or negedge PciReset) begin
    if (!PciReset)
        Edge <= #TD 2'h3;
    else
        Edge <= #TD {Edge[0], (Timer == 7'h0)};
end

always @ (posedge LpcClock or negedge PciReset) begin
    if (!PciReset)
        Timer <= #TD 7'h00;
    else if (LoadWDTimer)
             Timer <= #TD {WatchDogRegister[3:0], 3'h0};
         else if (SelfLoad)
                  Timer <= #TD 7'h8;
              else if (CountEnable)
                       Timer <= #TD Timer - 7'h01;
                   else 
                       Timer <= #TD Timer;
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
