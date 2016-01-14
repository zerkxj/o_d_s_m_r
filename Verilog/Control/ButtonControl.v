//******************************************************************************
// File name        : ButtonControl.v
// Module name      : ButtonControl
// Company          : Radware
// Project name     : ODS-MR
// Card name        : Yarkon
// Designer         : Fedor Haikin
// Creation Date    : 08.02.2011
// Status           : Under design
// Last modified    : 10.13.2015
// Version          : 1.0
// Description      : This module controls Power Button, System Reset Button
// Hierarchy Up     : ODS_MR
// Hierarchy Down   :
// Card Release     : 1.0
//******************************************************************************

//------------------------------------------------------------------------------
// Macro define or include file
//------------------------------------------------------------------------------
// None

//------------------------------------------------------------------------------
// Module declaration
//------------------------------------------------------------------------------
module ButtonControl (
    MainReset,          // In, Power or Controller ICH10R Reset
    SlowClock,          // In, Oscillator Clock 32,768 Hz
    Strobe1s,           // In, Single SlowClock Pulse @ 1s
    Strobe16ms,         // In, Single SlowClock Pulse @ 16 ms
    Strobe125ms,        // In, Single SlowClock Pulse @ 125 ms
    SysReset,           // In, Reset Button
    PowerButtonIn,      // In, Power Button
    WatchDogReset,      // In, System Watch Dog Reset Request
    PWRGD_PS_PWROK_3V3, // In, 3V3 Power Good
    FM_PS_EN,           // In, Power Supply enable
    PowerbuttonEvt,     // In, Power button event
    PowerEvtState,      // In, Power evnet state

    Interrupt,              // Out, Power & Reset Interrupts and Button release
    PowerButtonDebounce,    // Out, Debounced Power Button
    ResetOut,               // Out, Active Wide Strobe 4s after  the button pushed
    RstBiosFlg,             // Out,
    FM_SYS_SIO_PWRBTN_N     // Out
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
input           MainReset;
input           SlowClock;
input           Strobe1s;
input           Strobe16ms;
input           Strobe125ms;
input           SysReset;
input           PowerButtonIn;
input           WatchDogReset;
input           PWRGD_PS_PWROK_3V3;
input           FM_PS_EN;
input           PowerbuttonEvt;
input   [3:0]   PowerEvtState;

//--------------------------------------------------------------------------
// Output declaration
//--------------------------------------------------------------------------
output  [3:0]   Interrupt;
output          PowerButtonDebounce;
output          ResetOut;
output          RstBiosFlg;
output          FM_SYS_SIO_PWRBTN_N;

//------------------------------------------------------------------------------
// Signal declaration
//------------------------------------------------------------------------------
//--------------------------------------------------------------------------
// Wire declaration
//--------------------------------------------------------------------------
//----------------------------------------------------------------------
// Combinational, module connection
//----------------------------------------------------------------------
wire            PowerInterrupt;
wire            PowerRelease;
wire            ResetInterrupt;
wire            ResetRelease;
wire            ResetStrobe;

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
reg     [9:0]   PowerButtonInBuf;

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
assign Interrupt = {PowerInterrupt, PowerRelease, ResetInterrupt, ResetRelease};
assign ResetOut = ResetStrobe & !WatchDogReset;
assign RstBiosFlg = (PWRGD_PS_PWROK_3V3) ? 1'b0 :
                        ((PowerEvtState == `Event_PowerStandBy) && (~PowerButtonIn)) ? 1'b1 :
                            ((~PowerButtonInBuf[9]) && (FM_PS_EN == `PwrSW_Off)) ? 1'b1 : 1'b0;
assign FM_SYS_SIO_PWRBTN_N = PowerButtonDebounce & PowerbuttonEvt;

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
always @ (posedge Strobe125ms or negedge MainReset) begin
    if(!MainReset)
        PowerButtonInBuf <= #TD 10'd0;
    else
        PowerButtonInBuf <= #TD {PowerButtonInBuf[8:0], PowerButtonIn};
end

//----------------------------------------------------------------------
// FSM
//----------------------------------------------------------------------
// None

//--------------------------------------------------------------------------
// Module instantiation
//--------------------------------------------------------------------------
Button #(.RST(1'b0))
    u_PowerButton(.MainReset(MainReset),        // In, Power or Controller ICH10R Reset
                  .SlowClock(SlowClock),        // In, Oscillator Clock 32,768 Hz
                  .Strobe16ms(Strobe16ms),      // In, Single SlowClock Pulse @ 16 ms
                  .Strobe125ms(Strobe125ms),    // In, Single SlowClock Pulse @ 125 ms
                  .ButtonIn(PowerButtonIn),     // In, Button Input
                  .Interrupt(PowerInterrupt),   // Out, Single SlowClock Pulse 1s after the button pushed
                  .StrobeOut(PowerButtonDebounce),   // Out, Active Wide Strobe 4s after the button pushed
                  .Release(PowerRelease));      // Out, Single SlowClock Pulse after the button released

Button #(.RST(1'b1))
    u_ResetButton(.MainReset(MainReset),        // In, Power or Controller ICH10R Reset
                  .SlowClock(SlowClock),        // In, Oscillator Clock 32,768 Hz
                  .Strobe16ms(Strobe16ms),      // In, Single SlowClock Pulse @ 16 ms
                  .Strobe125ms(Strobe125ms),    // In, Single SlowClock Pulse @ 125 ms
                  .ButtonIn(SysReset),          // In, Button Input
                  .Interrupt(ResetInterrupt),   // Out, Single SlowClock Pulse 1s after the button pushed
                  .StrobeOut(ResetStrobe),      // Out, Active Wide Strobe 4s after the button pushed
                  .Release(ResetRelease));      // Out, Single SlowClock Pulse after the button released

endmodule
