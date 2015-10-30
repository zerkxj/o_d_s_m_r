///////////////////////////////////////////////////////////////////
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
// Hierarchy Up	  : Lpc
// Hierarchy Down : ---
// Card Release	  : 1.0
///////////////////////////////////////////////////////////////////
module WatchDog(
	PciReset,				// PCI Reset
	LpcClock,				// 33 MHz Lpc (Altera Clock)
	Strobe125msec,			// Single LpcClock  Pulse @ 125 ms
	Write,					// Write Access to CPLD registers
	Read,					// Read  Access to CPLD registers
   
	ClearInterrupt,			// Clear Interrups: WatchDog, Reset, Power
	RegAddress,				// Address of the accessed Register
	Data,					// Data to be written to register
	WatchDogRegister,		// Watch Dog Control / Status Register
	WatchDogReset			// System Watch Dog Reset Request
	);
///////////////////////////////////////////////////////////////////
input			PciReset, LpcClock, Strobe125msec, Write, Read;
input	[2:0]	ClearInterrupt;
input	[4:0]	RegAddress;
input	[7:0]	Data;
output	[6:0]	WatchDogRegister;
output			WatchDogReset;
///////////////////////////////////////////////////////////////////
reg				WatchDogEnable, StopIREQ;
reg				WatchDogIREQ, CountEnable, SelfLoad, WatchDogReset;
reg		[1:0]	Edge;
reg		[6:0]	Timer;	// 4 bits seconds, 3 bits - 125ms counting
reg				WatchDogOccurred;	// Start after Watch Dog Reset
reg				WatchDogIntrEvt;	// Start after Watch Dog Intrrupt
wire	[6:0]	WatchDogRegister;
///////////////////////////////////////////////////////////////////
wire			WriteWD = Write & (RegAddress == 5'hB);
wire			ReadWD  = Read  & (RegAddress == 5'hB);

///////////////////////////////////////////////////////////////////
assign			WatchDogRegister = {WatchDogOccurred, (WatchDogIREQ | WatchDogIntrEvt), WatchDogEnable,
											Timer[6:3]};
///////////////////////////////////////////////////////////////////
always	@(posedge LpcClock or negedge PciReset)
  if(!PciReset)
    begin
      Timer					<= 0;
      WatchDogEnable		<= 0;
      Edge					<= 2'h3;
      SelfLoad				<= 0;
      CountEnable			<= 0;
      WatchDogIREQ			<= 0;
      StopIREQ				<= 0;
      WatchDogReset			<= 0;
    end
  else
    begin
      Timer					<= WriteWD  ? {Data[3:0], 3'h0} :
      						   SelfLoad ? 7'h8 :
      						   CountEnable ? Timer - 1'b1 : Timer;
      WatchDogEnable		<= WriteWD ? Data[4] : WatchDogEnable;
      Edge					<= {Edge[0], Timer == 7'h0};
      SelfLoad				<= Strobe125msec & WatchDogIREQ & Edge[0];
      CountEnable			<= Strobe125msec & |Timer;
      WatchDogIREQ			<= (Edge == 2'h1) | WatchDogIREQ & !StopIREQ;
      StopIREQ				<= WatchDogReset | WriteWD | ClearInterrupt[2];
      WatchDogReset			<= (Edge == 2'h1) & WatchDogIREQ & WatchDogEnable | WatchDogReset;
    end
///////////////////////////////////////////////////////////////////
always	@(posedge LpcClock)
  WatchDogOccurred	<= WatchDogReset | WatchDogOccurred & !ReadWD;

always	@(posedge LpcClock)
  WatchDogIntrEvt	<= WatchDogIREQ | WatchDogIntrEvt & !ReadWD;
///////////////////////////////////////////////////////////////////
initial
begin
			WatchDogOccurred = 0;
            WatchDogIntrEvt  = 0;
end
///////////////////////////////////////////////////////////////////
endmodule
///////////////////////////////////////////////////////////////////
//	Watch Dog Control Register								0x03
///////////////////////////////////////////////////////////////////
//	bits
//	7			There was reset by Watch Dog				RC
//	6			Watch Dog Interrupt Enable (Mirror)			RO
//	5			Watch Dog Interrupt Occurred				RO
//	4			Watch Dog Enable							RW
//	3:0			Time remains in seconds						RW
///////////////////////////////////////////////////////////////////
