///////////////////////////////////////////////////////////////////
// File name      : InterruptControl.v
// Module name    : InterruptControl
// Company        : Radware
// Project name   : ODS-LS
// Card name      : Yarkon
// Designer       : Fedor Haikin
// Creation Date  : 08.02.2011
// Status         : Under design
// Last modified  : 08.02.2011
// Version        : 1.0
// Description    : This module controls Interrupts
// Hierarchy Up	  : Lpc
// Hierarchy Down : ---
// Card Release	  : 1.0
///////////////////////////////////////////////////////////////////
module InterruptControl(
	PciReset,				// PCI Reset
	LpcClock,				// 33 MHz Lpc (Altera Clock)
	Write,					// Write Access to CPLD registers
	WatchDogIREQ,			// Watch Dog Interrupt Request
	RegAddress,				// Address of the accessed Register
	Data,					// Data to be written to register
	Interrupt,				// Power & Reset Interrupts and Button release
	ClearInterrupt,			// Clear Interrups: WatchDog, Reset, Power
	InterruptRegister,		// Interrupt Control / Status Register
	InterruptD				// Interrupt Request to CPU
	);
///////////////////////////////////////////////////////////////////
input			PciReset, LpcClock, Write, WatchDogIREQ;
input	[4:0]	RegAddress;
input	[7:0]	Data;
input	[3:0]	Interrupt;
output	[6:4]	ClearInterrupt;
output	[5:0]	InterruptRegister;
output			InterruptD;
///////////////////////////////////////////////////////////////////
reg		[3:0]	Control;	// ATX Mode, WD En, Reset En, Power En
reg		[6:4]	ClearInterrupt;
reg		[5:4]	IREQ;		// Reset, Power Interrup requests;
///////////////////////////////////////////////////////////////////
wire			WriteInt = Write & (RegAddress == 5'h9);
wire			ATX = Control[3];
wire			ResetEvent = ATX ? Interrupt[0] : Interrupt[1];
wire			PowerEvent = ATX ? Interrupt[2] : Interrupt[3];
wire	[6:4]	Request = {WatchDogIREQ, IREQ};
wire			InterruptRequest = |(Request & Control[2:0]);
///////////////////////////////////////////////////////////////////
assign			InterruptRegister = {IREQ, Control};
assign			InterruptD = InterruptRequest ? 1'b0 : 1'bz;
///////////////////////////////////////////////////////////////////
always	@(posedge LpcClock or negedge PciReset)
  if(!PciReset)
    begin
      Control				<= 0;
      ClearInterrupt		<= 0;
      IREQ					<= 0;
    end
  else
    begin
      Control				<= WriteInt ? Data[3:0] : Control;
      ClearInterrupt		<= WriteInt ? Data[6:4] : 3'b000;
      IREQ[5]				<= ResetEvent | IREQ[5] & !ClearInterrupt[5];
      IREQ[4]				<= PowerEvent | IREQ[4] & !ClearInterrupt[4];
    end
///////////////////////////////////////////////////////////////////
endmodule
///////////////////////////////////////////////////////////////////
//	Interrupt Control Register								0x09
///////////////////////////////////////////////////////////////////
//	bits
//	7			Not Used: Default "0"						RO
//	6			Watch Dog	 Interrupt Occurred				R-WC
//	5			Reset Button Interrupt Occurred				R-WC
//	4			Power Button Interrupt Occurred				R-WC
//	3			ATX Mode									RW
//	2			Watch Dog    Interrupt Enable				RW
//	1			Reset Button Interrupt Enable				RW
//	0			Power Button Interrupt Enable				RW
///////////////////////////////////////////////////////////////////
// Interrupt = {PowerInterrupt, PowerRelease, ResetInterrupt, ResetRelease};
///////////////////////////////////////////////////////////////////
