///////////////////////////////////////////////////////////////////
`timescale 1ps/1ps
///////////////////////////////////////////////////////////////////
// File name      	: StrobeGen.v
// Module name    	: StrobeGen
// Company        	: Radware
// Project name   	: ODS-LS
// Card name      	: Yarkon
// Designer       	: Iris  Bener Sharoni
// Creation Date  	: 15.10.2010
// Status         	: Under design
// Last modified by	: Iris Bener Sharoni
// Last modified  	: 15.10.2010
// Version        	: 1.0							
// Description    	: Generates cyclic strobe signals
// Hierarchy Up	  	: ODSLS
// Hierarchy Down 	: -
// Card Release	  	: 1.0
///////////////////////////////////////////////////////////////////
module StrobeGen(
	ResetN,
	LpcClock,				// 33 MHz Lpc (Altera Clock)
	SlowClock,				// Oscillator Clock 32,768 Hz
	Strobe1s,				// Single SlowClock Pulse @ 1 s
	Strobe488us,			// Single SlowClock Pulse @ 488 us
	Strobe1ms,				// Single SlowClock Pulse @ 1 ms
	Strobe16ms,				// Single SlowClock Pulse @ 16 ms
	Strobe125ms,			// Single SlowClock Pulse @ 125 ms
	Strobe125msec,			// Single LpcClock  Pulse @ 125 ms
	Counter					// 15 bit Free run Counter on Slow Clock
	);
///////////////////////////////////////////////////////////////////
input			ResetN, LpcClock, SlowClock;
output			Strobe1s, Strobe1ms, Strobe16ms, Strobe125ms, Strobe125msec;
output			Strobe488us;
output	[14:0]	Counter;
///////////////////////////////////////////////////////////////////
reg				Strobe1s, Strobe1ms, Strobe16ms, Strobe125ms;
reg				Strobe488us;
reg 	[14:0]	Counter;
///////////////////////////////////////////////////////////////////
reg		[1:0]	StrobeEdge;
reg				Strobe125msec;
///////////////////////////////////////////////////////////////////
always @ (posedge SlowClock or negedge ResetN)
  if (!ResetN)
    begin
      Counter 			<= 0;
      Strobe1s			<= 0;
      Strobe125ms		<= 0;
      Strobe16ms 		<= 0;
      Strobe1ms			<= 0;
      Strobe488us		<= 0;
    end
  else
    begin
      Counter			<= Counter + 1'b1;
      //Strobe1s			<= Counter		 == 15'h5;
      Strobe1s			<= Counter		 == 15'h5;
      Strobe125ms		<= Counter[11:0] == 12'h5;
      Strobe16ms		<= Counter[8:0]  ==  9'h5;
      Strobe1ms			<= Counter[4:0]  ==  5'h5;
      Strobe488us		<= Counter[3:0]  ==  4'h5;
    end
///////////////////////////////////////////////////////////////////
always	@(posedge LpcClock or negedge ResetN)
  if(!ResetN)
    begin
      StrobeEdge		<= 0;
      Strobe125msec		<= 0;
    end
  else
    begin
      StrobeEdge		<= {StrobeEdge[0], Strobe125ms};
      Strobe125msec		<= StrobeEdge == 2'h1;
    end
///////////////////////////////////////////////////////////////////
endmodule
///////////////////////////////////////////////////////////////////
