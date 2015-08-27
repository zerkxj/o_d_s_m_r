///////////////////////////////////////////////////////////////////
// File name      : ButtonControl.v
// Module name    : ButtonControl
// Company        : Radware
// Project name   : ODS-LS
// Card name      : Yarkon
// Designer       : Fedor Haikin
// Creation Date  : 08.02.2011
// Status         : Under design
// Last modified  : 08.02.2011
// Version        : 1.0
// Description    : This module controls Power Button, System Reset Button
// Hierarchy Up	  : ODSLS
// Hierarchy Down : 
// Card Release	  : 1.0
///////////////////////////////////////////////////////////////////
module ButtonControl(
	MainReset,				// Power or Controller ICH10R Reset
	SlowClock,				// Oscillator Clock 32,768 Hz
	Strobe1s,				// Single SlowClock Pulse @ 1s
	Strobe16ms,				// Single SlowClock Pulse @ 16 ms
	Strobe125ms,			// Single SlowClock Pulse @ 125 ms
	SysReset,				// Reset Button
	PowerButtonIn,			// Power Button
	WatchDogReset,			// System Watch Dog Reset Request
	Interrupt,				// Power & Reset Interrupts and Button release
	PowerButtonOut,			// Debounced Power Button
	ResetOut				// Active Wide Strobe 4s after  the button pushed
	);
///////////////////////////////////////////////////////////////////
input			MainReset, SlowClock, Strobe1s, Strobe16ms, Strobe125ms;
input			SysReset, PowerButtonIn, WatchDogReset;
output	[3:0]	Interrupt;
output			PowerButtonOut, ResetOut;
///////////////////////////////////////////////////////////////////
wire			PowerInterrupt, PowerRelease;
wire			ResetInterrupt, ResetRelease, ResetStrobe;
///////////////////////////////////////////////////////////////////
assign			Interrupt = {PowerInterrupt, PowerRelease, ResetInterrupt, ResetRelease};
assign			ResetOut = ResetStrobe & !WatchDogReset;
///////////////////////////////////////////////////////////////////
Button #(.RST(1'b0)) PowerButton(
	MainReset,			// Power or Controller ICH10R Reset
	SlowClock,			// Oscillator Clock 32,768 Hz
	Strobe16ms,			// Single SlowClock Pulse @ 16 ms
	Strobe125ms,		// Single SlowClock Pulse @ 125 ms
	PowerButtonIn,		// Button Input
	PowerInterrupt,		// Single SlowClock Pulse 1s after the button pushed
	PowerButtonOut,		// Debounced Power Button
	PowerRelease		// Single SlowClock Pulse after the button released
	);
///////////////////////////////////////////////////////////////////
Button #(.RST(1'b1)) ResetButton(
	MainReset,			// Power or Controller ICH10R Reset
	SlowClock,			// Oscillator Clock 32,768 Hz
	Strobe16ms,			// Single SlowClock Pulse @ 16 ms
	Strobe125ms,		// Single SlowClock Pulse @ 125 ms
	SysReset,			// Button Input
	ResetInterrupt,		// Single SlowClock Pulse 1s after the button pushed
	ResetStrobe,		// Active Wide Strobe 4s after  the button pushed
	ResetRelease		// Single SlowClock Pulse after the button released
	);
///////////////////////////////////////////////////////////////////
endmodule
///////////////////////////////////////////////////////////////////
module Button(
	MainReset,			// Power or Controller ICH10R Reset
	SlowClock,			// Oscillator Clock 32,768 Hz
	Strobe16ms,			// Single SlowClock Pulse @ 16 ms
	Strobe125ms,		// Single SlowClock Pulse @ 125 ms
	ButtonIn,			// Button Input
	Interrupt,			// Single SlowClock Pulse 1s after the button pushed
	StrobeOut,			// Active Wide Strobe 4s after  the button pushed
	Release				// Single SlowClock Pulse after the button released
	);
///////////////////////////////////////////////////////////////////
parameter		RST = 0;
///////////////////////////////////////////////////////////////////
input			MainReset, SlowClock, Strobe16ms, Strobe125ms;
input			ButtonIn;
output			Interrupt, Release, StrobeOut;
///////////////////////////////////////////////////////////////////
reg		[2:0]	Debounce;
reg				Status, Interrupt, Strobe, Release;
reg		[5:0]	Timer;
///////////////////////////////////////////////////////////////////
wire			Widest = Timer[5];
///////////////////////////////////////////////////////////////////
assign			StrobeOut = RST ? Strobe : Status;
///////////////////////////////////////////////////////////////////
initial
begin
    Debounce	= 0;
    Status		= 0;
    Interrupt	= 0;
    Strobe		= 0;
    Release		= 0;
    Timer		= 0;
end

always	@(posedge SlowClock or negedge MainReset)
  if(!MainReset)
    begin
      Debounce			<= 3'h7;
      Status			<= 1;
      Timer				<= 0;
      Interrupt			<= 0;
      Strobe			<= 1;
      Release			<= 0;
    end
  else
    begin
      if(Strobe16ms)
        begin
          Debounce		<= {Debounce[1:0], ButtonIn};
          Status		<= (Debounce == 3'h7) | Status & (Debounce != 3'h0);
        end
      if(Strobe125ms)
        if(Status)
          Timer			<= 6'h0;
        else
          Timer			<= Widest ? Timer : Timer + 1'b1;
      Interrupt			<= (Timer == 6'h7) & Strobe125ms;
      Strobe			<= (Timer != 6'h1F);
      Release			<= (Debounce == 3'h7) & !Status & Strobe16ms;
    end
///////////////////////////////////////////////////////////////////
endmodule
///////////////////////////////////////////////////////////////////
