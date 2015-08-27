///////////////////////////////////////////////////////////////////
// File name      : FanDisplay.v
// Module name    : FanDisplay
// Company        : Radware
// Project name   : ODS-LS
// Card name      : Yarkon
// Designer       : Fedor Haikin
// Creation Date  : 12.04.2011
// Status         : Under design
// Last modified  : 12.04.2011
// Version        : 1.0
// Description    : This module controls FAN Status LED
// Hierarchy Up	  : ODSLS
// Hierarchy Down : -------
// Card Release	  : 1.0
///////////////////////////////////////////////////////////////////

`define FANLedOff               2'b11
`define FANLedRed               2'b10
`define FANLedGreen             2'b01

module FanLED( // FanDisplay(
	SlowClock,				// Oscillator Clock 32,768 Hz
	Strobe16ms,				// Single SlowClock Pulse @ 16 ms
	Beep,					// Fan Fail - 1, FanOK - 0; - has internal weak P/U
    FanLedCtrlReg,
	FanFail,				// Fan Led indication
	FanOK					// 
	);
///////////////////////////////////////////////////////////////////
input			SlowClock, Strobe16ms, Beep;
input   [3:0]   FanLedCtrlReg;
output			FanFail, FanOK;
///////////////////////////////////////////////////////////////////
reg		[1:0]	Sample;
reg				Tone;
reg				FanFailx, FanOKx; 
wire			FanFail, FanOK;
///////////////////////////////////////////////////////////////////
wire			Fail = |Sample;
///////////////////////////////////////////////////////////////////

assign {FanOK, FanFail} = (1'b0 == FanLedCtrlReg[0]) ? {FanOKx, FanFailx} :
                          (1'b1 == FanLedCtrlReg[1]) ? `FANLedOff :
                          (1'b1 == FanLedCtrlReg[2]) ? `FANLedGreen :
                          (1'b1 == FanLedCtrlReg[3]) ? `FANLedRed : `FANLedOff;

always	@(posedge SlowClock)
  begin
    Tone		<= Beep;
    Sample		<= Tone ? 2'h3 : (Strobe16ms & Fail) ? Sample - 1'b1 : Sample;
    FanFailx	<=  Fail;
    FanOKx		<= !Fail;
  end
///////////////////////////////////////////////////////////////////
endmodule
///////////////////////////////////////////////////////////////////
