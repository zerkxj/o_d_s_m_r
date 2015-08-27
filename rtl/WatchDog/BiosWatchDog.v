///////////////////////////////////////////////////////////////////
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
// Hierarchy Up	  : Lpc
// Hierarchy Down : ---
// Card Release	  : 1.0
///////////////////////////////////////////////////////////////////
`timescale 1 ns / 100 ps
`include "../Verilog/Includes/DefineODSTextMacro.v"

module BiosWatchDog(
	Reset,					// Generated PowerUp Reset
	SlowClock,				// Oscillator Clock 32,768 Hz
	LpcClock,				// 33 MHz Lpc (Altera Clock)
	MainReset,				// Power or Controller ICH10R Reset
    PS_ONn,
    DPx,
	Strobe125msec,			// Single LpcClock  Pulse @ 125 ms
	WriteBiosWD,			// CPU (BIOS) writes to BIOS WD Register (#1)
	BiosRegister,			// Bios Watch Dog Control Register
	BiosFinished,			// Bios Has been finished
	BiosPowerOff,			// BiosWD Occurred, Force Power Off
	ForceSwap				// BiosWD Occurred, Force BIOS Swap while power restart
	);
///////////////////////////////////////////////////////////////////
input			Reset, SlowClock;
input			LpcClock, MainReset, Strobe125msec, WriteBiosWD;
input           PS_ONn;
input	[7:0]	BiosRegister;
output	[1:0]	DPx;
output			BiosFinished, BiosPowerOff, ForceSwap;
///////////////////////////////////////////////////////////////////
reg		[9:0]	BiosTimer;
reg		[5:0]	BiosTimer4sec;
reg				BiosPowerOff, BiosWatchDogReset, Edge, ForceSwap;
reg				BiosFinished, DisableBiosWD, DisableTimer, Freeze;
wire    [1:0]   DPx;

assign DPx[1] = (DisableTimer) ? 1'b0 : (0 == BiosTimer) ? 1'b0 : 1'b1;
assign DPx[0] = (Freeze) ? 1'b0 : (0 == BiosTimer4sec) ? 1'b0 : 1'b1;
///////////////////////////////////////////////////////////////////
	initial
	begin
        BiosTimer			= 0;
        BiosTimer4sec		= 0;
        BiosPowerOff		= 0;
        BiosWatchDogReset	= 0;
        Edge				= 0;
	end

always	@(posedge LpcClock)
  if(!MainReset && `PwrSW_Off == PS_ONn) 
    begin
      BiosTimer			<= 0;
      BiosTimer4sec		<= 0;
      BiosWatchDogReset	<= 0;
      Edge				<= 0;
      ForceSwap			<= 0;
      DisableBiosWD		<= 0;
      DisableTimer		<= 0;
      BiosFinished		<= 0;
      Freeze			<= 0;
    end
  else
    begin
      BiosTimer			<= DisableTimer ? BiosTimer :
      						Strobe125msec ? BiosTimer + 1'b1 : BiosTimer;
      BiosTimer4sec		<= Freeze ? BiosTimer4sec : (WriteBiosWD | DisableBiosWD) ? 6'h0 :
      						Strobe125msec ? BiosTimer4sec + 1'b1 : BiosTimer4sec;
      BiosWatchDogReset	<= BiosTimer[9] | BiosTimer4sec[5];
      //BiosWatchDogReset	<= BiosTimer[9];
      Edge				<= BiosWatchDogReset;
      ForceSwap			<= BiosWatchDogReset & !Edge;
	  ///////////////////////////////////////////////////////
	  
       DisableBiosWD		<= ((BiosRegister == 8'h55) | (BiosRegister == 8'h29)) & !BiosFinished; 	  
	   
       DisableTimer		<= (BiosRegister == 8'h29) | BiosFinished | BiosWatchDogReset;	  
	  
       BiosFinished		<= (BiosRegister == 8'hFF) |  BiosFinished;
	  
	  //////////////////////////////////////////////////////////
	  
      //DisableTimer		<= (BiosRegister == 8'h28) | BiosFinished | BiosWatchDogReset;
      //BiosFinished		<= (BiosRegister == 8'hFE) |  BiosFinished;
      Freeze			<= BiosFinished | BiosWatchDogReset;
    end
///////////////////////////////////////////////////////////////////
always @ (posedge SlowClock or negedge Reset)
  if(!Reset)		BiosPowerOff		<= 0; 
   else				BiosPowerOff		<= BiosWatchDogReset;   
///////////////////////////////////////////////////////////////////
endmodule
///////////////////////////////////////////////////////////////////
